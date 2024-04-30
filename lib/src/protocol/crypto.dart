import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:tbdex/src/protocol/jcs.dart';
import 'package:web5/web5.dart';

class CryptoUtils {
  static Uint8List digest(Object value) {
    final canonicalized = JsonCanonicalizer.canonicalize(value);
    final digest = sha256.convert(canonicalized);

    return Uint8List.fromList(digest.bytes);
  }

  static String generateSalt() {
    var random = Random.secure();
    var bytes =
        Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
    return Base64Url.encode(bytes);
  }
}
