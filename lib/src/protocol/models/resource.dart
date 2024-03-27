import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/resource_data.dart';
import 'package:web5/web5.dart';

abstract class Metadata {}

enum ResourceKind {
  offering,
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
      kind: ResourceKind.values.firstWhere((e) => e.toString() == json['kind']),
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

  static Resource parse(String payload) {
    final json = jsonDecode(payload);
    // final dataJson = json['data'];
    final kind = json['metadata']['kind'].toString();
    switch (ResourceKind.values.firstWhere((e) => e.toString() == kind)) {
      case ResourceKind.offering:
        final offering = Offering.fromJson(json);
        offering.verify();
        return offering;
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
    // TODO(ethan-tbd): figure out how to verify
    await Jws.verify(signature ?? '');
  }

  Uint8List _digest() {
    final payload = json.encode({'metadata': metadata, 'data': data});
    final bytes = utf8.encode(payload);
    return Uint8List.fromList(sha256.convert(bytes).bytes);
  }

  @override
  String toString() => jsonEncode(this);
}
