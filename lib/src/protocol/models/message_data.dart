import 'package:tbdex/src/protocol/models/resource_data.dart';

abstract class MessageData extends Data {}

class PrivatePaymentDetails {
  final Map<String, dynamic> paymentDetails;

  PrivatePaymentDetails({required this.paymentDetails});

  factory PrivatePaymentDetails.fromJson(Map<String, dynamic> json) {
    return PrivatePaymentDetails(
      paymentDetails: json['paymentDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentDetails': paymentDetails,
    };
  }
}

class RfqPrivateData {
  final String salt;
  final PrivatePaymentDetails? payin;
  final PrivatePaymentDetails? payout;
  final List<String>? claims;

  RfqPrivateData({required this.salt, this.payin, this.payout, this.claims});

  factory RfqPrivateData.fromJson(Map<String, dynamic> json) {
    return RfqPrivateData(
      salt: json['salt'],
      payin: json['payin'] != null ? PrivatePaymentDetails.fromJson(json['payin']) : null,
      payout: json['payout'] != null ? PrivatePaymentDetails.fromJson(json['payout']) : null,
      claims: json['claims'] != null ?
        (json['claims'] as List).map((claim) => claim as String).toList() :
        null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salt': salt,
      if (payin != null) 'payin': payin!.toJson(),
      if (payout != null) 'payout': payout!.toJson(),
      if (claims != null) 'claims': claims,
    };
  }
}

class CreateSelectedPayinMethod {
  final String amount;
  final String kind;
  final Map<String, dynamic>? paymentDetails;

  CreateSelectedPayinMethod({
    required this.amount,
    required this.kind,
    this.paymentDetails,
  });
}

class CreateSelectedPayoutMethod {
  final String kind;
  final Map<String, dynamic>? paymentDetails;

  CreateSelectedPayoutMethod({
    required this.kind,
    this.paymentDetails,
  });
}

class CreateRfqData {
  final String offeringId;
  final CreateSelectedPayinMethod payin;
  final CreateSelectedPayoutMethod payout;
  final List<String>? claims;

  CreateRfqData({
    required this.offeringId,
    required this.payin,
    required this.payout,
    this.claims,
  });
}

class RfqData extends MessageData {
  final String offeringId;
  final SelectedPayinMethod payin;
  final SelectedPayoutMethod payout;
  final String? claimsHash;

  RfqData({
    required this.offeringId,
    required this.payin,
    required this.payout,
    required this.claimsHash,
  });

  factory RfqData.fromJson(Map<String, dynamic> json) {
    return RfqData(
      offeringId: json['offeringId'],
      payin: SelectedPayinMethod.fromJson(json['payin']),
      payout: SelectedPayoutMethod.fromJson(json['payout']),
      claimsHash: json['claimsHash'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'offeringId': offeringId,
      'payin': payin.toJson(),
      'payout': payout.toJson(),
      if (claimsHash != null) 'claimsHash': claimsHash,
    };
  }
}

class SelectedPayinMethod {
  final String amount;
  final String kind;
  final String? paymentDetailsHash;

  SelectedPayinMethod({
    required this.amount,
    required this.kind,
    this.paymentDetailsHash,
  });

  factory SelectedPayinMethod.fromJson(Map<String, dynamic> json) {
    return SelectedPayinMethod(
      amount: json['amount'],
      kind: json['kind'],
      paymentDetailsHash: json['paymentDetailsHash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'kind': kind,
      if (paymentDetailsHash != null) 'paymentDetailsHash': paymentDetailsHash,
    };
  }
}

class SelectedPayoutMethod {
  final String kind;
  final String? paymentDetailsHash;

  SelectedPayoutMethod({required this.kind, this.paymentDetailsHash});

  factory SelectedPayoutMethod.fromJson(Map<String, dynamic> json) {
    return SelectedPayoutMethod(
      kind: json['kind'],
      paymentDetailsHash: json['paymentDetailsHash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      if (paymentDetailsHash != null) 'paymentDetailsHash': paymentDetailsHash,
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

  @override
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

  @override
  Map<String, dynamic> toJson() {
    return {
      if (success != null) 'success': success,
      if (reason != null) 'reason': reason,
    };
  }
}

class OrderData extends MessageData {
  @override
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'orderStatus': orderStatus,
    };
  }
}
