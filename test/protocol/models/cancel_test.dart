import 'dart:convert';

import 'package:tbdex/src/protocol/models/cancel.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/tbdex.dart';
import 'package:test/test.dart';
import 'package:typeid/typeid.dart';

import '../../helpers/test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('Cancel', () {
    test('can create a new cancel', () {
      final cancel = Cancel.create(
        TestData.pfi,
        TestData.alice,
        TypeId.generate(MessageKind.cancel.name),
        CancelData(reason: 'my reason'),
      );

      expect(cancel.metadata.id, startsWith(MessageKind.cancel.name));
      expect(cancel.metadata.kind, equals(MessageKind.cancel));
      expect(cancel.metadata.protocol, equals('1.0'));
      expect(cancel.data.reason, equals('my reason'));
    });

    test('can parse and verify cancel from a json string', () async {
      final cancel = TestData.getCancel();
      await cancel.sign(TestData.aliceDid);
      final json = jsonEncode(cancel.toJson());
      final parsed = await Cancel.parse(json);

      expect(parsed, isA<Cancel>());
      expect(parsed.toString(), equals(json));
    });
  });
}
