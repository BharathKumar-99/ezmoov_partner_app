import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/core/services/in_app_update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InAppUpdateService Tests', () {
    test('InAppUpdateService singleton instance exists', () {
      final service1 = InAppUpdateService.instance;
      final service2 = InAppUpdateService.instance;

      expect(service1, isNotNull);
      expect(service1, same(service2));
    });

    test('checkForUpdateAndPerform handles test/non-android environment gracefully without throw', () async {
      final service = InAppUpdateService.instance;
      final result = await service.checkForUpdateAndPerform();

      // On non-android/test platforms, checkForUpdateAndPerform gracefully returns false
      expect(result, isFalse);
    });
  });
}
