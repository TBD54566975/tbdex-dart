import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:tbdex/src/protocol/crypto.dart';
import 'package:tbdex/src/protocol/exceptions.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/validator.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

class Rfq extends Message {
  @override
  final MessageMetadata metadata;
  @override
  final RfqData data;
  final RfqPrivateData? privateData;

  @override
  Set<MessageKind> get validNext => {MessageKind.quote, MessageKind.close};

  Rfq._({
    required this.metadata,
    required this.data,
    this.privateData,
    String? signature,
  }) : super() {
    this.signature = signature;
  }

  static Rfq create(
    String to,
    String from,
    CreateRfqData createRfqData, {
    String? externalId,
    String protocol = '1.0',
  }) {
    final id = Message.generateId(MessageKind.rfq);
    final now = DateTime.now().toUtc().toIso8601String();
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

    var result = hashPrivateData(createRfqData);

    return Rfq._(
      metadata: metadata,
      data: result['data'],
      privateData: result['privateData'],
    );
  }

  static String digestPrivateData(String salt, value) {
    var digest = CryptoUtils.digest([salt, value]);
    return Base64Url.encode(digest);
  }

  static Map<String, dynamic> hashPrivateData(CreateRfqData unhashedRfqData) {
    var salt = CryptoUtils.generateSalt();

    PrivatePaymentDetails? privatePayin;
    PrivatePaymentDetails? privatePayout;
    String? payinDetailsHash;
    String? payoutDetailsHash;
    String? claimsHash;

    if (unhashedRfqData.payin.paymentDetails != null) {
      privatePayin = PrivatePaymentDetails(
        paymentDetails: unhashedRfqData.payin.paymentDetails!,
      );
      payinDetailsHash = digestPrivateData(
        salt,
        unhashedRfqData.payin.paymentDetails,
      );
    }

    if (unhashedRfqData.payout.paymentDetails != null) {
      privatePayout = PrivatePaymentDetails(
        paymentDetails: unhashedRfqData.payout.paymentDetails!,
      );
      payoutDetailsHash = digestPrivateData(
        salt,
        unhashedRfqData.payout.paymentDetails,
      );
    }

    if (unhashedRfqData.claims != null && unhashedRfqData.claims != null) {
      claimsHash = digestPrivateData(salt, unhashedRfqData.claims);
    }

    var data = RfqData(
      offeringId: unhashedRfqData.offeringId,
      payin: SelectedPayinMethod(
        amount: unhashedRfqData.payin.amount,
        kind: unhashedRfqData.payin.kind,
        paymentDetailsHash: payinDetailsHash,
      ),
      payout: SelectedPayoutMethod(
        kind: unhashedRfqData.payout.kind,
        paymentDetailsHash: payoutDetailsHash,
      ),
      claimsHash: claimsHash,
    );

    var privateData = RfqPrivateData(
      salt: salt,
      claims: unhashedRfqData.claims,
      payin: privatePayin,
      payout: privatePayout,
    );

    return {
      'data': data,
      'privateData': privateData,
    };
  }

  static Future<Rfq> parse(
    String rawMessage, {
    requireAllPrivateData = false,
  }) async {
    final jsonObject = jsonDecode(rawMessage) as Map<String, dynamic>;
    Validator.validate(jsonObject, 'message');
    Validator.validate(jsonObject['data'], 'rfq');
    if (jsonObject['privateData'] != null) {
      Validator.validate(jsonObject['privateData'], 'rfqPrivate');
    }

    final rfq = Rfq.fromJson(jsonObject);
    await rfq.verify();

    if (requireAllPrivateData) {
      rfq.verifyAllPrivateData();
    } else {
      rfq.verifyPresentPrivateData();
    }

    return rfq;
  }

  void verifyAllPrivateData() {
    if (privateData == null) {
      throw TbdexParseException(
        TbdexExceptionCode.rfqPrivateDataMissing,
        'Could not verify all privateData because privateData property is missing',
      );
    }

    // Verify payin details
    if (data.payin.paymentDetailsHash != null) {
      verifyPayinDetailsHash();
    }

    // Verify payout details
    if (data.payout.paymentDetailsHash != null) {
      verifyPayoutDetailsHash();
    }

    // Verify claims
    if (data.claimsHash != null) {
      verifyClaimsHash();
    }
  }

  void verifyPresentPrivateData() {
    // Verify payin details
    if (data.payin.paymentDetailsHash != null &&
        privateData?.payin?.paymentDetails != null) {
      verifyPayinDetailsHash();
    }

    // Verify payout details
    if (data.payout.paymentDetailsHash != null &&
        privateData?.payout?.paymentDetails != null) {
      verifyPayoutDetailsHash();
    }

    // Verify claims
    if (data.claimsHash != null && privateData!.claims != null) {
      verifyClaimsHash();
    }
  }

  void verifyPayinDetailsHash() {
    if (data.payin.paymentDetailsHash == null) {
      return;
    }

    if (privateData?.payin?.paymentDetails == null) {
      throw TbdexParseException(
        TbdexExceptionCode.rfqPayinDetailsMissing,
        'Private data integrity check failed: data.payin.paymentDetailsHash does not match digest of privateData.payin.paymentDetails',
      );
    }

    var digest = Rfq.digestPrivateData(
      privateData!.salt,
      privateData!.payin!.paymentDetails,
    );

    if (digest != data.payin.paymentDetailsHash) {
      throw TbdexParseException(
        TbdexExceptionCode.rfqPayinDetailsHashMismatch,
        'Private data integrity check failed: privateData.payin.paymentDetails is missing',
      );
    }
  }

