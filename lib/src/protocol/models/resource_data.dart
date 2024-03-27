abstract class Data {}

abstract class ResourceData extends Data {}

class OfferingData extends ResourceData {
  final String description;
  final String payoutUnitsPerPayinUnit;
  final CurrencyDetails payoutCurrency;
  final CurrencyDetails payinCurrency;
  final List<PaymentMethod> payinMethods;
  final List<PaymentMethod> payoutMethods;
  // final PresentationDefinitionV2? requiredClaims;

  OfferingData({
    required this.description,
    required this.payoutUnitsPerPayinUnit,
    required this.payoutCurrency,
    required this.payinCurrency,
    required this.payinMethods,
    required this.payoutMethods,
    // this.requiredClaims,
  });

  factory OfferingData.fromJson(Map<String, dynamic> json) {
    return OfferingData(
      description: json['description'],
      payoutUnitsPerPayinUnit: json['payoutUnitsPerPayinUnit'],
      payoutCurrency: CurrencyDetails.fromJson(json['payoutCurrency']),
      payinCurrency: CurrencyDetails.fromJson(json['payinCurrency']),
      payinMethods: (json['payinMethods'] as List)
          .map((e) => PaymentMethod.fromJson(e))
          .toList(),
      payoutMethods: (json['payoutMethods'] as List)
          .map((e) => PaymentMethod.fromJson(e))
          .toList(),
      // requiredClaims: json['requiredClaims'] != null ? PresentationDefinitionV2.fromJson(json['requiredClaims']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'payoutUnitsPerPayinUnit': payoutUnitsPerPayinUnit,
      'payoutCurrency': payoutCurrency.toJson(),
      'payinCurrency': payinCurrency.toJson(),
      'payinMethods': payinMethods.map((e) => e.toJson()).toList(),
      'payoutMethods': payoutMethods.map((e) => e.toJson()).toList(),
      // 'requiredClaims': requiredClaims?.toJson(),
    };
  }
}

class CurrencyDetails {
  final String currencyCode;
  final String? minAmount;
  final String? maxAmount;

  CurrencyDetails({required this.currencyCode, this.minAmount, this.maxAmount});

  factory CurrencyDetails.fromJson(Map<String, dynamic> json) {
    return CurrencyDetails(
      currencyCode: json['currencyCode'],
      minAmount: json['minAmount'],
      maxAmount: json['maxAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
    };
  }
}

class PaymentMethod {
  final String kind;
  final dynamic requiredPaymentDetails;
  final String? fee;

  PaymentMethod({required this.kind, this.requiredPaymentDetails, this.fee});

  dynamic getRequiredPaymentDetailsSchema() {
    if (requiredPaymentDetails == null) return null;

    return requiredPaymentDetails;
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      kind: json['kind'],
      requiredPaymentDetails: json['requiredPaymentDetails'],
      fee: json['fee'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'requiredPaymentDetails': requiredPaymentDetails,
      'fee': fee,
    };
  }
}
