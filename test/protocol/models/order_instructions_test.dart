import 'dart:convert';

import 'package:tbdex/src/protocol/models/order_instructions.dart';
import 'package:tbdex/tbdex.dart';
import 'package:test/test.dart';
import 'package:typeid/typeid.dart';

import '../../helpers/test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('OrderInstructions', () {
    test('can create a new order instruction', () {
      final orderInstructions = OrderInstructions.create(
        TestData.pfi,
        TestData.alice,
        TypeId.generate(MessageKind.rfq.name),
        OrderInstructionsData(
          payin: PaymentInstruction(instruction: 'just do it'),
          payout: PaymentInstruction(instruction: 'just receive it'),
        ),
      );

      expect(
        orderInstructions.metadata.id,
        startsWith(MessageKind.orderinstructions.name),
      );
      expect(
        orderInstructions.metadata.kind,
        equals(MessageKind.orderinstructions),
      );
      expect(orderInstructions.metadata.protocol, equals('1.0'));
      expect(orderInstructions.data.payin.instruction, equals('just do it'));
      expect(
        orderInstructions.data.payout.instruction,
        equals('just receive it'),
      );
    });

    test('can parse and verify order instructions from a json string',
        () async {
      final orderInstructions = TestData.getOrderInstructions();
      await orderInstructions.sign(TestData.pfiDid);
      final json = jsonEncode(orderInstructions.toJson());
      final parsed = await OrderInstructions.parse(json);

      expect(parsed, isA<OrderInstructions>());
      expect(parsed.toString(), equals(json));
    });
  });
}
