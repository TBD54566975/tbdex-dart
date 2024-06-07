// TODO(ethan-tbd): move to web5-dart when kcc is added to web5-dart
class _TbdexTokenError implements Exception {
  final String message;
  final Exception? cause;

  _TbdexTokenError({
    required this.message,
    this.cause,
  });

  String get errorType => 'TbdexValidationError';

  @override
  String toString() => [
        '$errorType: $message',
        if (cause != null) 'Caused by: $cause',
      ].join('\n');
}

class RequestTokenError extends _TbdexTokenError {
  RequestTokenError({
    required String message,
    Exception? cause,
  }) : super(
          message: message,
          cause: cause,
        );

  @override
  String get errorType => 'RequestTokenError';
}

class RequestTokenSigningError extends RequestTokenError {
  RequestTokenSigningError({
    required String message,
    Exception? cause,
  }) : super(
          message: message,
          cause: cause,
        );

  @override
  String get errorType => 'RequestTokenSigningError';
}

class RequestTokenVerificationError extends RequestTokenError {
  RequestTokenVerificationError({
    required String message,
    Exception? cause,
  }) : super(
          message: message,
          cause: cause,
        );

  @override
  String get errorType => 'RequestTokenVerificationError';
}

class RequestTokenMissingClaimsError extends RequestTokenError {
  RequestTokenMissingClaimsError({
    required String message,
    Exception? cause,
  }) : super(
          message: message,
          cause: cause,
        );

  @override
  String get errorType => 'RequestTokenMissingClaimsError';
}

class RequestTokenAudienceMismatchError extends RequestTokenError {
  RequestTokenAudienceMismatchError({
    required String message,
    Exception? cause,
  }) : super(
          message: message,
          cause: cause,
        );

  @override
  String get errorType => 'RequestTokenAudienceMismatchError';
}
