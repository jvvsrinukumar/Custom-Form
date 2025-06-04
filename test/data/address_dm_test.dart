import 'package:custom_form/core/data/address_dm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressData Model Tests', () {
    test('Construction with all fields', () {
      const address = AddressData(
        id: '1',
        address: '123 Test St',
        city: 'Testville',
        zipCode: '12345',
        state: 'TS',
        landmark: 'Near Test Park',
      );

      expect(address.id, '1');
      expect(address.address, '123 Test St');
      expect(address.city, 'Testville');
      expect(address.zipCode, '12345');
      expect(address.state, 'TS');
      expect(address.landmark, 'Near Test Park');
    });

    test('Construction with landmark as null', () {
      const address = AddressData(
        id: '2',
        address: '456 Another Ave',
        city: 'Sample City',
        zipCode: '67890',
        state: 'SC',
        // landmark is optional, so not provided here
      );

      expect(address.id, '2');
      expect(address.address, '456 Another Ave');
      expect(address.city, 'Sample City');
      expect(address.zipCode, '67890');
      expect(address.state, 'SC');
      expect(address.landmark, isNull);
    });
  });
}
