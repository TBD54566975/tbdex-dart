import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:path/path.dart' as p;
import 'package:tbdex/src/protocol/exceptions.dart';
import 'package:tbdex/src/protocol/models/close.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/order_status.dart';
import 'package:tbdex/src/protocol/models/quote.dart';
import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';

class Validator {
  factory Validator._internal() {
    _initialize();
    return Validator._();
  }

  static final Map<String, JsonSchema> _schemaMap = {};
  static final Validator _instance = Validator._internal();

  Validator._();

  static void validateMessage(Message message) {
    _instance._validateMessage(message);
  }

  static void validateResource(Resource resource) {
    _instance._validateResource(resource);
  }

  static void validate(Map<String, dynamic> json, String schemaName) {
    return _instance._validate(json, schemaName);
  }

  void _validate(Map<String, dynamic> json, String schemaName) {
    final schema = _schemaMap[schemaName] ??
        (throw TbdexValidatorException(TbdexExceptionCode.validatorNoSchema, 'no schema with name $schemaName exists'));
    final validationResult = schema.validate(json);

    if (!validationResult.isValid) {
      _handleValidationError(validationResult.errors);
    }
  }

  void _validateMessage(Message message) {
    final matchedKind = MessageKind.values.firstWhere(
      (kind) => kind == message.metadata.kind,
      orElse: () =>
          throw TbdexValidatorException(TbdexExceptionCode.validatorUnknownMessageKind, 'unknown message kind: ${message.metadata.kind}'),
    );

    switch (matchedKind) {
      case MessageKind.rfq:
        final rfq = message as Rfq;
        _instance._validate(rfq.toJson(), 'message');
        _instance._validate(rfq.data.toJson(), rfq.metadata.kind.name);
        break;
      case MessageKind.quote:
        final quote = message as Quote;
        _instance._validate(quote.toJson(), 'message');
        _instance._validate(quote.data.toJson(), quote.metadata.kind.name);
        break;
      case MessageKind.close:
        final close = message as Close;
        _instance._validate(close.toJson(), 'message');
        _instance._validate(close.data.toJson(), close.metadata.kind.name);
        break;
      case MessageKind.order:
        final order = message as Order;
        _instance._validate(order.toJson(), 'message');
        _instance._validate(order.data.toJson(), order.metadata.kind.name);
        break;
      case MessageKind.orderstatus:
        final orderStatus = message as OrderStatus;
        _instance._validate(orderStatus.toJson(), 'message');
        _instance._validate(
          orderStatus.data.toJson(),
          orderStatus.metadata.kind.name,
        );
        break;
    }
  }

  void _validateResource(Resource resource) {
    final matchedKind = ResourceKind.values.firstWhere(
      (kind) => kind == resource.metadata.kind,
      orElse: () =>
          throw TbdexValidatorException(TbdexExceptionCode.validatorUnknownResourceKind, 'unknown resource kind: ${resource.metadata.kind}'),
    );

    switch (matchedKind) {
      case ResourceKind.offering:
        final offering = resource as Offering;
        validate(offering.toJson(), 'resource');
        validate(offering.data.toJson(), offering.metadata.kind.name);
        break;
      case ResourceKind.balance:
      case ResourceKind.reputation:
        throw UnimplementedError();
    }
  }

  void _handleValidationError(List<ValidationError> errors) {
    if (errors.isNotEmpty) {
      throw TbdexValidatorException(TbdexExceptionCode.validatorJsonSchemaError, errors.join(', '));
    }
  }

  static void _initialize() {
    final schemasPath = p.join('lib', 'src', 'protocol', 'json-schemas');
    final refProvider = _createRefProvider(schemasPath);

    final schemaFiles = {
      'close': 'close.schema.json',
      'definitions': 'definitions.json',
      'offering': 'offering.schema.json',
      'message': 'message.schema.json',
      'order': 'order.schema.json',
      'orderstatus': 'orderstatus.schema.json',
      'quote': 'quote.schema.json',
      'resource': 'resource.schema.json',
      'rfq': 'rfq.schema.json',
      'rfqPrivate': 'rfq-private.schema.json',
    };

    for (final entry in schemaFiles.entries) {
      final filePath = p.join(schemasPath, entry.value);
      final schemaJsonString = File(filePath).readAsStringSync();
      final schemaJson = json.decode(schemaJsonString);

      _schemaMap[entry.key] =
          JsonSchema.create(schemaJson, refProvider: refProvider);
    }
  }

  static RefProvider _createRefProvider(String schemasPath) {
    final schemaJson = json.decode(
      File(p.join(schemasPath, 'definitions.json')).readAsStringSync(),
    );

    return RefProvider.sync(
      (ref) => ref == 'https://tbdex.dev/definitions.json' ? schemaJson : null,
    );
  }
}
