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

  group('Rfq', () {
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
      final json = jsonEncode(rfq.toJson());
      final parsed = await Rfq.parse(json);

      expect(parsed, isA<Rfq>());
      expect(parsed.toString(), equals(json));
    });

    test('can verify rfq with offering', () {
      final offering = TestData.getOffering();
      final rfq = TestData.getRfq(offeringId: offering.metadata.id);
      expect(() => rfq.verifyOfferingRequirements(offering), returnsNormally);
    });

    test('should throw exception if rfq offeringId differs from offering id',
        () {
      final offering = TestData.getOffering();
      final rfq = TestData.getRfq(offeringId: 'fake_offeringId');
      expect(() => rfq.verifyOfferingRequirements(offering), throwsException);
    });

    test(
        'should throw exception if rfq payin amount is greater than offering payin max',
        () {
      final offering = TestData.getOffering();
      final rfq = TestData.getRfq(amount: '100.91');
      expect(() => rfq.verifyOfferingRequirements(offering), throwsException);
    });

    test(
        'should throw exception if rfq payin amount is less than offering payin min',
        () {
      final offering = TestData.getOffering();
      final rfq = TestData.getRfq(amount: '0.00');
      expect(() => rfq.verifyOfferingRequirements(offering), throwsException);
    });

    test(
        'should throw exception if rfq payin kind is not a valid offering payin kind',
        () {
      final offering = TestData.getOffering();
      final rfq = TestData.getRfq(
        offeringId: offering.metadata.id,
        payinKind: 'fake_payinKind',
      );
      expect(() => rfq.verifyOfferingRequirements(offering), throwsException);
    });

    test(
        'should throw exception if rfq payout kind is not a valid offering payin kind',
        () {
      final offering = TestData.getOffering();
      final rfq = TestData.getRfq(
        offeringId: offering.metadata.id,
        payoutKind: 'fake_payoutKind',
      );
      expect(() => rfq.verifyOfferingRequirements(offering), throwsException);
    });
  });
}
