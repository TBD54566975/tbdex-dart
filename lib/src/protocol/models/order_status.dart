import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';

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
  });

  static OrderStatus create(
    String to,
    String from,
    String exchangeId,
    OrderStatusData data,
    String? externalId, {
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.quote,
      to: to,
      from: from,
      id: 'order_status_id',
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

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: OrderStatusData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'data': data.toJson(),
    };
  }
}
