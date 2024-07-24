import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/parser.dart';

class OrderInstructions extends Message {
  @override
  final MessageMetadata metadata;
  @override
  final OrderInstructionsData data;

  @override
  Set<MessageKind> get validNext =>
      {MessageKind.orderstatus, MessageKind.close, MessageKind.cancel};

  OrderInstructions._({
    required this.metadata,
    required this.data,
    String? signature,
  }) : super() {
    this.signature = signature;
  }

  static OrderInstructions create(
    String to,
    String from,
    String exchangeId,
    OrderInstructionsData data, {
    String? externalId,
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.orderinstructions,
      to: to,
      from: from,
      id: Message.generateId(MessageKind.orderinstructions),
      exchangeId: exchangeId,
      createdAt: now,
      protocol: protocol,
      externalId: externalId,
    );

    return OrderInstructions._(
      metadata: metadata,
      data: data,
    );
  }

  static Future<OrderInstructions> parse(String rawMessage) async {
    final orderStatus = Parser.parseMessage(rawMessage) as OrderInstructions;
    await orderStatus.verify();
    return orderStatus;
  }

  factory OrderInstructions.fromJson(Map<String, dynamic> json) {
    return OrderInstructions._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: OrderInstructionsData.fromJson(json['data']),
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
