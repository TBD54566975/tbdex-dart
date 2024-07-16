import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/parser.dart';

class Cancel extends Message {
  @override
  final MessageMetadata metadata;
  @override
  final CancelData data;

  @override
  Set<MessageKind> get validNext => {};

  Cancel._({
    required this.metadata,
    required this.data,
    String? signature,
  }) : super() {
    this.signature = signature;
  }

  static Cancel create(
    String to,
    String from,
    String exchangeId,
    CancelData data, {
    String? externalId,
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.cancel,
      to: to,
      from: from,
      id: Message.generateId(MessageKind.cancel),
      exchangeId: exchangeId,
      createdAt: now,
      protocol: protocol,
      externalId: externalId,
    );

    return Cancel._(
      metadata: metadata,
      data: data,
    );
  }

  static Future<Cancel> parse(String rawMessage) async {
    final cancel = Parser.parseMessage(rawMessage) as Cancel;
    await cancel.verify();
    return cancel;
  }

  factory Cancel.fromJson(Map<String, dynamic> json) {
    return Cancel._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: CancelData.fromJson(json['data']),
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
