import 'dart:convert';
import 'package:tbdex/src/protocol/jcs.dart';
import 'package:test/test.dart';

void main() {
  group('JsonCanonicalizer', () {
    test('empty array', () {
      final result = JsonCanonicalizer.canonicalize([]);
      expect(utf8.decode(result), equals('[]'));
    });

    test('one element array', () {
      final result = JsonCanonicalizer.canonicalize([123]);
      expect(utf8.decode(result), equals('[123]'));
    });

    test('multi element array', () {
      final result = JsonCanonicalizer.canonicalize([123, 456, 'hello']);
      expect(utf8.decode(result), equals('[123,456,"hello"]'));
    });

    test('null and undefined values in array', () {
      final result = JsonCanonicalizer.canonicalize([null, null, 'hello']);
      expect(utf8.decode(result), equals('[null,null,"hello"]'));
    });

    test('object in array', () {
      final result = JsonCanonicalizer.canonicalize([
        {'b': 123, 'a': 'string'}
      ]);
      expect(utf8.decode(result), equals('[{"a":"string","b":123}]'));
    });

    test('empty object', () {
      final result = JsonCanonicalizer.canonicalize({});
      expect(utf8.decode(result), equals('{}'));
    });

    test('object with one property', () {
      final result = JsonCanonicalizer.canonicalize({'hello': 'world'});
      expect(utf8.decode(result), equals('{"hello":"world"}'));
    });

    test('object with more than one property', () {
      final result =
          JsonCanonicalizer.canonicalize({'hello': 'world', 'number': 123});
      expect(utf8.decode(result), equals('{"hello":"world","number":123}'));
    });

    test('null', () {
      final result = JsonCanonicalizer.canonicalize(null);
      expect(utf8.decode(result), equals('null'));
    });

    test('object with number key', () {
      expect(
        () => JsonCanonicalizer.canonicalize({42: 'foo'}),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });

    test('object with a function', () {
      var customObject = {
        'a': 123,
        'b': 456,
        'toJSON': () => {'b': 456, 'a': 123},
      };

      expect(
        () => JsonCanonicalizer.canonicalize(customObject),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });

    // Handling error cases
    test('NaN in array', () {
      expect(
        () => JsonCanonicalizer.canonicalize([double.nan]),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });

    test('Infinity in array', () {
      expect(
        () => JsonCanonicalizer.canonicalize([double.infinity]),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });
  });
}
