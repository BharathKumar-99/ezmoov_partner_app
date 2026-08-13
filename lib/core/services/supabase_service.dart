import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/driver_model.dart';
import '../../models/vehicle_model.dart';
import '../../models/vehicle_type_model.dart';
import '../../models/document_model.dart';
import '../../models/bank_details_model.dart';
import '../../models/rating_model.dart';
import '../../models/booking_model.dart';
import '../../models/earning_model.dart';
import '../../models/vehicle_catalog_model.dart';
import '../../models/wallet_model.dart';

class SupabaseService {
  SupabaseService._internal();
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  /// Check if driver exists in `drivers` table by phone number
  Future<DriverModel?> getDriverByPhone(String rawPhone) async {
    try {
      final cleanDigits = rawPhone.replaceAll(RegExp(r'\D'), '');
      if (cleanDigits.isEmpty) return null;

      final tenDigits = cleanDigits.length >= 10
          ? cleanDigits.substring(cleanDigits.length - 10)
          : cleanDigits;
      final withPlus91 = '+91$tenDigits';

      final response = await client
          .from('drivers')
          .select()
          .eq('phone', withPlus91)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return DriverModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting driver by phone: $e');
      rethrow;
    }
  }

  /// Get driver by ID
  Future<DriverModel?> getDriverById(String driverId) async {
    try {
      final response = await client
          .from('drivers')
          .select()
          .eq('id', driverId)
          .maybeSingle();

      if (response == null) return null;
      return DriverModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting driver by id: $e');
      rethrow;
    }
  }

  /// Send Phone OTP via Supabase Auth
  Future<void> sendPhoneOtp(String phone) async {
    try {
      final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
      final formattedPhone = phone.startsWith('+') ? phone : '+$cleanDigits';
      await client.auth.signInWithOtp(phone: formattedPhone);
    } catch (e) {
      debugPrint('Error sending Phone OTP: $e');
      rethrow;
    }
  }

  /// Verify Phone OTP via Supabase Auth
  Future<AuthResponse> verifyPhoneOtp(String phone, String token) async {
    try {
      final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
      final formattedPhone = phone.startsWith('+') ? phone : '+$cleanDigits';
      final response = await client.auth.verifyOTP(
        type: OtpType.sms,
        phone: formattedPhone,
        token: token,
      );
      return response;
    } catch (e) {
      debugPrint('Error verifying Phone OTP: $e');
      rethrow;
    }
  }

  /// Create a new driver profile in database
  Future<DriverModel> createDriver(DriverModel driver) async {
    try {
      final data = driver.toJson();
      if (driver.id == null) {
        data.remove('id');
      }

      // Ensure phone stored in DB is formatted with +
      final rawPhone = driver.phone;
      final cleanDigits = rawPhone.replaceAll(RegExp(r'\D'), '');
      if (cleanDigits.isNotEmpty) {
        data['phone'] = rawPhone.startsWith('+') ? rawPhone : '+$cleanDigits';
      }

      final response =
          await client.from('drivers').insert(data).select().single();

      return DriverModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating driver: $e');
      rethrow;
    }
  }

