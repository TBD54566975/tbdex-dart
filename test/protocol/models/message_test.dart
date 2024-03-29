import 'dart:convert';

import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:test/test.dart';

import '../../test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('Message Test', () {
    test('can parse a list of messages', () async {
      final rfq = TestData.getRfq();
      await rfq.sign(TestData.aliceDid);
      final order = TestData.getOrder();
      await order.sign(TestData.pfiDid);

      final messages = await Future.wait(
        [
          jsonEncode(rfq.toJson()),
          jsonEncode(order.toJson()),
        ].map((jsonString) async => Message.parse(jsonString)),
      );

      expect(messages.first, isA<Rfq>());
      expect(messages.last, isA<Order>());
    });

    test('sign populates message signature', () async {
      final rfq = TestData.getRfq();
      await rfq.sign(TestData.pfiDid);

      expect(rfq.signature, isNotNull);
    });

    test('parse throws error if json string is not valid', () async {
      await expectLater(
        Message.parse(';;;;'),
        throwsA(isA<FormatException>()),
      );
    });

    test('messages must be signed by the sender', () async {
      final rfqFromAlice = TestData.getRfq();
      // Sign it with the wrong DID
      await rfqFromAlice.sign(TestData.pfiDid);

      await expectLater(
        Message.parse(jsonEncode(rfqFromAlice.toJson())),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'signature verification',
            contains(
              'signature verification failed: was not signed by the expected DID',
            ),
          ),
        ),
      );
    });
  });
}
