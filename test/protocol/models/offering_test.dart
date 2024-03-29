import 'dart:convert';

import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/models/resource_data.dart';
import 'package:test/test.dart';

import '../../test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('OfferingTest', () {
    test('can create a new offering', () {
      final offering = Offering.create(
        TestData.pfi,
        OfferingData(
          description: 'my fake offering',
          payoutUnitsPerPayinUnit: '1',
          payin: PayinDetails(currencyCode: 'AUD', methods: []),
          payout: PayoutDetails(currencyCode: 'BTC', methods: []),
        ),
      );

      expect(offering.metadata.id, startsWith(ResourceKind.offering.name));
      expect(offering.metadata.kind, equals(ResourceKind.offering));
      expect(offering.metadata.protocol, equals('1.0'));
      expect(offering.data.description, equals('my fake offering'));
    });

    test('can parse offering from a json string', () async {
      final offering = TestData.getOffering();
      await offering.sign(TestData.pfiDid);
      final jsonResource = jsonEncode(offering.toJson());
      final parsed = await Resource.parse(jsonResource);

      expect(parsed, isA<Offering>());
      expect(parsed.toString(), equals(jsonResource));
    });

    // TODO(ethan-tbd): do we want explicit parsing?
    test('can parse an offering explicitly', () async {
      final offering = TestData.getOffering();
      await offering.sign(TestData.pfiDid);
      final jsonResource = jsonEncode(offering.toJson());
      final parsedOffering = await Offering.parse(jsonResource);

      expect(parsedOffering, isA<Offering>());
    });
  });
}
