class _TbdexValidationError implements Exception {
  final String message;
  final Exception? cause;

  _TbdexValidationError({
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

class ValidationError extends _TbdexValidationError {
  ValidationError({
    required String message,
    Exception? cause,
  }) : super(
          message: message,
          cause: cause,
        );

  @override
  String get errorType => 'ValidationError';
}

class InvalidDidError extends ValidationError {
  InvalidDidError({
    required String message,
    Exception? cause,
  }) : super(
          message: message,
          cause: cause,
        );

  @override
  String get errorType => 'InvalidDidError';
}

class MissingServiceEndpointError extends ValidationError {
  MissingServiceEndpointError({
    required String message,
    Exception? cause,
  }) : super(
          message: message,
          cause: cause,
        );

  @override
  String get errorType => 'MissingServiceEndpointError';
}
