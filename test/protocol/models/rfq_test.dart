import 'dart:convert';

import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:test/test.dart';
import 'package:typeid/typeid.dart';

import '../../test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('RfqTest', () {
    test('can create a new rfq', () {
      final rfq = Rfq.create(
        TestData.pfi,
        TestData.alice,
        RfqData(
          offeringId: TypeId.generate(ResourceKind.offering.name),
          payin: SelectedPayinMethod(amount: '100', kind: 'BTC_ADDRESS'),
          payout: SelectedPayoutMethod(kind: 'BANK'),
          claims: [],
        ),
        externalId: 'rfq_id',
      );

      expect(rfq.metadata.id, startsWith(MessageKind.rfq.name));
      expect(rfq.metadata.kind, equals(MessageKind.rfq));
      expect(rfq.metadata.protocol, equals('1.0'));
      expect(rfq.metadata.externalId, equals('rfq_id'));
      expect(rfq.data.payin.amount, equals('100'));
    });

    test('can parse rfq from a json string', () async {
      final rfq = TestData.getRfq();
      await rfq.sign(TestData.aliceDid);
      final jsonResource = jsonEncode(rfq.toJson());
      final parsed = await Message.parse(jsonResource);

      expect(parsed, isA<Rfq>());
      expect(parsed.toString(), equals(jsonResource));
    });
  });
}
