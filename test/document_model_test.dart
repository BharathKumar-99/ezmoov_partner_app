import 'package:flutter_test/flutter_test.dart';
import 'package:ezmoov_partner_app/models/document_model.dart';

void main() {
  group('DocumentModel serialization & deserialization tests', () {
    test('fromJson correctly parses dl_back_url and rc_back_url', () {
      final json = {
        'id': 'doc-123',
        'driver_id': 'driver-456',
        'aadhaar_url': 'https://storage/aadhaar.jpg',
        'driving_license_url': 'https://storage/dl.jpg',
        'dl_back_url': 'https://storage/dl_back.jpg',
        'vehicle_rc_url': 'https://storage/rc.jpg',
        'rc_back_url': 'https://storage/rc_back.jpg',
        'pan_card_url': 'https://storage/pan.jpg',
        'insurance_url': 'https://storage/insurance.jpg',
        'puc_url': 'https://storage/puc.jpg',
        'permit_url': 'https://storage/permit.jpg',
        'fitness_url': 'https://storage/fitness.jpg',
        'police_clearance_url': 'https://storage/police.jpg',
        'selfie_with_vehicle_url': 'https://storage/selfie.jpg',
        'status': 'approved',
        'created_at': '2026-09-15T12:00:00.000Z',
        'updated_at': '2026-09-15T12:30:00.000Z',
      };

      final doc = DocumentModel.fromJson(json);

      expect(doc.id, 'doc-123');
      expect(doc.driverId, 'driver-456');
      expect(doc.drivingLicenseUrl, 'https://storage/dl.jpg');
      expect(doc.dlBackUrl, 'https://storage/dl_back.jpg');
      expect(doc.vehicleRcUrl, 'https://storage/rc.jpg');
      expect(doc.rcBackUrl, 'https://storage/rc_back.jpg');
      expect(doc.status, 'approved');
      expect(doc.createdAt, DateTime.parse('2026-09-15T12:00:00.000Z'));
    });

    test('fromJson falls back to dl_back and rc_back column names', () {
      final json = {
        'id': 'doc-789',
        'driver_id': 'driver-456',
        'dl_back': 'https://storage/dl_back_alt.jpg',
        'rc_back': 'https://storage/rc_back_alt.jpg',
      };

      final doc = DocumentModel.fromJson(json);

      expect(doc.dlBackUrl, 'https://storage/dl_back_alt.jpg');
      expect(doc.rcBackUrl, 'https://storage/rc_back_alt.jpg');
    });

    test('toJson produces correct map with dl_back_url and rc_back_url', () {
      final doc = DocumentModel(
        id: 'doc-123',
        driverId: 'driver-456',
        aadhaarUrl: 'https://storage/aadhaar.jpg',
        drivingLicenseUrl: 'https://storage/dl.jpg',
        dlBackUrl: 'https://storage/dl_back.jpg',
        vehicleRcUrl: 'https://storage/rc.jpg',
        rcBackUrl: 'https://storage/rc_back.jpg',
        panCardUrl: 'https://storage/pan.jpg',
        insuranceUrl: 'https://storage/insurance.jpg',
        pucUrl: 'https://storage/puc.jpg',
        permitUrl: 'https://storage/permit.jpg',
        fitnessUrl: 'https://storage/fitness.jpg',
        policeClearanceUrl: 'https://storage/police.jpg',
        selfieWithVehicleUrl: 'https://storage/selfie.jpg',
        status: 'pending',
      );

      final json = doc.toJson();

      expect(json['id'], 'doc-123');
      expect(json['driver_id'], 'driver-456');
      expect(json['driving_license_url'], 'https://storage/dl.jpg');
      expect(json['dl_back_url'], 'https://storage/dl_back.jpg');
      expect(json['vehicle_rc_url'], 'https://storage/rc.jpg');
      expect(json['rc_back_url'], 'https://storage/rc_back.jpg');
      expect(json['status'], 'pending');
    });
  });
}
