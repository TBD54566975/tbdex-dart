import 'dart:convert';

import 'package:tbdex/tbdex.dart';
import 'package:test/test.dart';

import '../../helpers/test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('Balance', () {
    test('can create a new balance', () {
      final offering = Balance.create(
        TestData.pfi,
        BalanceData(
          currencyCode: 'USD',
          available: '100.00',
        ),
      );

      expect(offering.metadata.id, startsWith(ResourceKind.balance.name));
      expect(offering.metadata.kind, equals(ResourceKind.balance));
      expect(offering.metadata.protocol, equals('1.0'));
      expect(offering.data.currencyCode, equals('USD'));
      expect(offering.data.available, equals('100.00'));
    });

    test('can parse and verify balance from a json string', () async {
      final balance = TestData.getBalance();
      await balance.sign(TestData.pfiDid);
      final json = jsonEncode(balance.toJson());
      final parsed = await Balance.parse(json);

      expect(parsed, isA<Balance>());
      expect(parsed.toString(), equals(json));
    });
  });
}
