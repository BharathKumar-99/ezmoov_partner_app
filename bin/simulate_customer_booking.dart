// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const supabaseUrl = 'https://icpqdnkbhdavpcaievdz.supabase.co';
  const supabaseApiKey = 'sb_publishable_PrjwgAl8Q9BZNMxIbEK9rw_6U7fdQM-';

  print('=====================================================');
  print('🚀 EZMOOV CUSTOMER BOOKING SIMULATION SCRIPT');
  print('=====================================================');
  print('Creating a test booking request in Supabase...\n');

  final endpoint = Uri.parse('$supabaseUrl/rest/v1/bookings');

  final payload = {
    'customer_id': 'cust_test_101',
    'pickup_address': 'Indiranagar 100ft Road, Bengaluru',
    'drop_address': 'MG Road Metro Station, Bengaluru',
    'pickup_lat': 12.9716,
    'pickup_lng': 77.5946,
    'drop_lat': 12.9756,
    'drop_lng': 77.6066,
    'status': 'searching',
    'fare': 345.00,
    'otp': '4825',
    'created_at': DateTime.now().toIso8601String(),
  };

  try {
    final response = await http.post(
      endpoint,
      headers: {
        'apikey': supabaseApiKey,
        'Authorization': 'Bearer $supabaseApiKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('✅ SUCCESS! Booking request created successfully in Supabase:');
      print(const JsonEncoder.withIndent('  ').convert(responseData));
      print(
        '\n⚡ The Partner (Driver) App should now trigger the Incoming Ride Pop-Up modal!',
      );
    } else {
      print('❌ ERROR creating booking: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (e) {
    print('❌ EXCEPTION: $e');
  }

  exit(0);
}
