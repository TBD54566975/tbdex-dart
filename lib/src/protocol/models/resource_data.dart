import 'package:json_schema/json_schema.dart';

abstract class Data {}

abstract class ResourceData extends Data {}

class OfferingData extends ResourceData {
  final String description;
  final String payoutUnitsPerPayinUnit;
  final PayinDetails payin;
  final PayoutDetails payout;
  // final PresentationDefinitionV2? requiredClaims;

  OfferingData({
    required this.description,
    required this.payoutUnitsPerPayinUnit,
    required this.payin,
    required this.payout,
    // this.requiredClaims,
  });

  factory OfferingData.fromJson(Map<String, dynamic> json) {
    return OfferingData(
      description: json['description'],
      payoutUnitsPerPayinUnit: json['payoutUnitsPerPayinUnit'],
      payin: PayinDetails.fromJson(json['payin']),
      payout: PayoutDetails.fromJson(json['payout']),
      // requiredClaims: json['requiredClaims'] != null ? PresentationDefinitionV2.fromJson(json['requiredClaims']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'payoutUnitsPerPayinUnit': payoutUnitsPerPayinUnit,
      'payin': payin.toJson(),
      'payout': payout.toJson(),
      // 'requiredClaims': requiredClaims?.toJson(),
    };
  }
}

class PayinDetails {
  final String currencyCode;
  final List<PayinMethod> methods;
  final String? min;
  final String? max;

  PayinDetails({
    required this.currencyCode,
    required this.methods,
    this.min,
    this.max,
  });

  factory PayinDetails.fromJson(Map<String, dynamic> json) {
    return PayinDetails(
      currencyCode: json['currencyCode'],
      methods: (json['methods'] as List)
          .map(
            (method) => PayinMethod.fromJson(
              method as Map<String, dynamic>,
            ),
          )
          .toList(),
      min: json['min'],
      max: json['max'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'methods': methods.map((method) => method.toJson()).toList(),
      if (min != null) 'min': min,
      if (max != null) 'max': max,
    };
  }
}

class PayoutDetails {
  final String currencyCode;
  final List<PayoutMethod> methods;
  final String? min;
  final String? max;

  PayoutDetails({
    required this.currencyCode,
    required this.methods,
    this.min,
    this.max,
  });

  factory PayoutDetails.fromJson(Map<String, dynamic> json) {
    return PayoutDetails(
      currencyCode: json['currencyCode'],
      methods: (json['methods'] as List)
          .map(
            (method) => PayoutMethod.fromJson(
              method as Map<String, dynamic>,
            ),
          )
          .toList(),
      min: json['min'],
      max: json['max'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'methods': methods.map((method) => method.toJson()).toList(),
      if (min != null) 'min': min,
      if (max != null) 'max': max,
    };
  }
}

class PayinMethod {
  final String kind;
  final String? name;
  final String? description;
  final String? group;
  final JsonSchema? requiredPaymentDetails;
  final String? fee;
  final String? min;
  final String? max;

  PayinMethod({
    required this.kind,
    this.name,
    this.description,
    this.group,
    this.requiredPaymentDetails,
    this.fee,
    this.min,
    this.max,
  });

  JsonSchema? getRequiredPaymentDetailsSchema() => requiredPaymentDetails;

  factory PayinMethod.fromJson(Map<String, dynamic> json) {
    return PayinMethod(
      kind: json['kind'],
      name: json['name'],
      description: json['description'],
      group: json['group'],
      requiredPaymentDetails: JsonSchema.create(json['requiredPaymentDetails']),
      fee: json['fee'],
      min: json['min'],
      max: json['max'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (group != null) 'group': group,
      if (requiredPaymentDetails != null)
        'requiredPaymentDetails': requiredPaymentDetails?.schemaMap,
      if (fee != null) 'fee': fee,
      if (min != null) 'min': min,
      if (max != null) 'max': max,
    };
  }
}

class PayoutMethod {
  final int estimatedSettlementTime;
  final String kind;
  final String? name;
  final String? description;
  final String? group;
  final JsonSchema? requiredPaymentDetails;
  final String? fee;
  final String? min;
  final String? max;

  PayoutMethod({
    required this.estimatedSettlementTime,
    required this.kind,
    this.name,
    this.description,
    this.group,
    this.requiredPaymentDetails,
    this.fee,
    this.min,
    this.max,
  });

  JsonSchema? getRequiredPaymentDetailsSchema() => requiredPaymentDetails;

  factory PayoutMethod.fromJson(Map<String, dynamic> json) {
    return PayoutMethod(
      kind: json['kind'],
      estimatedSettlementTime: json['estimatedSettlementTime'],
      name: json['name'],
      description: json['description'],
      group: json['group'],
      requiredPaymentDetails: JsonSchema.create(json['requiredPaymentDetails']),
      fee: json['fee'],
      min: json['min'],
      max: json['max'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'estimatedSettlementTime': estimatedSettlementTime,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (group != null) 'group': group,
      if (requiredPaymentDetails != null)
        'requiredPaymentDetails': requiredPaymentDetails?.schemaMap,
      if (fee != null) 'fee': fee,
      if (min != null) 'min': min,
      if (max != null) 'max': max,
    };
  }
}
