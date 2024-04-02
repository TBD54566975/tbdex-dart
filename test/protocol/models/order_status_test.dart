import 'dart:convert';

import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/order_status.dart';
import 'package:test/test.dart';
import 'package:typeid/typeid.dart';

import '../../test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('OrderStatusTest', () {
    test('can create a new order status', () {
      final orderStatus = OrderStatus.create(
        TestData.pfi,
        TestData.alice,
        TypeId.generate(MessageKind.rfq.name),
        OrderStatusData(orderStatus: 'my status'),
      );

      expect(orderStatus.metadata.id, startsWith(MessageKind.orderstatus.name));
      expect(orderStatus.metadata.kind, equals(MessageKind.orderstatus));
      expect(orderStatus.metadata.protocol, equals('1.0'));
      expect(orderStatus.data.orderStatus, equals('my status'));
    });

    test('can parse order status from a json string', () async {
      final orderStatus = TestData.getOrderStatus();
      await orderStatus.sign(TestData.pfiDid);
      final json = jsonEncode(orderStatus.toJson());
      final parsed = await OrderStatus.parse(json);

      expect(parsed, isA<OrderStatus>());
      expect(parsed.toString(), equals(json));
    });
  });
}
