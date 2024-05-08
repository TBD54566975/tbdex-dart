import 'package:tbdex/src/protocol/models/close.dart';

class SubmitCloseRequest {
  final Close close;

  SubmitCloseRequest({
    required this.close,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': close.toJson(),
    };
  }
}
