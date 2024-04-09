import 'dart:convert';

import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:tbdex/src/protocol/parser.dart';
import 'package:test/test.dart';

import '../test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('Parser', () {
    test('can parse a list of messages', () async {
      final rfq = TestData.getRfq();
      await rfq.sign(TestData.aliceDid);
      final order = TestData.getOrder();
      await order.sign(TestData.aliceDid);

      final messages = await Future.wait(
        [
          jsonEncode(rfq.toJson()),
          jsonEncode(order.toJson()),
        ].map((jsonString) async => Parser.parseMessage(jsonString)),
      );

      expect(messages.first, isA<Rfq>());
      expect(messages.last, isA<Order>());
    });

    test('parse throws error if json string is not valid', () {
      expect(
        () => Parser.parseMessage(';;;;'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
