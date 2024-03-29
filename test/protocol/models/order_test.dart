import 'dart:convert';

import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/order.dart';
import 'package:test/test.dart';
import 'package:typeid/typeid.dart';

import '../../test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('OrderTest', () {
    test('can create a new order', () {
      final order = Order.create(
        TestData.pfi,
        TestData.alice,
        TypeId.generate(MessageKind.rfq.name),
      );

      expect(order.metadata.id, startsWith(MessageKind.order.name));
      expect(order.metadata.kind, equals(MessageKind.order));
      expect(order.metadata.protocol, equals('1.0'));
    });

    test('can parse order from a json string', () async {
      final order = TestData.getOrder();
      await order.sign(TestData.pfiDid);
      final jsonResource = jsonEncode(order.toJson());
      final parsed = await Message.parse(jsonResource);

      expect(parsed, isA<Order>());
      expect(parsed.toString(), equals(jsonResource));
    });
  });
}