  void verifyPayoutDetailsHash() {
    if (data.payout.paymentDetailsHash == null) {
      return;
    }

    if (privateData?.payout?.paymentDetails == null) {
      throw TbdexParseException(
        TbdexExceptionCode.rfqPayoutDetailsMissing,
        'Private data integrity check failed: privateData.payout.paymentDetails is missing',
      );
    }

    var digest = Rfq.digestPrivateData(
      privateData!.salt,
      privateData!.payout!.paymentDetails,
    );

    if (digest != data.payout.paymentDetailsHash) {
      throw TbdexParseException(
        TbdexExceptionCode.rfqPayoutDetailsHashMismatch,
        'Private data integrity check failed: data.payout.paymentDetailsHash does not match digest of privateData.payout.paymentDetails',
      );
    }
  }

  void verifyClaimsHash() {
    if (data.claimsHash == null) {
      return;
    }

    if (privateData?.claims == null) {
      throw TbdexParseException(
        TbdexExceptionCode.rfqClaimsMissing,
        'Private data integrity check failed: privateData.claims is missing',
      );
    }

    var claims = privateData!.claims;
    var digest = Rfq.digestPrivateData(privateData!.salt, claims);

    if (digest != data.claimsHash) {
      throw TbdexParseException(
        TbdexExceptionCode.rfqClaimsHashMismatch,
        'Private data integrity check failed: data.claimsHash does not match digest of privateData.claims',
      );
    }
  }

  void verifyOfferingRequirements(Offering offering) {
    if (metadata.protocol != offering.metadata.protocol) {
      throw TbdexVerifyOfferingRequirementsException(
        TbdexExceptionCode.rfqProtocolVersionMismatch,
        'protocol version mismatch: ${offering.metadata.protocol} != ${metadata.protocol}',
      );
    }

    if (data.offeringId != offering.metadata.id) {
      throw TbdexVerifyOfferingRequirementsException(
        TbdexExceptionCode.rfqOfferingIdMismatch,
        'offering id mismatch: ${offering.metadata.id} != ${data.offeringId}',
      );
    }

    if (offering.data.payin.min != null) {
      if (Decimal.parse(data.payin.amount) <
          Decimal.parse(offering.data.payin.min ?? '')) {
        throw TbdexVerifyOfferingRequirementsException(
          TbdexExceptionCode.rfqPayinLessThanMin,
          'payin amount is less than the minimum required amount',
        );
      }
    }

    if (offering.data.payin.max != null) {
      if (Decimal.parse(data.payin.amount) >
          Decimal.parse(offering.data.payin.max ?? '')) {
        throw TbdexVerifyOfferingRequirementsException(
          TbdexExceptionCode.rfqPayinGreaterThanMax,
          'payin amount is greater than the maximum allowed amount',
        );
      }
    }

    final payinMethod = offering.data.payin.methods.firstWhere(
      (method) => method.kind == data.payin.kind,
      orElse: () => throw TbdexVerifyOfferingRequirementsException(
        TbdexExceptionCode.rfqUnknownPayinKind,
        'unknown payin kind: ${data.payin.kind}',
      ),
    );

    final payinSchema = payinMethod.getRequiredPaymentDetailsSchema();
    if (payinSchema != null) {
      final validationResult =
          payinSchema.validate(privateData?.payin?.paymentDetails);
      if (!validationResult.isValid) {
        throw TbdexVerifyOfferingRequirementsException(
          TbdexExceptionCode.rfqPayinDetailsNotValid,
          'Payin details not valid: ${validationResult.errors.join(', ')}',
        );
      }
    }

    final payoutMethod = offering.data.payout.methods.firstWhere(
      (method) => method.kind == data.payout.kind,
      orElse: () => throw TbdexVerifyOfferingRequirementsException(
        TbdexExceptionCode.rfqUnknownPayoutKind,
        'unknown payout kind: ${data.payout.kind}',
      ),
    );

    final payoutSchema = payoutMethod.getRequiredPaymentDetailsSchema();
    if (payoutSchema != null) {
      final validationResult =
          payoutSchema.validate(privateData?.payout?.paymentDetails);
      if (!validationResult.isValid) {
        throw TbdexVerifyOfferingRequirementsException(
          TbdexExceptionCode.rfqPayoutDetailsNotValid,
          'Payout details not valid: ${validationResult.errors.join(', ')}',
        );
      }
    }

    verifyClaims(offering);
  }

  void verifyClaims(Offering offering) {
    if (offering.data.requiredClaims == null) {
      return;
    }
    final presentationDefinition = offering.data.requiredClaims!;

    final credentials =
        presentationDefinition.selectCredentials(privateData?.claims ?? []);

    if (credentials.isEmpty) {
      throw TbdexVerifyOfferingRequirementsException(
        TbdexExceptionCode.rfqClaimsInsufficient,
        "Rfq claims were insufficient to satisfy Offering's required claims",
      );
    }

    for (final credential in credentials) {
      DecodedVcJwt.decode(credential).verify();
    }
  }

  factory Rfq.fromJson(Map<String, dynamic> json) {
    return Rfq._(
      metadata: MessageMetadata.fromJson(json['metadata']),
      data: RfqData.fromJson(json['data']),
      privateData: json['privateData'] != null
          ? RfqPrivateData.fromJson(json['privateData'])
          : null,
      signature: json['signature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'data': data.toJson(),
      if (privateData != null) 'privateData': privateData?.toJson(),
      'signature': signature,
    };
  }
}
