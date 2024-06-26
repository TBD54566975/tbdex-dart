import 'dart:convert';

import 'package:tbdex/src/protocol/models/close.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:test/test.dart';
import 'package:typeid/typeid.dart';

import '../../helpers/test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('Close', () {
    test('can create a new close', () {
      final close = Close.create(
        TestData.pfi,
        TestData.alice,
        TypeId.generate(MessageKind.rfq.name),
        CloseData(reason: 'my reason'),
      );

      expect(close.metadata.id, startsWith(MessageKind.close.name));
      expect(close.metadata.kind, equals(MessageKind.close));
      expect(close.metadata.protocol, equals('1.0'));
      expect(close.data.reason, equals('my reason'));
    });

    test('can parse and verify close from a json string', () async {
      final close = TestData.getClose();
      await close.sign(TestData.aliceDid);
      final json = jsonEncode(close.toJson());
      final parsed = await Close.parse(json);

      expect(parsed, isA<Close>());
      expect(parsed.toString(), equals(json));
    });
  });
}