  /// Update Online status of driver
  Future<void> updateOnlineStatus(String driverId, bool isOnline) async {
    try {
      await client.from('drivers').update({
        'is_online': isOnline,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', driverId);
    } catch (e) {
      debugPrint('Error updating online status: $e');
      rethrow;
    }
  }

  /// Update Driver Location (JSON map containing lat/lng)
  Future<void> updateDriverLocation(
    String driverId,
    double lat,
    double lng,
  ) async {
    try {
      final locationJson = {
        'latitude': lat,
        'longitude': lng,
        'lat': lat,
        'lng': lng,
      };
      await client.from('drivers').update({
        'current_location': locationJson,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', driverId);
    } catch (e) {
      debugPrint('Error updating driver location: $e');
      rethrow;
    }
  }

  /// Fetch list of vehicle types from database (with fallback defaults)
  Future<List<VehicleTypeModel>> fetchVehicleTypes() async {
    try {
      final response = await client.from('vehicle_types').select();
      if ((response as List).isNotEmpty) {
        final list = (response as List)
            .map((item) =>
                VehicleTypeModel.fromJson(item as Map<String, dynamic>))
            .toList();
        list.sort((a, b) => a.capacityKg.compareTo(b.capacityKg));
        return list;
      }
    } catch (e) {
      debugPrint(
          'Error fetching vehicle types from DB, using default list: $e');
    }
    return VehicleTypeModel.defaultVehicleTypes;
  }

  /// Save Vehicle details & update driver vehicle status
  Future<VehicleModel> saveVehicle(VehicleModel vehicle) async {
    try {
      final vehicleData = vehicle.toJson();
      if (vehicle.id == null) {
        vehicleData.remove('id');
      }

      final response =
          await client.from('vehicles').insert(vehicleData).select().single();

      await client.from('drivers').update({
        'is_vehicle_added': true,
        'vehicle_number': vehicle.vehicleNumber,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', vehicle.driverId);

      return VehicleModel.fromJson(response);
    } catch (e) {
      debugPrint('Error saving vehicle: $e');
      rethrow;
    }
  }

  /// Get Vehicle for driver
  Future<VehicleModel?> getVehicleByDriverId(String driverId) async {
    try {
      final response = await client
          .from('vehicles')
          .select()
          .eq('driver_id', driverId)
          .maybeSingle();

      if (response == null) return null;
      return VehicleModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting vehicle by driver id: $e');
      rethrow;
    }
  }

  /// Save Document details & update driver document status
  Future<DocumentModel> saveDocuments(DocumentModel document) async {
    try {
      final docData = document.toJson();
      if (document.id == null) {
        docData.remove('id');
      }

      final response =
          await client.from('documents').insert(docData).select().single();

      await client.from('drivers').update({
        'is_documents_uploaded': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', document.driverId);

      return DocumentModel.fromJson(response);
    } catch (e) {
      debugPrint('Error saving documents: $e');
      rethrow;
    }
  }

  /// Get Documents for driver
  Future<DocumentModel?> getDocumentsByDriverId(String driverId) async {
    try {
      final response = await client
          .from('documents')
          .select()
          .eq('driver_id', driverId)
          .maybeSingle();

      if (response == null) return null;
      return DocumentModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting documents: $e');
      rethrow;
    }
  }

  /// Save Bank details & update driver bank status
  Future<BankDetailsModel> saveBankDetails(BankDetailsModel bankDetails) async {
    try {
      final bankData = bankDetails.toJson();
      if (bankDetails.id == null) {
        bankData.remove('id');
      }

      final response =
          await client.from('bank_details').insert(bankData).select().single();

      await client.from('drivers').update({
        'is_bank_details_added': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bankDetails.driverId);

      return BankDetailsModel.fromJson(response);
    } catch (e) {
      debugPrint('Error saving bank details: $e');
      rethrow;
    }
  }

  /// Get Bank Details for driver
  Future<BankDetailsModel?> getBankDetailsByDriverId(String driverId) async {
    try {
      final response = await client
          .from('bank_details')
          .select()
          .eq('driver_id', driverId)
          .maybeSingle();

      if (response == null) return null;
      return BankDetailsModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting bank details: $e');
      rethrow;
    }
  }

  /// Save driver rating & review
  Future<RatingModel> saveRating(RatingModel rating) async {
    try {
      final ratingData = rating.toJson();
      if (rating.id == null) {
        ratingData.remove('id');
      }

      final response = await client
          .from('driver_ratings')
          .insert(ratingData)
          .select()
          .single();

      return RatingModel.fromJson(response);
    } catch (e) {
      debugPrint('Error saving rating: $e');
      rethrow;
    }
  }

  /// Get ratings for a driver using exact .eq filter
  Future<List<RatingModel>> getDriverRatings(String driverId) async {
    try {
      final response = await client
          .from('driver_ratings')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list.map((json) => RatingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting driver ratings: $e');
      rethrow;
    }
  }

  /// Get driver trips from public.bookings using exact .eq filter
  Future<List<BookingModel>> getDriverTrips(String driverId) async {
    try {
      final response = await client
          .from('bookings')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Notice fetching driver trips: $e');
      return [];
    }
  }

  /// Get driver earnings from public.earning table
  Future<List<EarningModel>> getDriverEarnings(String driverId) async {
    try {
      final response = await client
          .from('earning')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list.map((json) => EarningModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Notice fetching driver earnings: $e');
      return [];
    }
  }

  /// Get currently active booking for driver ('accepted', 'arrived', 'in_transit', 'drop_complete', or 'amount_paid')
  Future<BookingModel?> getActiveDriverBooking(String driverId) async {
    try {
      final response = await client
          .from('bookings')
          .select()
          .eq('driver_id', driverId)
          .inFilter('status', [
            'accepted',
            'arrived',
            'in_transit',
            'drop_complete',
            'amount_paid'
          ])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return BookingModel.fromJson(response);
    } catch (e) {
      debugPrint('Notice fetching active driver booking: $e');
      return null;
    }
  }

  /// Get booking details by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await client
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .maybeSingle();

      if (response == null) return null;
      return BookingModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting booking by id: $e');
      return null;
    }
  }

  /// Update booking status in Supabase (e.g., 'arrived', 'in_transit', 'completed', 'cancelled')
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await client.from('bookings').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
    } catch (e) {
      debugPrint('Error updating booking status: $e');
      rethrow;
    }
  }

  /// ATOMIC ACCEPTANCE: Invoke Supabase RPC function accept_booking_request
  Future<Map<String, dynamic>> acceptBookingRequest({
    required String bookingId,
    required String driverId,
  }) async {
    try {
      final response = await client.rpc(
        'accept_booking_request',
        params: {'p_booking_id': bookingId, 'p_driver_id': driverId},
      );
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      debugPrint('Error calling accept_booking_request RPC: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Query active searching bookings (polling fallback)
  Future<List<BookingModel>> getSearchingBookings() async {
    try {
      final response = await client
          .from('bookings')
          .select()
          .eq('status', 'searching')
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Notice querying searching bookings: $e');
      return [];
    }
  }

  /// Realtime Stream subscription to public.bookings table
  Stream<List<BookingModel>> subscribeToBookingsStream() {
    return client.from('bookings').stream(primaryKey: ['id']).map(
      (data) => data.map((json) => BookingModel.fromJson(json)).toList(),
    );
  }

  /// Upload file to specified storage bucket and return public URL
  Future<String> uploadImage({
    required String bucket,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final file = File(filePath);
      final storagePath = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await client.storage.from(bucket).upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = client.storage.from(bucket).getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image to $bucket: $e');
      rethrow;
    }
  }

  /// Record driver payout request
  Future<void> saveDriverPayout({
    required String driverId,
    required double amount,
    required String bankName,
    required String accountNumber,
  }) async {
    try {
      await client.from('driver_payouts').insert({
        'driver_id': driverId,
        'amount': amount,
        'bank_name': bankName,
        'account_number': accountNumber,
        'status': 'processed',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Notice recording driver payout: $e');
    }
  }

  /// Get driver payouts history
  Future<List<Map<String, dynamic>>> getDriverPayouts(String driverId) async {
    try {
      final response = await client
          .from('driver_payouts')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Notice fetching driver payouts: $e');
      return [];
    }
  }

  /// Cancel booking with driver cancellation reason
  Future<void> cancelBookingWithReason({
    required String bookingId,
    required String reason,
  }) async {
    try {
      await client.from('bookings').update({
        'status': 'cancelled',
        'cancellation_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
    } catch (e) {
      debugPrint('Error cancelling booking with reason: $e');
      rethrow;
    }
  }

  /// Upload Proof of Pickup (POP) photo and update booking record
  Future<String> uploadPickupImage({
    required String bookingId,
    required File file,
  }) async {
    try {
      final fileName =
          'pickup_${bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'pickup/$fileName';

      await client.storage.from('documents').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl =
          client.storage.from('documents').getPublicUrl(storagePath);

      await client.from('bookings').update({
        'pickup_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading Pickup image: $e');
      rethrow;
    }
  }

  /// Upload Proof of Delivery (POD) photo and update booking record
  Future<String> uploadPodImage({
    required String bookingId,
    required File file,
  }) async {
    try {
      final fileName =
          'pod_${bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'pod/$fileName';

      await client.storage.from('documents').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl =
          client.storage.from('documents').getPublicUrl(storagePath);

      await client.from('bookings').update({
        'pod_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading POD image: $e');
      rethrow;
    }
  }

  /// Save driver_charges JSON map into public.bookings amount column
  Future<void> saveDriverCharges({
    required String bookingId,
    required Map<String, dynamic> driverCharges,
  }) async {
    try {
      final currentBooking = await getBookingById(bookingId);
      Map<String, dynamic> amountMap = {};

      if (currentBooking?.amount != null) {
        amountMap = Map<String, dynamic>.from(currentBooking!.amount!);
      }

      // Add/Update driver_charges map in amount JSON
      amountMap['driver_charges'] = driverCharges;
      amountMap['total_price'] += driverCharges.values.reduce((a, b) => a + b);

      // Save updated amount map to public.bookings
      await client.from('bookings').update({
        'amount': amountMap,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

      debugPrint(
          '✅ Successfully saved driver_charges to booking #$bookingId: $amountMap');
    } catch (e) {
      debugPrint('Error saving driver_charges: $e');
      rethrow;
    }
  }

  /// Record rating given by driver to customer
  Future<void> submitCustomerRating({
    required String bookingId,
    required String customerId,
    required String driverId,
    required double rating,
    String? comment,
  }) async {
    try {
      await client.from('driver_ratings').insert({
        'driver_id': driverId,
        'trip_id': bookingId,
        'customer_name': 'Customer #$customerId',
        'rating': rating,
        'review_comment': comment ?? 'Rated by Driver',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Notice submitting customer rating: $e');
    }
  }

  /// Save or update FCM token in public.user_fcm_tokens
  Future<void> saveUserFcmToken({
    required String userId,
    required String fcmToken,
    required String type,
    String? device,
  }) async {
    try {
      final nowStr = DateTime.now().toIso8601String();
      await client.from('user_fcm_tokens').upsert(
        {
          'driver_id': userId,
          'fcm_token': fcmToken,
          'type': type,
          'device': device,
          'last_used': nowStr,
          'updated_at': nowStr,
        },
        onConflict: 'fcm_token',
      );
      debugPrint('Successfully saved FCM token to Supabase for user $userId');
    } catch (e) {
      debugPrint('Error saving FCM token to Supabase: $e');
    }
  }

  /// Submit driver bid record into public.bids table
  Future<bool> submitDriverBid({
    required String bookingId,
    required String driverId,
    required double currentRate,
    required double driverBid,
  }) async {
    try {
      final nowStr = DateTime.now().toIso8601String();
      await client.from('bids').insert({
        'booking_id': bookingId,
        'driver_id': driverId,
        'current_booking_rate': currentRate,
        'driver_bid': driverBid,
        'status': 'pending',
        'created_at': nowStr,
        'updated_at': nowStr,
      });
      debugPrint(
          '✅ Bid submitted successfully for booking #$bookingId: ₹$driverBid');
      return true;
    } catch (e) {
      debugPrint('Error submitting driver bid to public.bids: $e');
      rethrow;
    }
  }

  /// Fetch vehicle catalog items from public.vehicle_catalog table
  Future<List<VehicleCatalogModel>> fetchVehicleCatalog() async {
    try {
      final response = await client
          .from('vehicle_catalog')
          .select()
          .order('wheel_count', ascending: true)
          .order('brand', ascending: true);

      final list = (response as List<dynamic>)
          .map((item) =>
              VehicleCatalogModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) return list;
      return VehicleCatalogModel.defaultCatalog;
    } catch (e) {
      debugPrint(
          'Notice fetching vehicle_catalog: $e. Falling back to defaults.');
      return VehicleCatalogModel.defaultCatalog;
    }
  }

  // ==========================================
  // WALLET & DAILY REJECTION SYSTEM METHODS
  // ==========================================

  /// Get driver wallet balance
  Future<DriverWalletModel?> getDriverWallet(String driverId) async {
    try {
      final response = await client
          .from('driver_wallets')
          .select()
          .eq('driver_id', driverId)
          .maybeSingle();

      if (response == null) {
        // Create initial wallet with 0.0 balance if not exists
        final newWallet = await client
            .from('driver_wallets')
            .insert({'driver_id': driverId, 'balance': 0.0})
            .select()
            .single();
        return DriverWalletModel.fromJson(newWallet);
      }
      return DriverWalletModel.fromJson(response);
    } catch (e) {
      debugPrint('Notice getting driver wallet: $e');
      return DriverWalletModel(driverId: driverId, balance: 0.0);
    }
  }

  /// Get wallet transactions history for driver
  Future<List<WalletTransactionModel>> getWalletTransactions(
      String driverId) async {
    try {
      final response = await client
          .from('wallet_transactions')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list.map((json) => WalletTransactionModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Notice getting wallet transactions: $e');
      return [];
    }
  }

  /// Get driver daily status for current date (fee deduction & rejection count)
  Future<DriverDailyStatusModel?> getDriverDailyStatus(String driverId) async {
    try {
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final response = await client
          .from('driver_daily_status')
          .select()
          .eq('driver_id', driverId)
          .eq('status_date', todayStr)
          .maybeSingle();

      if (response == null) return null;
      return DriverDailyStatusModel.fromJson(response);
    } catch (e) {
      debugPrint('Notice getting driver daily status: $e');
      return null;
    }
  }

  /// Invoke RPC function recharge_driver_wallet
  Future<Map<String, dynamic>> rechargeDriverWallet({
    required String driverId,
    required double amount,
  }) async {
    try {
      final response = await client.rpc(
        'recharge_driver_wallet',
        params: {
          'p_driver_id': driverId,
          'p_amount': amount,
        },
      );
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      return {
        'success': false,
        'message': 'Unexpected response from recharge RPC'
      };
    } catch (e) {
      debugPrint('Error invoking recharge_driver_wallet RPC: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Invoke RPC function record_driver_rejection
  Future<Map<String, dynamic>> recordDriverRejection(String driverId) async {
    try {
      final response = await client.rpc(
        'record_driver_rejection',
        params: {'p_driver_id': driverId},
      );
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      return {
        'success': false,
        'message': 'Unexpected response from rejection RPC'
      };
    } catch (e) {
      debugPrint('Error invoking record_driver_rejection RPC: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get notifications for driver from public.driver_notifications
  Future<List<Map<String, dynamic>>> getDriverNotifications(
      String driverId) async {
    try {
      final response = await client
          .from('driver_notifications')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Notice fetching driver notifications: $e');
      return [];
    }
  }
}
