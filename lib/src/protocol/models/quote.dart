import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/parser.dart';

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
    String? signature,
  }) : super() {
    this.signature = signature;
  }

  static Quote create(
    String to,
    String from,
    String exchangeId,
    QuoteData data, {
    String? externalId,
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.quote,
      to: to,
      from: from,
      id: Message.generateId(MessageKind.quote),
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

  static Future<Quote> parse(String rawMessage) async {
    final quote = Parser.parseMessage(rawMessage) as Quote;
    await quote.verify();
    return quote;
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: QuoteData.fromJson(json['data']),
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
