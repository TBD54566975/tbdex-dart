import 'package:tbdex/src/protocol/models/resource_data.dart';

abstract class MessageData extends Data {}

class RfqData extends MessageData {
  final String offeringId;
  final String payinAmount;
  final SelectedPaymentMethod payinMethod;
  final SelectedPaymentMethod payoutMethod;
  final List<String> claims;

  RfqData({
    required this.offeringId,
    required this.payinAmount,
    required this.payinMethod,
    required this.payoutMethod,
    required this.claims,
  });

  factory RfqData.fromJson(Map<String, dynamic> json) {
    return RfqData(
      offeringId: json['offeringId'],
      payinAmount: json['payinAmount'],
      payinMethod: SelectedPaymentMethod.fromJson(json['payinMethod']),
      payoutMethod: SelectedPaymentMethod.fromJson(json['payoutMethod']),
      claims: (json['claims'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offeringId': offeringId,
      'payinAmount': payinAmount,
      'payinMethod': payinMethod.toJson(),
      'payoutMethod': payoutMethod.toJson(),
      'claims': claims,
    };
  }
}

class SelectedPaymentMethod {
  final String kind;
  final Map<String, dynamic>? paymentDetails;

  SelectedPaymentMethod({required this.kind, this.paymentDetails});

  factory SelectedPaymentMethod.fromJson(Map<String, dynamic> json) {
    return SelectedPaymentMethod(
      kind: json['kind'],
      paymentDetails: json['paymentDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'paymentDetails': paymentDetails,
    };
  }
}

class QuoteData extends MessageData {
  final String expiresAt;
  final QuoteDetails payin;
  final QuoteDetails payout;

  QuoteData(
      {required this.expiresAt, required this.payin, required this.payout});

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
      'fee': fee,
      'paymentInstruction': paymentInstruction?.toJson(),
    };
  }
}

class PaymentInstruction {
  final String? link;
  final String? instruction;

  PaymentInstruction({this.link, this.instruction});

  factory PaymentInstruction.fromJson(Map<String, dynamic> json) {
    return PaymentInstruction(
      link: json['link'],
      instruction: json['instruction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'instruction': instruction,
    };
  }
}

class CloseData extends MessageData {
  final String reason;

  CloseData({required this.reason});

  factory CloseData.fromJson(Map<String, dynamic> json) {
    return CloseData(
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
    };
  }
}

class OrderData extends MessageData {}

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
