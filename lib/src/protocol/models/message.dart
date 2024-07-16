import 'dart:convert';
import 'dart:typed_data';

import 'package:tbdex/src/protocol/crypto.dart';
import 'package:tbdex/src/protocol/exceptions.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/validator.dart';
import 'package:typeid/typeid.dart';
import 'package:web5/web5.dart';

enum MessageKind {
  rfq,
  quote,
  close,
  cancel,
  order,
  orderstatus,
}

class MessageMetadata extends Metadata {
  final MessageKind kind;
  final String to;
  final String from;
  final String id;
  final String exchangeId;
  final String createdAt;
  final String protocol;
  final String? externalId;

  MessageMetadata({
    required this.kind,
    required this.to,
    required this.from,
    required this.id,
    required this.exchangeId,
    required this.createdAt,
    required this.protocol,
    this.externalId,
  });

  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      kind: MessageKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => throw TbdexParseException(
          TbdexExceptionCode.messageUnknownKind,
          'unknown message kind: ${json['kind']}',
        ),
      ),
      to: json['to'],
      from: json['from'],
      id: json['id'],
      exchangeId: json['exchangeId'],
      createdAt: json['createdAt'],
      protocol: json['protocol'],
      externalId: json['externalId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.name,
      'to': to,
      'from': from,
      'id': id,
      'exchangeId': exchangeId,
      'createdAt': createdAt,
      'protocol': protocol,
      if (externalId != null) 'externalId': externalId,
    };
  }
}

abstract class Message {
  Set<MessageKind> get validNext;
  MessageMetadata get metadata;
  MessageData get data;
  String? signature;

  static String generateId(MessageKind kind) {
    return TypeId.generate(kind.name);
  }

  void validate() {
    Validator.validateMessage(this);
  }

  Future<void> sign(BearerDid did, {String? keyAlias}) async {
    signature = await Jws.sign(
      did: did,
      payload: _digest(),
      detachedPayload: true,
    );
  }

  Future<void> verify() async {
    if (signature == null) {
      throw TbdexSignatureVerificationException(
        TbdexExceptionCode.messageSignatureMissing,
        'signature verification failed: expected signature property to exist',
      );
    }

    final decodedJws = Jws.decode(signature ?? '', detachedPayload: _digest());
    final verificationMethodId = decodedJws.header.kid;
    final parsedDidUrl = Did.parse(verificationMethodId ?? '');
    final signingDid = parsedDidUrl.uri;

    if (signingDid != metadata.from) {
      throw TbdexSignatureVerificationException(
        TbdexExceptionCode.messageSignatureMismatch,
        'signature verification failed: was not signed by the expected DID',
      );
    }

    await decodedJws.verify();
  }

  Uint8List _digest() {
    return CryptoUtils.digest({
      'metadata': metadata.toJson(),
      'data': data.toJson(),
    });
  }

  @override
  String toString() => jsonEncode(this);
}
