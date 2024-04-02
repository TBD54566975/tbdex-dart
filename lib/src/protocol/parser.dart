import 'dart:convert';

import 'package:tbdex/src/protocol/models/close.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/order_status.dart';
import 'package:tbdex/src/protocol/models/quote.dart';
import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';

abstract class Parser {
  static Message parseMessage(String rawMessage) {
    final jsonObject = jsonDecode(rawMessage) as Map<String, dynamic>?;
    final messageKind = _getKindFromJson(jsonObject);
    final matchedKind = MessageKind.values.firstWhere(
      (kind) => kind.name == messageKind,
      orElse: () => throw Exception('unknown message kind: $messageKind'),
    );

    switch (matchedKind) {
      case MessageKind.rfq:
        return Rfq.fromJson(jsonObject ?? {});
      case MessageKind.quote:
        return Quote.fromJson(jsonObject ?? {});
      case MessageKind.close:
        return Close.fromJson(jsonObject ?? {});
      case MessageKind.order:
        return Order.fromJson(jsonObject ?? {});
      case MessageKind.orderstatus:
        return OrderStatus.fromJson(jsonObject ?? {});
    }
  }

  static Resource parseResource(String rawResource) {
    final jsonObject = jsonDecode(rawResource) as Map<String, dynamic>?;
    final resourceKind = _getKindFromJson(jsonObject);
    final matchedKind = ResourceKind.values.firstWhere(
      (kind) => kind.name == resourceKind,
      orElse: () => throw Exception('unknown resource kind: $resourceKind'),
    );

    switch (matchedKind) {
      case ResourceKind.offering:
        return Offering.fromJson(jsonObject ?? {});
      case ResourceKind.balance:
      case ResourceKind.reputation:
        throw UnimplementedError();
    }
  }

  static String _getKindFromJson(Map<String, dynamic>? jsonObject) {
    if (jsonObject == null) {
      throw Exception('string is not a valid json object');
    }

    final metadata = jsonObject['metadata'] as Map<String, dynamic>?;

    if (metadata == null) {
      throw Exception('metadata property is required');
    }

    final kind = metadata['kind'] as String?;
    return kind ?? (throw Exception('kind property is required in metadata'));
  }
}
