import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:typeid/typeid.dart';

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
    final now = DateTime.now().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.rfq,
      to: to,
      from: from,
      id: TypeId.generate(MessageKind.rfq.name),
      exchangeId: TypeId.generate(MessageKind.rfq.name),
      createdAt: now,
      protocol: protocol,
      externalId: externalId,
    );

    return Rfq._(
      metadata: metadata,
      data: data,
    );
  }

  void verifyOfferingRequirements(Offering offering) {
    if (data.offeringId != offering.metadata.id) {
      throw ArgumentError('offering id does not match');
    }

    // if (offering.data.payinCurrency.minAmount != null) {
    //   if (offering.data.payinCurrency.minAmount > data.payinAmount) {
    //     throw Exception('The payin amount is less than the minimum required amount.');
    //   }
    // }

    // if (offering.data.payinCurrency.maxAmount != null) {
    //   if (data.payinAmount > offering.data.payinCurrency.maxAmount!) {
    //     throw Exception('The payin amount exceeds the maximum allowed amount.');
    //   }
    // }

    final payinMethod = offering.data.payin.methods
        .firstWhere((method) => method.kind == data.payin.kind);

    final payinSchema = payinMethod.getRequiredPaymentDetailsSchema();
    if (payinSchema != null) {
      payinSchema.validate(data.payin.paymentDetails);
    }

    final payoutMethod = offering.data.payout.methods
        .firstWhere((method) => method.kind == data.payout.kind);

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
