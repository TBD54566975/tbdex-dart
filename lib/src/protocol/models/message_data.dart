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
      payin: json['payin'] != null
          ? PrivatePaymentDetails.fromJson(json['payin'])
          : null,
      payout: json['payout'] != null
          ? PrivatePaymentDetails.fromJson(json['payout'])
          : null,
      claims: json['claims'] != null
          ? (json['claims'] as List).map((claim) => claim as String).toList()
          : null,
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
  final String payoutUnitsPerPayinUnit;
  final QuoteDetails payin;
  final QuoteDetails payout;

  QuoteData({
    required this.expiresAt,
    required this.payoutUnitsPerPayinUnit,
    required this.payin,
    required this.payout,
  });

  factory QuoteData.fromJson(Map<String, dynamic> json) {
    return QuoteData(
      expiresAt: json['expiresAt'],
      payoutUnitsPerPayinUnit: json['payoutUnitsPerPayinUnit'],
      payin: QuoteDetails.fromJson(json['payin']),
      payout: QuoteDetails.fromJson(json['payout']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'expiresAt': expiresAt,
      'payoutUnitsPerPayinUnit': payoutUnitsPerPayinUnit,
      'payin': payin.toJson(),
      'payout': payout.toJson(),
    };
  }
}

class QuoteDetails {
  final String currencyCode;
  final String subtotal;
  final String total;
  final String? fee;
  final PaymentInstruction? paymentInstruction;

  QuoteDetails({
    required this.currencyCode,
    required this.subtotal,
    required this.total,
    this.fee,
    this.paymentInstruction,
  });

  factory QuoteDetails.fromJson(Map<String, dynamic> json) {
    return QuoteDetails(
      currencyCode: json['currencyCode'],
      subtotal: json['subtotal'],
      total: json['total'],
      fee: json['fee'],
      paymentInstruction: json['paymentInstruction'] != null
          ? PaymentInstruction.fromJson(json['paymentInstruction'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'subtotal': subtotal,
      'total': total,
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

class CancelData extends MessageData {
  final String? reason;

  CancelData({
    this.reason,
  });

  factory CancelData.fromJson(Map<String, dynamic> json) {
    return CancelData(
      reason: json['reason'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
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
  final Status status;

  OrderStatusData({required this.status});

  factory OrderStatusData.fromJson(Map<String, dynamic> json) {
    return OrderStatusData(
      status: Status.fromJson(json['status']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status.toJson(),
    };
  }
}

enum Status {
  payinPending,
  payinInitiated,
  payinSettled,
  payinFailed,
  payinExpired,
  payoutPending,
  payoutInitiated,
  payoutSettled,
  payoutFailed,
  refundPending,
  refundInitiated,
  refundFailed,
  refundSettled;

  static Status fromJson(String json) {
    switch (json) {
      case 'PAYIN_PENDING':
        return Status.payinPending;
      case 'PAYIN_INITIATED':
        return Status.payinInitiated;
      case 'PAYIN_SETTLED':
        return Status.payinSettled;
      case 'PAYIN_FAILED':
        return Status.payinFailed;
      case 'PAYIN_EXPIRED':
        return Status.payinExpired;
      case 'PAYOUT_PENDING':
        return Status.payoutPending;
      case 'PAYOUT_INITIATED':
        return Status.payoutInitiated;
      case 'PAYOUT_SETTLED':
        return Status.payoutSettled;
      case 'PAYOUT_FAILED':
        return Status.payoutFailed;
      case 'REFUND_PENDING':
        return Status.refundPending;
      case 'REFUND_INITIATED':
        return Status.refundInitiated;
      case 'REFUND_FAILED':
        return Status.refundFailed;
      case 'REFUND_SETTLED':
        return Status.refundSettled;
      default:
        throw Exception('Unknown status: $json');
    }
  }

  String toJson() {
    switch (this) {
      case Status.payinPending:
        return 'PAYIN_PENDING';
      case Status.payinInitiated:
        return 'PAYIN_INITIATED';
      case Status.payinSettled:
        return 'PAYIN_SETTLED';
      case Status.payinFailed:
        return 'PAYIN_FAILED';
      case Status.payinExpired:
        return 'PAYIN_EXPIRED';
      case Status.payoutPending:
        return 'PAYOUT_PENDING';
      case Status.payoutInitiated:
        return 'PAYOUT_INITIATED';
      case Status.payoutSettled:
        return 'PAYOUT_SETTLED';
      case Status.payoutFailed:
        return 'PAYOUT_FAILED';
      case Status.refundPending:
        return 'REFUND_PENDING';
      case Status.refundInitiated:
        return 'REFUND_INITIATED';
      case Status.refundFailed:
        return 'REFUND_FAILED';
      case Status.refundSettled:
        return 'REFUND_SETTLED';
    }
  }
}

class OrderInstructionsData extends MessageData {
  final PaymentInstruction payin;
  final PaymentInstruction payout;

  OrderInstructionsData({required this.payin, required this.payout});

  factory OrderInstructionsData.fromJson(Map<String, dynamic> json) {
    return OrderInstructionsData(
      payin: PaymentInstruction.fromJson(json['payin']),
      payout: PaymentInstruction.fromJson(json['payout']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'payin': payin.toJson(),
      'payout': payout.toJson(),
    };
  }
}
