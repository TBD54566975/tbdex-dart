import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:web5/web5.dart';

class CryptoUtils {
  static Uint8List digest(Object value) {
    final payload = json.encode(value);
    final bytes = utf8.encode(payload);
    return Uint8List.fromList(sha256.convert(bytes).bytes);
  }

  static String generateSalt() {
    var random = Random.secure();
    var bytes = Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
    return Base64Url.encode(bytes);
  }
}