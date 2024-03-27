import 'dart:convert';

import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/offering.dart';

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
  });

  static Rfq create(
    String to,
    String from,
    RfqData data,
    String? externalId, {
    String protocol = '1.0',
  }) {
    final now = DateTime.now().toIso8601String();
    final metadata = MessageMetadata(
      kind: MessageKind.rfq,
      to: to,
      from: from,
      id: 'rfq_id',
      exchangeId: 'rfq_id',
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
      throw ArgumentError('The offering ID does not match.');
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

    // validatePaymentMethod(data.payinMethod, offering.data.payin.methods);
    // validatePaymentMethod(data.payoutMethod, offering.data.payout.methods);

    // TODO(ethan-tbd): verify claims
    // offering.data.requiredClaims?.forEach(verifyClaims);
  }

  // void validatePaymentMethod(
  //   SelectedPaymentMethod selectedMethod,
  //   List<PaymentMethod> offeringMethods,
  // ) {
  //   final matchedOfferingMethod = offeringMethods
  //       .firstWhere((method) => method.kind == selectedMethod.kind);

  //   var schema = matchedOfferingMethod.getRequiredPaymentDetailsSchema();
  //   if (matchedOfferingMethod.requiredPaymentDetails != null &&
  //       schema != null) {
  //     var jsonNodePaymentDetails = jsonEncode(selectedMethod.paymentDetails);
  //     schema.validate(jsonNodePaymentDetails);
  //   }
  // }

  factory Rfq.fromJson(Map<String, dynamic> json) {
    return Rfq._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: RfqData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'data': data.toJson(),
    };
  }
}
