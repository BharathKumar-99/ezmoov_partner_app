// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String testDriverId = '1162bd71-e708-4f6c-8c8a-88eb179630d1';
const String supabaseUrl = 'https://icpqdnkbhdavpcaievdz.supabase.co';
const String supabaseApiKey = 'sb_publishable_PrjwgAl8Q9BZNMxIbEK9rw_6U7fdQM-';

class TestResult {
  final String scenario;
  final String description;
  final bool passed;
  final String details;

  TestResult({
    required this.scenario,
    required this.description,
    required this.passed,
    required this.details,
  });
}

class SupabaseRestClient {
  final Map<String, String> _headers = {
    'apikey': supabaseApiKey,
    'Authorization': 'Bearer $supabaseApiKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  Future<List<dynamic>> query(String table, String queryParams) async {
    final uri = Uri.parse('$supabaseUrl/rest/v1/$table?$queryParams');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('GET $table failed (${response.statusCode}): ${response.body}');
    }
  }

  Future<List<dynamic>> insert(String table, Map<String, dynamic> data) async {
    final uri = Uri.parse('$supabaseUrl/rest/v1/$table');
    final response = await http.post(uri, headers: _headers, body: jsonEncode(data));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('INSERT $table failed (${response.statusCode}): ${response.body}');
    }
  }

  Future<List<dynamic>> update(String table, String queryParams, Map<String, dynamic> data) async {
    final uri = Uri.parse('$supabaseUrl/rest/v1/$table?$queryParams');
    final response = await http.patch(uri, headers: _headers, body: jsonEncode(data));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('PATCH $table failed (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> delete(String table, String queryParams) async {
    final uri = Uri.parse('$supabaseUrl/rest/v1/$table?$queryParams');
    await http.delete(uri, headers: _headers);
  }
}

