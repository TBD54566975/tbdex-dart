import 'dart:convert';

import 'package:tbdex/src/protocol/models/close.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:test/test.dart';
import 'package:typeid/typeid.dart';

import '../../test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('CloseTest', () {
    test('can create a new close', () {
      final close = Close.create(
        TestData.pfi,
        TestData.alice,
        TypeId.generate(MessageKind.rfq.name),
        CloseData(reason: 'my reason'),
      );

      expect(close.metadata.id, startsWith('close'));
      expect(close.metadata.protocol, equals('1.0'));
      expect(close.data.reason, equals('my reason'));
    });

    test('can parse close from a json string', () async {
      final close = TestData.getClose();
      await close.sign(TestData.pfiDid);
      final jsonResource = jsonEncode(close.toJson());
      final parsed = await Message.parse(jsonResource);

      expect(parsed, isA<Close>());
      expect(parsed.toString(), equals(jsonResource));
    });
  });
}
