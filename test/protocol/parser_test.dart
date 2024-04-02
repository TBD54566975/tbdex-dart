import 'dart:convert';

import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:tbdex/src/protocol/parser.dart';
import 'package:test/test.dart';

import '../test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('ParserTest', () {
    test('can parse a list of messages', () async {
      final rfq = TestData.getRfq();
      final order = TestData.getOrder();

      final messages = await Future.wait(
        [
          jsonEncode(rfq.toJson()),
          jsonEncode(order.toJson()),
        ].map((jsonString) async => Parser.parseRawMessage(jsonString)),
      );

      expect(messages.first, isA<Rfq>());
      expect(messages.last, isA<Order>());
    });

    test('parse throws error if json string is not valid', () {
      expect(
        () => Parser.parseRawMessage(';;;;'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
