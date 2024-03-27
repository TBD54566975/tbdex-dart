import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';

class Quote extends Message {
  @override
  final MessageMetadata metadata;
  @override
  final QuoteData data;

  @override
  Set<MessageKind> get validNext => {MessageKind.order, MessageKind.close};

  Quote._({
    required this.metadata,
    required this.data,
  });

  static Quote create(
    String to,
    String from,
    String exchangeId,
    QuoteData data,
    String? externalId, {
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.quote,
      to: to,
      from: from,
      id: 'quote_id',
      exchangeId: exchangeId,
      createdAt: now,
      protocol: protocol,
      externalId: externalId,
    );

    return Quote._(
      metadata: metadata,
      data: data,
    );
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: QuoteData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'data': data.toJson(),
    };
  }
}
