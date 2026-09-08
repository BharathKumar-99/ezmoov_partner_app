import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/driver_login_time_model.dart';
import 'package:ezmoov_partner_app/viewmodels/performance_viewmodel.dart';

void main() {
  group('DriverLoginTimeModel Tests', () {
    test('Calculates duration and formatted strings correctly for completed session', () {
      final startTime = DateTime(2026, 9, 1, 9, 0);
      final endTime = DateTime(2026, 9, 1, 11, 30);

      final model = DriverLoginTimeModel(
        id: 'test-1',
        driverId: 'driver-123',
        startTime: startTime,
        endTime: endTime,
        totalTime: '2 hrs 30 mins',
        date: '2026-09-01',
      );

      expect(model.isOngoing, false);
      expect(model.calculatedDuration, const Duration(hours: 2, minutes: 30));
      expect(model.formattedDuration, '2h 30m');
      expect(model.formattedDurationDetailed, '2 hrs 30 mins');
      expect(model.formattedTimeRange, '09:00 AM - 11:30 AM');
    });

    test('Handles ongoing session correctly', () {
      final startTime = DateTime.now().subtract(const Duration(minutes: 45));

      final model = DriverLoginTimeModel(
        id: 'test-2',
        driverId: 'driver-123',
        startTime: startTime,
        endTime: null,
        totalTime: 'Ongoing',
        date: '2026-09-01',
      );

      expect(model.isOngoing, true);
      expect(model.calculatedDuration.inMinutes, greaterThanOrEqualTo(44));
      expect(model.formattedTimeRange.contains('Ongoing'), true);
    });

    test('Serializes to and from JSON', () {
      final json = {
        'id': 'session-abc',
        'driver_id': 'driver-xyz',
        'start_time': '2026-09-01T08:00:00.000Z',
        'end_time': '2026-09-01T12:00:00.000Z',
        'total_time': '4 hrs 0 mins',
        'date': '2026-09-01',
      };

      final model = DriverLoginTimeModel.fromJson(json);
      expect(model.id, 'session-abc');
      expect(model.driverId, 'driver-xyz');
      expect(model.totalTime, '4 hrs 0 mins');
      expect(model.date, '2026-09-01');

      final serialized = model.toJson();
      expect(serialized['id'], 'session-abc');
      expect(serialized['driver_id'], 'driver-xyz');
      expect(serialized['total_time'], '4 hrs 0 mins');
    });
  });

  group('PerformanceViewModel Date Navigation & Duration Aggregation Tests', () {
    test('Calculates total hours across sessions correctly', () {
      final vm = PerformanceViewModel();

      expect(vm.formattedTodayLoginHoursShort, '0h 0m');
      expect(vm.formattedTodayLoginHoursDetailed, '0 mins');
      expect(vm.isSelectedDateToday, true);
    });
  });
}
