import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/parser.dart';

class OrderStatus extends Message {
  @override
  final MessageMetadata metadata;
  @override
  final OrderStatusData data;

  @override
  Set<MessageKind> get validNext =>
      {MessageKind.orderstatus, MessageKind.close};

  OrderStatus._({
    required this.metadata,
    required this.data,
    String? signature,
  }) : super() {
    this.signature = signature;
  }

  static OrderStatus create(
    String to,
    String from,
    String exchangeId,
    OrderStatusData data, {
    String? externalId,
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.orderstatus,
      to: to,
      from: from,
      id: Message.generateId(MessageKind.orderstatus),
      exchangeId: exchangeId,
      createdAt: now,
      protocol: protocol,
      externalId: externalId,
    );

    return OrderStatus._(
      metadata: metadata,
      data: data,
    );
  }

  static Future<OrderStatus> parse(String rawMessage) async {
    final orderStatus = Parser.parseMessage(rawMessage) as OrderStatus;
    await orderStatus.verify();
    return orderStatus;
  }

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: OrderStatusData.fromJson(json['data']),
      signature: json['signature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'data': data.toJson(),
      'signature': signature,
    };
  }
}