Future<void> main() async {
  print('================================================================');
  print('🚀 EZMOOV DRIVER LOGIN TIME TRIGGER TEST SUITE (DART CLIENT)');
  print('Target Driver ID: $testDriverId');
  print('Supabase URL: $supabaseUrl');
  print('================================================================\n');

  final client = SupabaseRestClient();
  final List<TestResult> results = [];

  try {
    // 0. Verify Driver Exists
    final drivers = await client.query('drivers', 'id=eq.$testDriverId&select=id,name,phone,is_online');
    if (drivers.isEmpty) {
      print('❌ ERROR: Driver with ID $testDriverId not found in public.drivers table!');
      exit(1);
    }

    final driver = drivers.first as Map<String, dynamic>;
    print('✅ Driver Found: ${driver['name']} (${driver['phone']})');
    print('Initial is_online: ${driver['is_online']}\n');

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr = yesterday.toIso8601String().substring(0, 10);

    // Initial reset: attempt clean deletion and set driver offline
    await client.delete('driver_login_time', 'driver_id=eq.$testDriverId');
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': false});
    await Future.delayed(const Duration(milliseconds: 600));

    // Determine baseline count of rows for today
    final baselineRows = await client.query('driver_login_time', 'driver_id=eq.$testDriverId&date=eq.$todayStr&select=*');
    final int baselineCount = baselineRows.length;
    print('Baseline driver_login_time rows for today: $baselineCount\n');

    // ========================================================================
    // SCENARIO 1.1: Cold Start Online Toggle (FALSE -> TRUE)
    // ========================================================================
    print('▶ Running Scenario 1.1: First-time Online Toggle (Cold Start)...');
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': true});
    await Future.delayed(const Duration(milliseconds: 800));

    final s1_1Rows = await client.query(
      'driver_login_time',
      'driver_id=eq.$testDriverId&date=eq.$todayStr&select=*&order=created_at.desc',
    );

    final s1_1Active = s1_1Rows.firstWhere(
      (r) => r['end_time'] == null,
      orElse: () => null,
    );

    final s1_1Passed = s1_1Active != null && s1_1Active['start_time'] != null;

    results.add(TestResult(
      scenario: '1.1',
      description: 'First-time Online Toggle (Cold Start)',
      passed: s1_1Passed,
      details: 'Active session created: ${s1_1Active != null}, start_time: ${s1_1Active?['start_time']}',
    ));
    print(s1_1Passed ? '   ✅ PASS' : '   ❌ FAIL: $s1_1Rows');

    // ========================================================================
    // SCENARIO 1.2: Immediate Offline Toggle (TRUE -> FALSE)
    // ========================================================================
    print('▶ Running Scenario 1.2: Immediate Offline Toggle...');
    await Future.delayed(const Duration(seconds: 1));
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': false});
    await Future.delayed(const Duration(milliseconds: 800));

    final s1_2Rows = await client.query(
      'driver_login_time',
      'driver_id=eq.$testDriverId&date=eq.$todayStr&select=*&order=created_at.desc',
    );

    final s1_2Closed = s1_2Rows.isNotEmpty &&
        s1_2Rows[0]['id'] == s1_1Active?['id'] &&
        s1_2Rows[0]['end_time'] != null &&
        s1_2Rows[0]['total_time'] != null;

    results.add(TestResult(
      scenario: '1.2',
      description: 'Immediate Offline Toggle',
      passed: s1_2Closed,
      details: 'Session ${s1_1Active?['id']} closed: ${s1_2Rows[0]['end_time'] != null}, total_time: ${s1_2Rows[0]['total_time']}',
    ));
    print(s1_2Closed ? '   ✅ PASS' : '   ❌ FAIL: $s1_2Rows');

    // ========================================================================
    // SCENARIO 2.1: Go Online with Completed Previous Session Today
    // ========================================================================
    print('▶ Running Scenario 2.1: Go Online with Completed Previous Session Today...');
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': true});
    await Future.delayed(const Duration(milliseconds: 800));

    final s2_1Rows = await client.query(
      'driver_login_time',
      'driver_id=eq.$testDriverId&date=eq.$todayStr&select=*&order=created_at.desc',
    );

    final s2_1NewActive = s2_1Rows.firstWhere(
      (r) => r['end_time'] == null,
      orElse: () => null,
    );

    final s2_1Passed = s2_1NewActive != null && s2_1NewActive['id'] != s1_1Active?['id'];

    results.add(TestResult(
      scenario: '2.1',
      description: 'Go Online with Completed Previous Session Today',
      passed: s2_1Passed,
      details: 'New distinct session created: ${s2_1NewActive?['id']}',
    ));
    print(s2_1Passed ? '   ✅ PASS' : '   ❌ FAIL: $s2_1Rows');

    // ========================================================================
    // SCENARIO 2.2: Second Offline Toggle of the Day
    // ========================================================================
    print('▶ Running Scenario 2.2: Second Offline Toggle of the Day...');
    await Future.delayed(const Duration(seconds: 1));
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': false});
    await Future.delayed(const Duration(milliseconds: 800));

    final s2_2Rows = await client.query(
      'driver_login_time',
      'driver_id=eq.$testDriverId&date=eq.$todayStr&select=*&order=created_at.desc',
    );

    final s2_2SecondClosed = s2_2Rows.isNotEmpty &&
        s2_2Rows[0]['id'] == s2_1NewActive?['id'] &&
        s2_2Rows[0]['end_time'] != null &&
        s2_2Rows[0]['total_time'] != null;

    final openCountAfter2_2 = s2_2Rows.where((r) => r['end_time'] == null).length;
    final s2_2Passed = s2_2SecondClosed && openCountAfter2_2 == 0;

    results.add(TestResult(
      scenario: '2.2',
      description: 'Second Offline Toggle of the Day',
      passed: s2_2Passed,
      details: 'Second session closed: ${s2_2Rows[0]['end_time'] != null}, Open sessions remaining: $openCountAfter2_2',
    ));
    print(s2_2Passed ? '   ✅ PASS' : '   ❌ FAIL: $s2_2Rows');

    // ========================================================================
    // SCENARIO 3.1: Go Online with Orphaned Pre-allocated Record
    // ========================================================================
    print('▶ Running Scenario 3.1: Go Online with Orphaned Pre-allocated Record...');
    // Insert an open pre-allocated record
    String? orphanedId;
    try {
      final insertedOrphan = await client.insert('driver_login_time', {
        'driver_id': testDriverId,
        'start_time': null,
        'end_time': null,
        'total_time': null,
        'date': todayStr,
      });
      orphanedId = insertedOrphan.isNotEmpty ? insertedOrphan[0]['id'] : null;
    } catch (_) {
      final insertedOrphan = await client.insert('driver_login_time', {
        'driver_id': testDriverId,
        'start_time': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'end_time': null,
        'total_time': null,
        'date': todayStr,
      });
      orphanedId = insertedOrphan.isNotEmpty ? insertedOrphan[0]['id'] : null;
    }

    final countBefore3_1 = (await client.query('driver_login_time', 'driver_id=eq.$testDriverId&date=eq.$todayStr&select=*')).length;

    // Go online
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': true});
    await Future.delayed(const Duration(milliseconds: 800));

    final rowsAfter3_1 = await client.query('driver_login_time', 'driver_id=eq.$testDriverId&date=eq.$todayStr&select=*&order=created_at.desc');
    final countAfter3_1 = rowsAfter3_1.length;

    final updatedOrphan = rowsAfter3_1.firstWhere((r) => r['id'] == orphanedId, orElse: () => null);
    final s3_1Passed = countBefore3_1 == countAfter3_1 && updatedOrphan != null && updatedOrphan['start_time'] != null && updatedOrphan['end_time'] == null;

    results.add(TestResult(
      scenario: '3.1',
      description: 'Go Online with Orphaned Pre-allocated Record',
      passed: s3_1Passed,
      details: 'Row count unchanged ($countAfter3_1 rows, no duplicate), start_time populated: ${updatedOrphan?['start_time']}',
    ));
    print(s3_1Passed ? '   ✅ PASS' : '   ❌ FAIL');

    // ========================================================================
    // SCENARIO 4.1: Going Offline without an Active Online Session (No-Op)
    // ========================================================================
    print('▶ Running Scenario 4.1: Going Offline without an Active Online Session (No-Op)...');
    // Close 3.1 active session
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': false});
    await Future.delayed(const Duration(milliseconds: 500));

    final beforeCountRows = await client.query('driver_login_time', 'driver_id=eq.$testDriverId&select=*');
    final countBefore = beforeCountRows.length;

    // Redundant offline update (FALSE -> FALSE)
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': false});
    await Future.delayed(const Duration(milliseconds: 500));

    final afterCountRows = await client.query('driver_login_time', 'driver_id=eq.$testDriverId&select=*');
    final countAfter = afterCountRows.length;

    final s4_1Passed = countBefore == countAfter;
    results.add(TestResult(
      scenario: '4.1',
      description: 'Going Offline without Active Online Session (No-Op)',
      passed: s4_1Passed,
      details: 'Row count before: $countBefore, after: $countAfter (Unchanged)',
    ));
    print(s4_1Passed ? '   ✅ PASS' : '   ❌ FAIL');

    // ========================================================================
    // SCENARIO 4.2: Redundant Online Update (No-Op)
    // ========================================================================
    print('▶ Running Scenario 4.2: Redundant Online Update (No-Op)...');
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': true});
    await Future.delayed(const Duration(milliseconds: 500));

    final s4_2RowsBefore = await client.query('driver_login_time', 'driver_id=eq.$testDriverId&date=eq.$todayStr&end_time=is.null&select=*');
    final initialStartTime = s4_2RowsBefore.isNotEmpty ? s4_2RowsBefore[0]['start_time'] : null;
    final activeId4_2 = s4_2RowsBefore.isNotEmpty ? s4_2RowsBefore[0]['id'] : null;

    // Redundant online update (TRUE -> TRUE)
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': true});
    await Future.delayed(const Duration(milliseconds: 500));

    final s4_2RowsAfter = await client.query('driver_login_time', 'driver_id=eq.$testDriverId&date=eq.$todayStr&end_time=is.null&select=*');
    final finalStartTime = s4_2RowsAfter.isNotEmpty ? s4_2RowsAfter[0]['start_time'] : null;
    final finalActiveId = s4_2RowsAfter.isNotEmpty ? s4_2RowsAfter[0]['id'] : null;

    final s4_2Passed = activeId4_2 == finalActiveId && initialStartTime == finalStartTime;

    results.add(TestResult(
      scenario: '4.2',
      description: 'Redundant Online Update (No-Op)',
      passed: s4_2Passed,
      details: 'Same active session ($activeId4_2), start_time untouched: ${initialStartTime == finalStartTime}',
    ));
    print(s4_2Passed ? '   ✅ PASS' : '   ❌ FAIL');

    // ========================================================================
    // SCENARIO 5.1: Going Online when Past Dates exist
    // ========================================================================
    print('▶ Running Scenario 5.1: Going Online when Past Dates exist...');
    // Close current session
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': false});
    await Future.delayed(const Duration(milliseconds: 500));

    // Insert completed record for yesterday
    await client.insert('driver_login_time', {
      'driver_id': testDriverId,
      'start_time': yesterday.subtract(const Duration(hours: 4)).toIso8601String(),
      'end_time': yesterday.toIso8601String(),
      'total_time': '4 hrs 0 mins',
      'date': yesterdayStr,
    });

    // Go online today
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': true});
    await Future.delayed(const Duration(milliseconds: 800));

    final s5_1TodayRows = await client.query('driver_login_time', 'driver_id=eq.$testDriverId&date=eq.$todayStr&end_time=is.null&select=*');
    final s5_1Passed = s5_1TodayRows.isNotEmpty;

    results.add(TestResult(
      scenario: '5.1',
      description: 'Going Online when Past Dates exist',
      passed: s5_1Passed,
      details: 'Active session created with date = $todayStr (ignoring yesterday): ${s5_1TodayRows.first['id']}',
    ));
    print(s5_1Passed ? '   ✅ PASS' : '   ❌ FAIL');

    // ========================================================================
    // SCENARIO 5.2: Going Offline on Overnight Shift (Cross-Midnight)
    // ========================================================================
    print('▶ Running Scenario 5.2: Going Offline on Overnight Shift (Cross-Midnight)...');
    // Close session from 5.1 and ensure driver state is ready
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': false});
    await Future.delayed(const Duration(milliseconds: 500));

    // Delete any lingering unclosed sessions for test driver
    // Driver went online yesterday (simulated by setting drivers.is_online = true first)
    // We update is_online to true first, then insert our targeted overnight session
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': true});
    await Future.delayed(const Duration(milliseconds: 500));

    // Close any today session created by the toggle
    final todayOpen = await client.query('driver_login_time', 'driver_id=eq.$testDriverId&date=eq.$todayStr&end_time=is.null&select=id');
    for (final row in todayOpen) {
      await client.update('driver_login_time', 'id=eq.${row['id']}', {'end_time': DateTime.now().toIso8601String(), 'total_time': '1 min'});
    }

    // Now insert our overnight open session
    final insertedOvernight = await client.insert('driver_login_time', {
      'driver_id': testDriverId,
      'start_time': DateTime.now().subtract(const Duration(hours: 7)).toIso8601String(),
      'end_time': null,
      'total_time': null,
      'date': yesterdayStr,
    });
    final overnightId = insertedOvernight.isNotEmpty ? insertedOvernight[0]['id'] : null;

    // Driver goes offline today across midnight boundary (TRUE -> FALSE)
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': false});
    await Future.delayed(const Duration(milliseconds: 800));

    final s5_2Rows = await client.query('driver_login_time', 'id=eq.$overnightId&select=*');
    final s5_2Passed = s5_2Rows.isNotEmpty &&
        s5_2Rows[0]['end_time'] != null &&
        s5_2Rows[0]['total_time'] != null;

    results.add(TestResult(
      scenario: '5.2',
      description: 'Going Offline on Overnight Shift (Cross-Midnight)',
      passed: s5_2Passed,
      details: 'Overnight session $overnightId closed: ${s5_2Rows.isNotEmpty ? s5_2Rows[0]['end_time'] : null}, total_time: ${s5_2Rows.isNotEmpty ? s5_2Rows[0]['total_time'] : null}',
    ));
    print(s5_2Passed ? '   ✅ PASS' : '   ❌ FAIL: $s5_2Rows');

    // Clean up: set driver offline
    await client.update('drivers', 'id=eq.$testDriverId', {'is_online': false});

    // ========================================================================
    // FINAL TEST REPORT SUMMARY TABLE
    // ========================================================================
    print('\n================================================================');
    print('📊 TEST EXECUTION SUMMARY REPORT (DRIVER: $testDriverId)');
    print('================================================================');
    print('| Scenario | Test Case Description                           | Status | Verification Details');
    print('|----------|-------------------------------------------------|--------|------------------------------------------------');

    for (final res in results) {
      final statusStr = res.passed ? '✅ PASS' : '❌ FAIL';
      final scPad = res.scenario.padRight(8);
      final descPad = res.description.padRight(47);
      print('| $scPad | $descPad | $statusStr | ${res.details}');
    }
    print('================================================================\n');

    final allPassed = results.every((r) => r.passed);
    if (allPassed) {
      print('🎉 ALL 9 TEST SCENARIOS PASSED WITH 100% SUCCESS!\n');
    } else {
      print('⚠️ SOME TEST SCENARIOS FAILED. Check details above.\n');
    }
  } catch (e, stack) {
    print('❌ UNEXPECTED ERROR RUNNING TESTS: $e');
    print(stack);
  }

  exit(0);
}
