import 'dart:convert';

import 'package:tbdex/src/protocol/exceptions.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:test/test.dart';
import 'package:typeid/typeid.dart';

import '../../helpers/test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('Rfq', () {
    test('can create a new rfq', () {
      final rfq = Rfq.create(
        TestData.pfi,
        TestData.alice,
        CreateRfqData(
          offeringId: TypeId.generate(ResourceKind.offering.name),
          payin: CreateSelectedPayinMethod(amount: '100', kind: 'BTC_ADDRESS'),
          payout: CreateSelectedPayoutMethod(kind: 'BANK'),
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

    test('can parse and verify rfq from a json string', () async {
      final rfq = TestData.getRfq();
      await rfq.sign(TestData.aliceDid);
      final json = jsonEncode(rfq.toJson());
      final parsed = await Rfq.parse(json);

      expect(parsed, isA<Rfq>());
      expect(parsed.toString(), equals(json));
    });

    group('.parse', () {
      group('requireAllPrivateData = true', () {
        test('succeeds when all privateData is present', () async {
          final rfq = TestData.getRfq();
          await rfq.sign(TestData.aliceDid);
          final json = jsonEncode(rfq.toJson());
          final parsed = await Rfq.parse(json, requireAllPrivateData: true);

          expect(parsed, isA<Rfq>());
          expect(parsed.toString(), equals(json));
        });

        test(
            'throws if private data is missing but hashed fields are present in Rfq.data',
            () async {
          final rfq = TestData.getRfq();
          await rfq.sign(TestData.aliceDid);

          final jsonObject = rfq.toJson();
          jsonObject.remove('privateData');
          final json = jsonEncode(jsonObject);

          expect(
            () async => Rfq.parse(json, requireAllPrivateData: true),
            throwsA(predicate((e) =>
                e is TbdexParseException &&
                e.code == TbdexExceptionCode.rfqPrivateDataMissing)),
          );
        });

        test(
            'throws if salt is missing but hashed fields are present in Rfq.data',
            () async {
          final rfq = TestData.getRfq();
          await rfq.sign(TestData.aliceDid);

          final jsonObject = rfq.toJson();
          (jsonObject['privateData']! as Map<String, dynamic>).remove('salt');
          final json = jsonEncode(jsonObject);

          expect(
            () async => Rfq.parse(json, requireAllPrivateData: true),
            throwsA(predicate((e) =>
                e is TbdexValidatorException &&
                e.code == TbdexExceptionCode.validatorJsonSchemaError)),
          );
        });

        test(
            'throws if Rfq.privateData.payin.paymentDetails is incorrect but Rfq.data.payin.paymentDetailsHash is present',
            () async {
          var rfq = TestData.getRfq();

          var jsonObject = rfq.toJson();
          // ignore: avoid_dynamic_calls
          jsonObject['data']['payin']['paymentDetailsHash'] = 'garbage';
          var rfqWithGarbageHash = Rfq.fromJson(jsonObject);
          await rfqWithGarbageHash.sign(TestData.aliceDid);

          final json = jsonEncode(rfqWithGarbageHash.toJson());

          expect(
            () async => Rfq.parse(json, requireAllPrivateData: true),
            throwsA(predicate((e) =>
                e is TbdexParseException &&
                e.code == TbdexExceptionCode.rfqPayinDetailsHashMismatch)),
          );
        });

        test(
            'throws if Rfq.privateData.payout.paymentDetails is incorrect but Rfq.data.payout.paymentDetailsHash is present',
            () async {
          var rfq = TestData.getRfq();

          var jsonObject = rfq.toJson();
          // ignore: avoid_dynamic_calls
          jsonObject['data']['payout']['paymentDetailsHash'] = 'garbage';
          var rfqWithGarbageHash = Rfq.fromJson(jsonObject);
          await rfqWithGarbageHash.sign(TestData.aliceDid);

          final json = jsonEncode(rfqWithGarbageHash.toJson());

          expect(
            () async => Rfq.parse(json, requireAllPrivateData: true),
            throwsA(predicate((e) =>
                e is TbdexParseException &&
                e.code == TbdexExceptionCode.rfqPayoutDetailsHashMismatch)),
          );
        });

        test(
            'throws if Rfq.privateData.claims is incorrect but Rfq.data.claimsHash is present',
            () async {
          var rfq = TestData.getRfq();

          var jsonObject = rfq.toJson();
          // ignore: avoid_dynamic_calls
          jsonObject['data']['claimsHash'] = 'garbage';
          var rfqWithGarbageHash = Rfq.fromJson(jsonObject);
          await rfqWithGarbageHash.sign(TestData.aliceDid);

          final json = jsonEncode(rfqWithGarbageHash.toJson());

          expect(
            () async => Rfq.parse(json, requireAllPrivateData: true),
            throwsA(predicate((e) =>
                e is TbdexParseException &&
                e.code == TbdexExceptionCode.rfqClaimsHashMismatch)),
          );
        });

        test(
            'throws if Rfq.privateData.payin.paymentDetails is missing but Rfq.data.payin.paymentDetailsHash is present',
            () async {
          var rfq = TestData.getRfq();
          await rfq.sign(TestData.aliceDid);

          var jsonObject = rfq.toJson();
          // ignore: avoid_dynamic_calls
          jsonObject['privateData'].remove('payin');

          final json = jsonEncode(jsonObject);

          expect(
            () async => Rfq.parse(json, requireAllPrivateData: true),
            throwsA(predicate((e) =>
                e is TbdexParseException &&
                e.code == TbdexExceptionCode.rfqPayinDetailsMissing)),
          );
        });

        test(
            'throws if Rfq.privateData.payout.paymentDetails is missing but Rfq.data.payout.paymentDetailsHash is present',
            () async {
          var rfq = TestData.getRfq();
          await rfq.sign(TestData.aliceDid);

          var jsonObject = rfq.toJson();
          // ignore: avoid_dynamic_calls
          jsonObject['privateData'].remove('payout');

          final json = jsonEncode(jsonObject);

          expect(
            () async => Rfq.parse(json, requireAllPrivateData: true),
            throwsA(predicate((e) =>
                e is TbdexParseException &&
                e.code == TbdexExceptionCode.rfqPayoutDetailsMissing)),
          );
        });

        test(
            'throws if Rfq.privateData.claims is missing but Rfq.data.claimsHash is present',
            () async {
          var rfq = TestData.getRfq();
          await rfq.sign(TestData.aliceDid);

          var jsonObject = rfq.toJson();
          // ignore: avoid_dynamic_calls
          jsonObject['privateData'].remove('claims');

          final json = jsonEncode(jsonObject);

          expect(
            () async => Rfq.parse(json, requireAllPrivateData: true),
            throwsA(predicate((e) =>
                e is TbdexParseException &&
                e.code == TbdexExceptionCode.rfqClaimsMissing)),
          );
        });
      });

      group('requireAllPrivateData = false', () {
        test(
            'throws if salt is missing but private fields are present in privateData',
            () async {
          final rfq = TestData.getRfq();
          await rfq.sign(TestData.aliceDid);

          final jsonObject = rfq.toJson();
          (jsonObject['privateData']! as Map<String, dynamic>).remove('salt');
          final json = jsonEncode(jsonObject);

          expect(
            () async =>
                Rfq.parse(json), // requireAllPrivateData = false by default
            throwsA(predicate((e) =>
                e is TbdexValidatorException &&
                e.code == TbdexExceptionCode.validatorJsonSchemaError)),
          );
        });

        test(
            'throws if Rfq.privateData.payin.paymentDetails is incorrect but Rfq.data.payin.paymentDetailsHash is present',
            () async {
          var rfq = TestData.getRfq();

          var jsonObject = rfq.toJson();
          // ignore: avoid_dynamic_calls
          jsonObject['data']['payin']['paymentDetailsHash'] = 'garbage';
          var rfqWithGarbageHash = Rfq.fromJson(jsonObject);
          await rfqWithGarbageHash.sign(TestData.aliceDid);

          final json = jsonEncode(rfqWithGarbageHash.toJson());

          expect(
            () async =>
                Rfq.parse(json), // requireAllPrivateData = false by default
            throwsA(predicate((e) =>
                e is TbdexParseException &&
                e.code == TbdexExceptionCode.rfqPayinDetailsHashMismatch)),
          );
        });

        test(
            'throws if Rfq.privateData.payout.paymentDetails is incorrect but Rfq.data.payout.paymentDetailsHash is present',
            () async {
          var rfq = TestData.getRfq();

          var jsonObject = rfq.toJson();
          // ignore: avoid_dynamic_calls
          jsonObject['data']['payout']['paymentDetailsHash'] = 'garbage';
          var rfqWithGarbageHash = Rfq.fromJson(jsonObject);
          await rfqWithGarbageHash.sign(TestData.aliceDid);

          final json = jsonEncode(rfqWithGarbageHash.toJson());

          expect(
            () async =>
                Rfq.parse(json), // requireAllPrivateData = false by default
            throwsA(predicate((e) =>
                e is TbdexParseException &&
                e.code == TbdexExceptionCode.rfqPayoutDetailsHashMismatch)),
          );
        });

        test(
            'throws if Rfq.privateData.claims is incorrect but Rfq.data.claimsHash is present',
            () async {
          var rfq = TestData.getRfq();

          var jsonObject = rfq.toJson();
          // ignore: avoid_dynamic_calls
          jsonObject['data']['claimsHash'] = 'garbage';
          var rfqWithGarbageHash = Rfq.fromJson(jsonObject);
          await rfqWithGarbageHash.sign(TestData.aliceDid);

          final json = jsonEncode(rfqWithGarbageHash.toJson());

          expect(
            () async =>
                Rfq.parse(json), // requireAllPrivateData = false by default
            throwsA(predicate((e) =>
                e is TbdexParseException &&
                e.code == TbdexExceptionCode.rfqClaimsHashMismatch)),
          );
        });
      });
    });

    test('can verify offering requirements', () {
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
