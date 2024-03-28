import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/resource_data.dart';
import 'package:web5/web5.dart';

abstract class Metadata {}

enum ResourceKind {
  offering,
  balance,
  reputation,
}

class ResourceMetadata extends Metadata {
  final ResourceKind kind;
  final String from;
  final String id;
  final String protocol;
  final String createdAt;
  final String? updatedAt;

  ResourceMetadata({
    required this.kind,
    required this.from,
    required this.id,
    required this.protocol,
    required this.createdAt,
    this.updatedAt,
  });

  factory ResourceMetadata.fromJson(Map<String, dynamic> json) {
    return ResourceMetadata(
      kind: ResourceKind.values
          .firstWhere((kind) => kind.toString() == json['kind']),
      from: json['from'],
      id: json['id'],
      protocol: json['protocol'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.toString(),
      'from': from,
      'id': id,
      'protocol': protocol,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

abstract class Resource {
  ResourceMetadata get metadata;
  ResourceData get data;
  String? signature;

  static Future<Resource> parse(String payload) async {
    final jsonMessage = jsonDecode(payload);
    // TODO(ethan-tbd): validate jsonMessage against resource

    // final jsonMessageData = jsonMessage['data'];
    final resourceKind = jsonMessage['metadata']['kind'].toString();
    // TODO(ethan-tbd): validate jsonMessageData against resourceKind

    switch (ResourceKind.values
        .firstWhere((kind) => kind.toString() == resourceKind)) {
      case ResourceKind.offering:
        final offering = Offering.fromJson(jsonMessage);
        await offering.verify();
        return offering;
      case ResourceKind.balance:
      case ResourceKind.reputation:
        throw UnimplementedError();
    }
  }

  Future<void> sign(BearerDid did, {String? keyAlias}) async {
    signature = await Jws.sign(
      did: did,
      payload: _digest(),
      detachedPayload: true,
    );
  }

  Future<void> verify() async {
    final decodedJws = Jws.decode(signature ?? '', detachedPayload: _digest());

    final verificationMethodId = decodedJws.header.kid;
    final parsedDidUrl = Did.parse(verificationMethodId ?? '');

    final signingDid = parsedDidUrl.uri;
    if (signingDid != metadata.from) {
      throw Exception(
        'Signature verification failed: Was not signed by the expected DID',
      );
    }

    await Jws.verify(signature ?? '', detachedPayload: _digest());
  }

  Uint8List _digest() {
    final payload = json.encode({'metadata': metadata, 'data': data});
    final bytes = utf8.encode(payload);
    return Uint8List.fromList(sha256.convert(bytes).bytes);
  }

  @override
  String toString() => jsonEncode(this);
}
