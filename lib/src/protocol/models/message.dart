import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:tbdex/src/protocol/models/close.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/order_status.dart';
import 'package:tbdex/src/protocol/models/quote.dart';
import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:web5/web5.dart';

enum MessageKind {
  rfq,
  quote,
  close,
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
      kind: MessageKind.values
          .firstWhere((kind) => kind.toString() == json['kind']),
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
      'kind': kind.toString(),
      'to': to,
      'from': from,
      'id': id,
      'exchangeId': exchangeId,
      'createdAt': createdAt,
      'protocol': protocol,
      'externalId': externalId,
    };
  }
}

abstract class Message {
  Set<MessageKind> get validNext;
  MessageMetadata get metadata;
  MessageData get data;
  String? signature;

  static Future<Message> parse(String payload) async {
    final jsonMessage = jsonDecode(payload);
    // TODO(ethan-tbd): validate jsonMessage against message

    // final jsonMessageData = jsonMessage['data'];
    final messageKind = jsonMessage['metadata']['kind'].toString();
    // TODO(ethan-tbd): validate jsonMessageData against messageKind

    switch (MessageKind.values
        .firstWhere((kind) => kind.toString() == messageKind)) {
      case MessageKind.rfq:
        final rfq = Rfq.fromJson(jsonMessage);
        await rfq.verify();
        return Rfq.fromJson(jsonMessage);
      case MessageKind.quote:
        final quote = Quote.fromJson(jsonMessage);
        await quote.verify();
        return Quote.fromJson(jsonMessage);
      case MessageKind.close:
        final close = Close.fromJson(jsonMessage);
        await close.verify();
        return Close.fromJson(jsonMessage);
      case MessageKind.order:
        final order = Order.fromJson(jsonMessage);
        await order.verify();
        return Order.fromJson(jsonMessage);
      case MessageKind.orderstatus:
        final orderStatus = OrderStatus.fromJson(jsonMessage);
        await orderStatus.verify();
        return OrderStatus.fromJson(jsonMessage);
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
    if (signature == null) {
      throw Exception(
        'signature verification failed: expected signature property to exist',
      );
    }
    final decodedJws = Jws.decode(signature ?? '', detachedPayload: _digest());

    final verificationMethodId = decodedJws.header.kid;
    final parsedDidUrl = Did.parse(verificationMethodId ?? '');

    final signingDid = parsedDidUrl.uri;
    if (signingDid != metadata.from) {
      throw Exception(
        'signature verification failed: was not signed by the expected DID',
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
