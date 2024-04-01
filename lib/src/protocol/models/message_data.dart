import 'package:tbdex/src/protocol/models/resource_data.dart';

abstract class MessageData extends Data {}

class RfqData extends MessageData {
  final String offeringId;
  final SelectedPayinMethod payin;
  final SelectedPayoutMethod payout;
  final List<String> claims;

  RfqData({
    required this.offeringId,
    required this.payin,
    required this.payout,
    required this.claims,
  });

  factory RfqData.fromJson(Map<String, dynamic> json) {
    return RfqData(
      offeringId: json['offeringId'],
      payin: SelectedPayinMethod.fromJson(json['payin']),
      payout: SelectedPayoutMethod.fromJson(json['payout']),
      claims: (json['claims'] as List).map((claim) => claim as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offeringId': offeringId,
      'payin': payin.toJson(),
      'payout': payout.toJson(),
      'claims': claims,
    };
  }
}

class SelectedPayinMethod {
  final String amount;
  final String kind;
  final Map<String, dynamic>? paymentDetails;

  SelectedPayinMethod({
    required this.amount,
    required this.kind,
    this.paymentDetails,
  });

  factory SelectedPayinMethod.fromJson(Map<String, dynamic> json) {
    return SelectedPayinMethod(
      amount: json['amount'],
      kind: json['kind'],
      paymentDetails: json['paymentDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'kind': kind,
      if (paymentDetails != null) 'paymentDetails': paymentDetails,
    };
  }
}

class SelectedPayoutMethod {
  final String kind;
  final Map<String, dynamic>? paymentDetails;

  SelectedPayoutMethod({required this.kind, this.paymentDetails});

  factory SelectedPayoutMethod.fromJson(Map<String, dynamic> json) {
    return SelectedPayoutMethod(
      kind: json['kind'],
      paymentDetails: json['paymentDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      if (paymentDetails != null) 'paymentDetails': paymentDetails,
    };
  }
}

class QuoteData extends MessageData {
  final String expiresAt;
  final QuoteDetails payin;
  final QuoteDetails payout;

  QuoteData({
    required this.expiresAt,
    required this.payin,
    required this.payout,
  });

  factory QuoteData.fromJson(Map<String, dynamic> json) {
    return QuoteData(
      expiresAt: json['expiresAt'],
      payin: QuoteDetails.fromJson(json['payin']),
      payout: QuoteDetails.fromJson(json['payout']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expiresAt': expiresAt,
      'payin': payin.toJson(),
      'payout': payout.toJson(),
    };
  }
}

class QuoteDetails {
  final String currencyCode;
  final String amount;
  final String? fee;
  final PaymentInstruction? paymentInstruction;

  QuoteDetails({
    required this.currencyCode,
    required this.amount,
    this.fee,
    this.paymentInstruction,
  });

  factory QuoteDetails.fromJson(Map<String, dynamic> json) {
    return QuoteDetails(
      currencyCode: json['currencyCode'],
      amount: json['amount'],
      fee: json['fee'],
      paymentInstruction: json['paymentInstruction'] != null
          ? PaymentInstruction.fromJson(json['paymentInstruction'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'amount': amount,
      if (fee != null) 'fee': fee,
      if (paymentInstruction != null)
        'paymentInstruction': paymentInstruction?.toJson(),
    };
  }
}

class PaymentInstruction {
  final String? link;
  final String? instruction;

  PaymentInstruction({
    this.link,
    this.instruction,
  });

  factory PaymentInstruction.fromJson(Map<String, dynamic> json) {
    return PaymentInstruction(
      link: json['link'],
      instruction: json['instruction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (link != null) 'link': link,
      if (instruction != null) 'instruction': instruction,
    };
  }
}

class CloseData extends MessageData {
  final bool? success;
  final String? reason;

  CloseData({
    this.success,
    this.reason,
  });

  factory CloseData.fromJson(Map<String, dynamic> json) {
    return CloseData(
      success: json['success'],
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (success != null) 'success': success,
      if (reason != null) 'reason': reason,
    };
  }
}

class OrderData extends MessageData {
  Map<String, dynamic> toJson() {
    return {};
  }
}

class OrderStatusData extends MessageData {
  final String orderStatus;

  OrderStatusData({required this.orderStatus});

  factory OrderStatusData.fromJson(Map<String, dynamic> json) {
    return OrderStatusData(
      orderStatus: json['orderStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderStatus': orderStatus,
    };
  }
}
