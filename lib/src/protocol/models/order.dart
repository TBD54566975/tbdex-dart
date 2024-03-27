import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';

class Order extends Message {
  @override
  final MessageMetadata metadata;
  @override
  final OrderData data;

  @override
  Set<MessageKind> get validNext => {MessageKind.orderstatus};

  Order._({
    required this.metadata,
    required this.data,
  });

  static Order create(
    String to,
    String from,
    String exchangeId,
    OrderData data,
    String? externalId, {
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.order,
      to: to,
      from: from,
      id: 'order_id',
      exchangeId: exchangeId,
      createdAt: now,
      protocol: protocol,
      externalId: externalId,
    );

    return Order._(
      metadata: metadata,
      data: data,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: OrderData(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'data': '',
    };
  }
}
