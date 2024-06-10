import 'dart:convert';

import 'package:tbdex/src/http_client/models/exchange.dart';
import 'package:tbdex/src/protocol/exceptions.dart';
import 'package:tbdex/src/protocol/models/balance.dart';
import 'package:tbdex/src/protocol/models/close.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/order_status.dart';
import 'package:tbdex/src/protocol/models/quote.dart';
import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:tbdex/src/protocol/validator.dart';

abstract class Parser {
  static Message parseMessage(String rawMessage) {
    final jsonObject = jsonDecode(rawMessage) as Map<String, dynamic>?;
    if (jsonObject is! Map<String, dynamic>) {
      throw TbdexParseException(
        TbdexExceptionCode.parserMessageJsonNotObject,
        'Message JSON must be an object',
      );
    }
    Validator.validate(jsonObject, 'message');

    return _parseMessageJson(jsonObject);
  }

  static Resource parseResource(String rawResource) {
    final jsonObject = jsonDecode(rawResource);

    if (jsonObject is! Map<String, dynamic>) {
      throw Exception('resource must be a json object');
    }

    return _parseResourceJson(jsonObject);
  }

  static Exchange parseExchange(String rawExchange) {
    final jsonObject = jsonDecode(rawExchange);

    if (jsonObject is! Map<String, dynamic>) {
      throw Exception('exchange must be a json object');
    }

    final exchange = jsonObject['data'];

    if (exchange is! List<dynamic> || exchange.isEmpty) {
      throw Exception('exchange data is malformed or empty');
    }

    final parsedMessages = <Message>[];
    for (final messageJson in exchange) {
      final message = _parseMessageJson(messageJson);
      parsedMessages.add(message);
    }

    return parsedMessages;
  }

  static List<String> parseExchanges(String rawExchanges) {
    final jsonObject = jsonDecode(rawExchanges);

    if (jsonObject is! Map<String, dynamic>) {
      throw Exception('exchanges must be a json object');
    }

    final exchanges = jsonObject['data'];

    if (exchanges is! List<dynamic> || exchanges.isEmpty) {
      throw Exception('exchanges data is malformed or empty');
    }

    if (exchanges.any((element) => element is! String)) {
      throw Exception('all exchange ids should be strings');
    }

    return List<String>.from(exchanges);
  }

  static List<Offering> parseOfferings(String rawOfferings) {
    final jsonObject = jsonDecode(rawOfferings);

    if (jsonObject is! Map<String, dynamic>) {
      throw Exception('offerings must be a json object');
    }

    final offerings = jsonObject['data'];

    if (offerings is! List<dynamic> || offerings.isEmpty) {
      throw Exception('offerings data is malformed or empty');
    }

    final parsedOfferings = <Offering>[];
    for (final offeringJson in offerings) {
      final offering = _parseResourceJson(offeringJson) as Offering;
      parsedOfferings.add(offering);
    }

    return parsedOfferings;
  }

  static List<Balance> parseBalances(String rawBalances) {
    final jsonObject = jsonDecode(rawBalances);

    if (jsonObject is! Map<String, dynamic>) {
      throw Exception('balances must be a json object');
    }

    final balances = jsonObject['data'];

    if (balances is! List<dynamic> || balances.isEmpty) {
      throw Exception('balances data is malformed or empty');
    }

    final parsedBalances = <Balance>[];
    for (final balanceJson in balances) {
      final balance = _parseResourceJson(balanceJson) as Balance;
      parsedBalances.add(balance);
    }

    return parsedBalances;
  }

  static Message _parseMessageJson(Map<String, dynamic> jsonObject) {
    final messageKind = _getKindFromJson(jsonObject);
    final matchedKind = MessageKind.values.firstWhere(
      (kind) => kind.name == messageKind,
      orElse: () => throw TbdexParseException(
        TbdexExceptionCode.parserUnknownMessageKind,
        'unknown message kind: $messageKind',
      ),
    );

    switch (matchedKind) {
      case MessageKind.rfq:
        return Rfq.fromJson(jsonObject);
      case MessageKind.quote:
        return Quote.fromJson(jsonObject);
      case MessageKind.close:
        return Close.fromJson(jsonObject);
      case MessageKind.order:
        return Order.fromJson(jsonObject);
      case MessageKind.orderstatus:
        return OrderStatus.fromJson(jsonObject);
    }
  }

  static Resource _parseResourceJson(Map<String, dynamic> jsonObject) {
    final resourceKind = _getKindFromJson(jsonObject);
    final matchedKind = ResourceKind.values.firstWhere(
      (kind) => kind.name == resourceKind,
      orElse: () => throw TbdexParseException(
        TbdexExceptionCode.parserUnknownResourceKind,
        'unknown resource kind: $resourceKind',
      ),
    );

    switch (matchedKind) {
      case ResourceKind.offering:
        return Offering.fromJson(jsonObject);
      case ResourceKind.balance:
        return Balance.fromJson(jsonObject);
      case ResourceKind.reputation:
        throw UnimplementedError();
    }
  }

  static String _getKindFromJson(Map<String, dynamic> jsonObject) {
    final metadata = jsonObject['metadata'];

    if (metadata is! Map<String, dynamic> || metadata.isEmpty) {
      throw TbdexParseException(
        TbdexExceptionCode.parserMetadataMalformed,
        'metadata is malformed or empty',
      );
    }

    final kind = metadata['kind'];

    if (kind is! String) {
      TbdexParseException(
        TbdexExceptionCode.parserKindRequired,
        'kind property is required in metadata and must be a string',
      );
    }
    return kind;
  }
}
