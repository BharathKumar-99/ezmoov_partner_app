// Supabase Edge Function: razorpay-webhook
// Securely processes Razorpay payment.captured and order.paid webhooks for Customer & Driver Wallet Recharges and Booking Payments

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-razorpay-signature",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const signature = req.headers.get("x-razorpay-signature");
    const rawBody = await req.text();
    const webhookSecret = Deno.env.get("RAZORPAY_WEBHOOK_SECRET") || "";

    // Validate Signature using HMAC-SHA256 if secret is configured
    if (signature && webhookSecret) {
      const key = await crypto.subtle.importKey(
        "raw",
        new TextEncoder().encode(webhookSecret),
        { name: "HMAC", hash: "SHA-256" },
        false,
        ["sign", "verify"]
      );

      const signatureBytes = new Uint8Array(
        signature.match(/.{1,2}/g)?.map((byte) => parseInt(byte, 16)) || []
      );
      const bodyBytes = new TextEncoder().encode(rawBody);

      const isValid = await crypto.subtle.verify(
        "HMAC",
        key,
        signatureBytes,
        bodyBytes
      );

      if (!isValid) {
        console.error("Invalid Razorpay Webhook Signature");
        return new Response(JSON.stringify({ error: "Invalid webhook signature" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    const payload = JSON.parse(rawBody);
    console.log("Received Razorpay Webhook Event:", payload.event);

    // Process payment.captured or order.paid events
    if (payload.event === "payment.captured" || payload.event === "order.paid") {
      const payment = payload.payload?.payment?.entity;
      const notes = payment?.notes || {};

      const rawCustomerId = notes.customer_id || notes.user_id || notes.customerId;
      const customerId = typeof rawCustomerId === "string" ? rawCustomerId.trim() : null;

      const rawDriverId = notes.driver_id || notes.driverId || notes.driver_uuid;
      const driverId = typeof rawDriverId === "string" ? rawDriverId.trim() : null;

      const rawBookingId = notes.booking_id || notes.trip_id || notes.bookingId;
      const bookingId = typeof rawBookingId === "string" ? rawBookingId.trim() : null;

      const amountInRupees = (payment.amount || 0) / 100;

      // Initialize Supabase Client using Service Role key to bypass RLS
      const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
      const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
      const supabase = createClient(supabaseUrl, supabaseServiceKey);

      // CASE 1: CUSTOMER WALLET RECHARGE (EzMoov Customer App)
      if (notes.type === "customer_wallet_recharge" || (customerId && !driverId)) {
        const targetUserId = customerId || driverId;
        if (!targetUserId) {
          console.error("Missing customer_id / user_id in payment notes for customer wallet recharge:", notes);
          return new Response(
            JSON.stringify({ error: "Missing customer_id in payment notes" }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        console.log(`Processing Customer Wallet Recharge via Webhook for user ${targetUserId}, amount: ₹${amountInRupees}`);
        
        let { data, error } = await supabase.rpc("recharge_customer_wallet", {
          p_user_id: targetUserId,
          p_amount: amountInRupees,
        });

        if (error) {
          console.warn("RPC recharge_customer_wallet failed, executing direct table fallback:", error.message);
          
          // Resilient Fallback: Direct table upsert using Service Role Key
          const { data: existingWallet } = await supabase
            .from("customer_wallets")
            .select("balance")
            .eq("user_id", targetUserId)
            .maybeSingle();

          const currentBalance = existingWallet?.balance || 0;
          const newBalance = currentBalance + amountInRupees;

          const { error: upsertErr } = await supabase
            .from("customer_wallets")
            .upsert({
              user_id: targetUserId,
              balance: newBalance,
              updated_at: new Date().toISOString(),
            }, { onConflict: "user_id" });

          if (upsertErr) {
            console.error("Direct table update fallback failed:", upsertErr);
            return new Response(JSON.stringify({ error: upsertErr.message }), {
              status: 500,
              headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
          }

          // Insert transaction log
          await supabase.from("customer_wallet_transactions").insert({
            user_id: targetUserId,
            amount: amountInRupees,
            type: "credit",
            title: "Wallet Top-up (Razorpay Webhook)",
            description: "Recharged via Razorpay Webhook",
            created_at: new Date().toISOString(),
          });

          data = { success: true, new_balance: newBalance, fallback: true };
        }

        console.log(`Customer wallet recharge successful via Webhook for user ${targetUserId}:`, data);
        return new Response(
          JSON.stringify({
            success: true,
            message: "Customer wallet recharged successfully via webhook",
            user_id: targetUserId,
            result: data,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // CASE 2.5: DIRECT DAILY FEE PAYMENT / RECHARGE WITHOUT WALLET (No Wallet Credit or Wallet Deduction)
      if (
        notes.type === "direct_daily_fee" ||
        notes.type === "pay_daily_fee_direct" ||
        notes.type === "recharge_without_wallet" ||
        notes.type === "direct_daily_platform_fee"
      ) {
        if (!driverId) {
          console.error("Missing driver_id in payment notes for direct daily fee payment:", notes);
          return new Response(
            JSON.stringify({ error: "Missing driver_id in payment notes" }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        console.log(`Processing Direct Daily Fee Payment (No Wallet) for driver ${driverId}, amount: ₹${amountInRupees}`);
        const todayStr = new Date().toISOString().split("T")[0];

        // 1. Fetch existing driver_daily_status record for today
        const { data: dailyStatus } = await supabase
          .from("driver_daily_status")
          .select("*")
          .eq("driver_id", driverId)
          .eq("status_date", todayStr)
          .maybeSingle();

        const dailyFee = amountInRupees || dailyStatus?.daily_fee || 100.0;

        // 2. Mark driver_daily_status fee_deducted = true (Activates 24 hr pass)
        const { error: dailyErr } = await supabase
          .from("driver_daily_status")
          .upsert({
            driver_id: driverId,
            status_date: todayStr,
            daily_fee: dailyFee,
            fee_deducted: true,
            is_blocked: (dailyStatus?.rejections_count || 0) >= 2,
            block_reason: (dailyStatus?.rejections_count || 0) >= 2 ? "exceeded_rejections" : null,
            updated_at: new Date().toISOString(),
          }, { onConflict: "driver_id,status_date" });

        if (dailyErr) {
          console.error("Error updating driver_daily_status via direct fee payment:", dailyErr);
          return new Response(JSON.stringify({ error: dailyErr.message }), {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }

        // 3. Add single transaction entry to wallet_transactions table:
        // type: "daily_deduction", description: "Daily Vehicle Platform Fee (YYYY-MM-DD)"
        // Note: Skips adding money to wallet, skips deducting from wallet balance
        await supabase.from("wallet_transactions").insert({
          driver_id: driverId,
          amount: -dailyFee,
          type: "daily_deduction",
          description: `Daily Vehicle Platform Fee (${todayStr})`,
          created_at: new Date().toISOString(),
        });

        console.log(`Direct Daily Fee Payment successful via Webhook for driver ${driverId}`);
        return new Response(
          JSON.stringify({
            success: true,
            message: "Direct daily fee payment processed successfully via webhook",
            driver_id: driverId,
            daily_fee: dailyFee,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // CASE 2: DRIVER WALLET RECHARGE (Partner App)
      if (driverId || notes.type === "wallet_recharge" || notes.type === "driver_wallet_recharge") {
        if (!driverId) {
          console.error("Missing driver_id in payment notes for driver wallet recharge:", notes);
          return new Response(
            JSON.stringify({ error: "Missing driver_id in payment notes" }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        console.log(`Processing Driver Wallet Recharge via Webhook for driver ${driverId}, amount: ₹${amountInRupees}`);
        
        let { data, error } = await supabase.rpc("recharge_driver_wallet", {
          p_driver_id: driverId,
          p_amount: amountInRupees,
        });

        if (error) {
          console.warn("RPC recharge_driver_wallet failed, executing direct table fallback:", error.message);
          
          // Resilient Fallback: Direct table update using Service Role Key
          const { data: existingWallet } = await supabase
            .from("driver_wallets")
            .select("balance")
            .eq("driver_id", driverId)
            .maybeSingle();

          const currentBalance = existingWallet?.balance || 0;
          const newBalance = currentBalance + amountInRupees;

          const { error: upsertErr } = await supabase
            .from("driver_wallets")
            .upsert({
              driver_id: driverId,
              balance: newBalance,
              updated_at: new Date().toISOString(),
            }, { onConflict: "driver_id" });

          if (upsertErr) {
            console.error("Direct table update fallback failed for driver wallet:", upsertErr);
            return new Response(JSON.stringify({ error: upsertErr.message }), {
              status: 500,
              headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
          }

          // Insert transaction log
          await supabase.from("wallet_transactions").insert({
            driver_id: driverId,
            amount: amountInRupees,
            type: "recharge",
            description: "Wallet Recharge via Razorpay",
            created_at: new Date().toISOString(),
          });

          // Check & Auto-Deduct Daily Fee if pending and balance is sufficient
          const todayStr = new Date().toISOString().split("T")[0];
          const { data: dailyStatus } = await supabase
            .from("driver_daily_status")
            .select("*")
            .eq("driver_id", driverId)
            .eq("status_date", todayStr)
            .maybeSingle();

          const dailyFee = dailyStatus?.daily_fee || 100.0;
          let feeDeducted = dailyStatus?.fee_deducted || false;

          if (!feeDeducted && newBalance >= dailyFee) {
            const balanceAfterFee = newBalance - dailyFee;
            await supabase
              .from("driver_wallets")
              .update({ balance: balanceAfterFee, updated_at: new Date().toISOString() })
              .eq("driver_id", driverId);

            await supabase.from("wallet_transactions").insert({
              driver_id: driverId,
              amount: -dailyFee,
              type: "daily_deduction",
              description: `Daily Vehicle Platform Fee (${todayStr})`,
              created_at: new Date().toISOString(),
            });

            await supabase.from("driver_daily_status").upsert({
              driver_id: driverId,
              status_date: todayStr,
              daily_fee: dailyFee,
              fee_deducted: true,
              is_blocked: (dailyStatus?.rejections_count || 0) >= 2,
              block_reason: (dailyStatus?.rejections_count || 0) >= 2 ? "exceeded_rejections" : null,
              updated_at: new Date().toISOString(),
            }, { onConflict: "driver_id,status_date" });

            feeDeducted = true;
          }

          data = { success: true, new_balance: newBalance, fee_deducted: feeDeducted, fallback: true };
        }

        console.log(`Driver wallet recharge successful via Webhook for driver ${driverId}:`, data);
        return new Response(
          JSON.stringify({
            success: true,
            message: "Driver wallet recharged successfully via webhook",
            driver_id: driverId,
            result: data,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // CASE 3: BOOKING / RIDE PAYMENT
      if (bookingId) {
        const paymentModeData = {
          mode: "online",
          method: "Online Payment (Razorpay)",
          payment_id: payment.id,
          order_id: payment.order_id,
          amount: amountInRupees,
          currency: payment.currency || "INR",
          status: payment.status || "captured",
          paid_at: new Date().toISOString(),
        };

        const { data, error } = await supabase
          .from("bookings")
          .update({
            status: "amount_paid",
            payment_mode: paymentModeData,
            updated_at: new Date().toISOString(),
          })
          .eq("id", bookingId)
          .select();

        if (error) {
          console.error("Error updating booking status via Webhook:", error);
          return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }

        console.log(`Booking ${bookingId} status successfully updated to amount_paid via Razorpay Webhook`);

        return new Response(
          JSON.stringify({
            success: true,
            message: "Booking status updated to amount_paid",
            booking_id: bookingId,
            booking: data,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      console.warn("Neither customer_id, driver_id nor booking_id present in payment notes:", notes);
      return new Response(
        JSON.stringify({ message: "No customer_id, driver_id or booking_id present in payment notes" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ message: "Event received & ignored", event: payload.event }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    console.error("Razorpay Webhook processing exception:", err);
    return new Response(
      JSON.stringify({ error: err.message || "Internal Server Error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
