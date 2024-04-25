import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:test/test.dart';

void main() async {
  await TestVectors.initialize();

  group('TestVectorsTest', () {
    test('can parse offering test vector', () async {
      final json = TestVectors.getVector('offering');
      print(json['input']);

      final parsed = await Offering.parse(json['input']);

      expect(parsed, isA<Offering>());
      expect(parsed.toString(), equals(json));
    });

    test('can parse rfq test vector', () async {
      final json = TestVectors.getVector('rfq');
      print(json['input']);

      final parsed = await Rfq.parse(json['input']);

      expect(parsed, isA<Rfq>());
      expect(parsed.toString(), equals(json));
    });
  });
}

class TestVectors {
  static final Map<String, dynamic> _vectorMap = {};

  static Future<void> initialize() async {
    final vectorsPath =
        p.join('tbdex', 'hosted', 'test-vectors', 'protocol', 'vectors');

    final vectorFiles = {
      'close': 'parse-close.json',
      'offering': 'parse-offering.json',
      'order': 'parse-order.json',
      'orderstatus': 'parse-orderstatus.json',
      'quote': 'parse-quote.json',
      'rfq': 'parse-rfq.json',
    };

    for (final entry in vectorFiles.entries) {
      final filePath = p.join(vectorsPath, entry.value);
      final vectorJsonString = await File(filePath).readAsString();
      // TODO: no need to decode json if parse takes a raw string
      final vectorJson = jsonDecode(vectorJsonString);

      _vectorMap[entry.key] = vectorJson;
    }
  }

  static dynamic getVector(String vectorName) =>
      _vectorMap[vectorName] ??
      (throw Exception('no vector with name $vectorName exists'));
}
