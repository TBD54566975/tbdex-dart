import 'package:tbdex/src/protocol/models/order.dart';

class SubmitOrderRequest {
  final Order order;

  SubmitOrderRequest({
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': order.toJson(),
    };
  }
}
