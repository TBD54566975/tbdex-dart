class RequestError implements Exception {
  final String message;
  final String? url;
  final Exception? cause;

  RequestError({
    required this.message,
    this.url,
    this.cause,
  });

  String get errorType => 'RequestError';

  @override
  String toString() => [
        '$errorType: $message',
        if (url != null) 'Url: $url',
        if (cause != null) 'Caused by: $cause',
      ].join('\n');
}

class ResponseError implements Exception {
  final String message;
  final int? status;
  final String? body;

  ResponseError({
    required this.message,
    this.status,
    this.body,
  });

  String get errorType => 'ResponseError';

  @override
  String toString() => [
        '$errorType: $message',
        if (status != null) 'Status: $status',
        if (body != null) 'Body: $body',
      ].join('\n');
}
