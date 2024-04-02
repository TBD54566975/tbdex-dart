import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/parser.dart';

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
    String? signature,
  }) : super() {
    this.signature = signature;
  }

  static Order create(
    String to,
    String from,
    String exchangeId, {
    String? externalId,
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.order,
      to: to,
      from: from,
      id: Message.generateId(MessageKind.order),
      exchangeId: exchangeId,
      createdAt: now,
      protocol: protocol,
      externalId: externalId,
    );

    return Order._(
      metadata: metadata,
      data: OrderData(),
    );
  }

  static Future<Order> parse(String rawMessage) async {
    final order = Parser.parseRawMessage(rawMessage) as Order;
    await order.verify();
    return order;
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: OrderData(),
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
