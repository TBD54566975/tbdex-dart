import 'package:tbdex/src/protocol/models/message.dart';
import 'package:test/test.dart';

import '../../helpers/test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('Message', () {
    test('can generate message type ids', () {
      final rfqId = Message.generateId(MessageKind.rfq);
      expect(rfqId, startsWith(MessageKind.rfq.name));

      final quoteId = Message.generateId(MessageKind.quote);
      expect(quoteId, startsWith(MessageKind.quote.name));

      final orderId = Message.generateId(MessageKind.order);
      expect(orderId, startsWith(MessageKind.order.name));

      final orderStatusId = Message.generateId(MessageKind.orderstatus);
      expect(orderStatusId, startsWith(MessageKind.orderstatus.name));

      final closeId = Message.generateId(MessageKind.close);
      expect(closeId, startsWith(MessageKind.close.name));
    });

    test('sign populates message signature', () async {
      final rfq = TestData.getRfq();
      await rfq.sign(TestData.pfiDid);

      expect(rfq.signature, isNotNull);

      final order = TestData.getOrder();
      await order.sign(TestData.aliceDid);

      print(order);
    });

    test('messages must be signed by the sender', () async {
      final rfqFromAlice = TestData.getRfq();
      // Sign it with the wrong DID
      await rfqFromAlice.sign(TestData.pfiDid);

      await expectLater(
        rfqFromAlice.verify(),
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
