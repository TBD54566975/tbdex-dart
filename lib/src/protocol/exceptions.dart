// Tbdex exception codes are each thrown in exactly one place.
// Each code is prefixed with the name of the file in which it is thrown.
enum TbdexExceptionCode {
  parserKindRequired,
  parserMessageJsonNotObject,
  parserMetadataMalformed,
  parserUnknownMessageKind,
  parserUnknownResourceKind,
  messageSignatureMissing,
  messageSignatureMismatch,
  messageUnknownKind,
  resourceSignatureMissing,
  resourceSignatureMismatch,
  resourceUnknownKind,
  rfqClaimsHashMismatch,
  rfqClaimsMissing,
  rfqOfferingIdMismatch,
  rfqPrivateDataMissing,
  rfqPayinDetailsHashMismatch,
  rfqPayinDetailsMissing,
  rfqPayinGreaterThanMax,
  rfqPayinLessThanMin,
  rfqPayinDetailsNotValid,
  rfqPayoutDetailsHashMismatch,
  rfqPayoutDetailsMissing,
  rfqPayoutDetailsNotValid,
  rfqProtocolVersionMismatch,
  rfqUnknownPayinKind,
  rfqUnknownPayoutKind,
  validatorNoSchema,
  validatorUnknownMessageKind,
  validatorUnknownResourceKind,
  validatorJsonSchemaError,
}

// TbdexException is the parent class for all custom exceptions thrown from this package
class TbdexException implements Exception {
  final String message;
  final TbdexExceptionCode code;
  TbdexException(this.code, this.message);

  @override
  String toString() => 'TbdexException($code): $message';
}

class TbdexParseException extends TbdexException {
  TbdexParseException(TbdexExceptionCode code, String message): super(code, message);
}

class TbdexSignatureVerificationException extends TbdexException {
  TbdexSignatureVerificationException(TbdexExceptionCode code, String message): super(code, message);
}

class TbdexValidatorException extends TbdexException {
  TbdexValidatorException(TbdexExceptionCode code, String message): super(code, message);
}

// Thrown when verifying RFQ against offering
class TbdexVerifyOfferingRequirementsException extends TbdexException {
  TbdexVerifyOfferingRequirementsException(TbdexExceptionCode code, String message): super(code, message);
}