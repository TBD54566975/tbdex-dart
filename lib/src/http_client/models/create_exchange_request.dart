import 'package:tbdex/src/protocol/models/rfq.dart';

class CreateExchangeRequest {
  final Rfq rfq;
  final String? replyTo;

  CreateExchangeRequest({
    required this.rfq,
    this.replyTo,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': rfq.toJson(),
      if (replyTo != null) 'replyTo': replyTo,
    };
  }
}
