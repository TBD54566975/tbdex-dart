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
      kind: MessageKind.values.firstWhere((e) => e.toString() == json['kind']),
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

  static Message parse(String payload) {
    final json = jsonDecode(payload);
    // final dataJson = json['data'];
    final kind = json['metadata']['kind'].toString();
    switch (MessageKind.values.firstWhere((e) => e.toString() == kind)) {
      case MessageKind.rfq:
        final rfq = Rfq.fromJson(json);
        rfq.verify();
        return Rfq.fromJson(json);
      case MessageKind.quote:
        final quote = Quote.fromJson(json);
        quote.verify();
        return Quote.fromJson(json);
      case MessageKind.close:
        final close = Close.fromJson(json);
        close.verify();
        return Close.fromJson(json);
      case MessageKind.order:
        final order = Order.fromJson(json);
        order.verify();
        return Order.fromJson(json);
      case MessageKind.orderstatus:
        final orderStatus = OrderStatus.fromJson(json);
        orderStatus.verify();
        return OrderStatus.fromJson(json);
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
    // await Jws.verify(signature ?? '');
  }

  Uint8List _digest() {
    final payload = json.encode({'metadata': metadata, 'data': data});
    final bytes = utf8.encode(payload);
    return Uint8List.fromList(sha256.convert(bytes).bytes);
  }

  @override
  String toString() => jsonEncode(this);
}
