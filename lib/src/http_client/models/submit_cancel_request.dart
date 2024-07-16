import 'package:tbdex/src/protocol/models/cancel.dart';

class SubmitCancelRequest {
  final Cancel cancel;

  SubmitCancelRequest({
    required this.cancel,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': cancel.toJson(),
    };
  }
}
