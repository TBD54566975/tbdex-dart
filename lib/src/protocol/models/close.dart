import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/parser.dart';

class Close extends Message {
  @override
  final MessageMetadata metadata;
  @override
  final CloseData data;

  @override
  Set<MessageKind> get validNext => {};

  Close._({
    required this.metadata,
    required this.data,
    String? signature,
  }) : super() {
    this.signature = signature;
  }

  static Close create(
    String to,
    String from,
    String exchangeId,
    CloseData data, {
    String? externalId,
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.close,
      to: to,
      from: from,
      id: Message.generateId(MessageKind.close),
      exchangeId: exchangeId,
      createdAt: now,
      protocol: protocol,
      externalId: externalId,
    );

    return Close._(
      metadata: metadata,
      data: data,
    );
  }

  static Future<Close> parse(String rawMessage) async {
    final close = Parser.parseMessage(rawMessage) as Close;
    await close.verify();
    return close;
  }

  factory Close.fromJson(Map<String, dynamic> json) {
    return Close._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: CloseData.fromJson(json['data']),
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
