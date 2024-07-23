import 'dart:convert';
import 'dart:typed_data';

// TODO(ethan-tbd): turn into standalone lib

/// Implements the JSON Canonicalization Scheme specified in
/// [RFC8785](https://www.rfc-editor.org/rfc/rfc8785)
class JsonCanonicalizer {
  /// canonicalizes the provided input per
  /// [RFC8785](https://www.rfc-editor.org/rfc/rfc8785)
  static Uint8List canonicalize(Object? input, {StringBuffer? buffer}) {
    //! this weird line is here to catch any non json encodable types (e.g. fn)
    //! and error out if any are present. this could also be checked per term
    //! (key and value) during canonicalization. refactor to per term if/when
    //! we make this a standalone lib
    final o = jsonDecode(jsonEncode(input));

    final sb = buffer ?? StringBuffer();
    _canonicalize(o, sb);

    return utf8.encode(sb.toString());
  }

  static void _canonicalize(Object? o, StringBuffer sb) {
    if (o == null || o is num || o is bool || o is String) {
      _writePrimitive(o, sb);
    } else if (o is List) {
      _writeList(o, sb);
    } else if (o is Map) {
      _writeMap(o, sb);
    }
  }

  /// Writes a primitive value to the `StringBuffer`.
  static void _writePrimitive(Object? value, StringBuffer sb) {
    sb.write(json.encode(value));
  }

  /// Writes a list to the `StringBuffer` using recursive serialization for elements.
  static void _writeList(List<dynamic> list, StringBuffer sb) {
    sb.write('[');
    var isFirst = true;

    for (final item in list) {
      if (!isFirst) {
        sb.write(',');
      }

      _canonicalize(item, sb);
      isFirst = false;
    }
    sb.write(']');
  }

  /// Writes a map to the `StringBuffer` after sorting its keys.
  static void _writeMap(Map<dynamic, dynamic> map, StringBuffer sb) {
    sb.write('{');
    final keys = List<dynamic>.from(map.keys)..sort();

    var isFirst = true;
    for (final key in keys) {
      if (!isFirst) {
        sb.write(',');
      }

      var keyStr = key;
      if (key is! String) {
        keyStr = key.toString();
      }

      sb.write('${json.encode(keyStr)}:');
      _canonicalize(map[key], sb);
      isFirst = false;
    }

    sb.write('}');
  }
}
