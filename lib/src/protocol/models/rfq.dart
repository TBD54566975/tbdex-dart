import 'package:decimal/decimal.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/parser.dart';

class Rfq extends Message {
  @override
  final MessageMetadata metadata;
  @override
  final RfqData data;

  @override
  Set<MessageKind> get validNext => {MessageKind.quote, MessageKind.close};

  Rfq._({
    required this.metadata,
    required this.data,
    String? signature,
  }) : super() {
    this.signature = signature;
  }

  static Rfq create(
    String to,
    String from,
    RfqData data, {
    String? externalId,
    String protocol = '1.0',
  }) {
    final id = Message.generateId(MessageKind.rfq);
    final now = DateTime.now().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.rfq,
      to: to,
      from: from,
      id: id,
      exchangeId: id,
      createdAt: now,
      protocol: protocol,
      externalId: externalId,
    );

    return Rfq._(
      metadata: metadata,
      data: data,
    );
  }

  static Future<Rfq> parse(String rawMessage) async {
    final rfq = Parser.parseRawMessage(rawMessage) as Rfq;
    await rfq.verify();
    return rfq;
  }

  void verifyOfferingRequirements(Offering offering) {
    if (metadata.protocol != offering.metadata.protocol) {
      throw Exception(
        'protocol version mismatch: ${offering.metadata.protocol} != ${metadata.protocol}',
      );
    }

    if (data.offeringId != offering.metadata.id) {
      throw Exception(
        'offering id mismatch: ${offering.metadata.id} != ${data.offeringId}',
      );
    }

    if (offering.data.payin.min != null) {
      if (Decimal.parse(data.payin.amount) <
          Decimal.parse(offering.data.payin.min ?? '')) {
        throw Exception(
          'payin amount is less than the minimum required amount',
        );
      }
    }

    if (offering.data.payin.max != null) {
      if (Decimal.parse(data.payin.amount) >
          Decimal.parse(offering.data.payin.max ?? '')) {
        throw Exception(
          'payin amount is greater than the maximum allowed amount',
        );
      }
    }

    final payinMethod = offering.data.payin.methods.firstWhere(
      (method) => method.kind == data.payin.kind,
      orElse: () =>
          throw Exception('unknown offering kind: ${data.payin.kind}'),
    );

    final payinSchema = payinMethod.getRequiredPaymentDetailsSchema();
    if (payinSchema != null) {
      payinSchema.validate(data.payin.paymentDetails);
    }

    final payoutMethod = offering.data.payout.methods.firstWhere(
      (method) => method.kind == data.payout.kind,
      orElse: () =>
          throw Exception('unknown offering kind: ${data.payout.kind}'),
    );

    final payoutSchema = payoutMethod.getRequiredPaymentDetailsSchema();
    if (payoutSchema != null) {
      payoutSchema.validate(data.payout.paymentDetails);
    }

    // TODO(ethan-tbd): verify claims
    // offering.data.requiredClaims?.forEach(verifyClaims);
  }

  factory Rfq.fromJson(Map<String, dynamic> json) {
    return Rfq._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: RfqData.fromJson(json['data']),
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
