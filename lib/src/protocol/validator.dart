import 'dart:convert';

import 'package:json_schema/json_schema.dart';
import 'package:path/path.dart' as p;
import 'package:tbdex/src/protocol/exceptions.dart';
import 'package:tbdex/src/protocol/json_schemas/cancel_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/close_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/definitions_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/message_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/offering_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/order_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/orderinstructions_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/orderstatus_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/quote_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/resource_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/rfq_private_schema.dart';
import 'package:tbdex/src/protocol/json_schemas/rfq_schema.dart';
import 'package:tbdex/src/protocol/models/cancel.dart';
import 'package:tbdex/src/protocol/models/close.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/order_instructions.dart';
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
        (throw TbdexValidatorException(
          TbdexExceptionCode.validatorNoSchema,
          'no schema with name $schemaName exists',
        ));
    final validationResult = schema.validate(json);

    if (!validationResult.isValid) {
      _handleValidationError(validationResult.errors);
    }
  }

  void _validateMessage(Message message) {
    final matchedKind = MessageKind.values.firstWhere(
      (kind) => kind == message.metadata.kind,
      orElse: () => throw TbdexValidatorException(
        TbdexExceptionCode.validatorUnknownMessageKind,
        'unknown message kind: ${message.metadata.kind}',
      ),
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
      case MessageKind.cancel:
        final cancel = message as Cancel;
        _instance._validate(cancel.toJson(), 'message');
        _instance._validate(cancel.data.toJson(), cancel.metadata.kind.name);
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
      case MessageKind.orderinstructions:
        final orderInstructions = message as OrderInstructions;
        _instance._validate(orderInstructions.toJson(), 'message');
        _instance._validate(
          orderInstructions.data.toJson(),
          orderInstructions.metadata.kind.name,
        );
    }
  }

  void _validateResource(Resource resource) {
    final matchedKind = ResourceKind.values.firstWhere(
      (kind) => kind == resource.metadata.kind,
      orElse: () => throw TbdexValidatorException(
        TbdexExceptionCode.validatorUnknownResourceKind,
        'unknown resource kind: ${resource.metadata.kind}',
      ),
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
      throw TbdexValidatorException(
        TbdexExceptionCode.validatorJsonSchemaError,
        errors.join(', '),
      );
    }
  }

  static void _initialize() {
    final schemasPath = p.join('lib', 'src', 'protocol', 'json_schemas');
    final refProvider = _createRefProvider(schemasPath);

    _schemaMap['cancel'] =
        JsonSchema.create(CancelSchema.json, refProvider: refProvider);
    _schemaMap['close'] =
        JsonSchema.create(CloseSchema.json, refProvider: refProvider);
    _schemaMap['definitions'] =
        JsonSchema.create(DefinitionsSchema.json, refProvider: refProvider);
    _schemaMap['offering'] =
        JsonSchema.create(OfferingSchema.json, refProvider: refProvider);
    _schemaMap['message'] =
        JsonSchema.create(MessageSchema.json, refProvider: refProvider);
    _schemaMap['order'] =
        JsonSchema.create(OrderSchema.json, refProvider: refProvider);
    _schemaMap['orderinstructions'] = JsonSchema.create(
      OrderinstructionsSchema.json,
      refProvider: refProvider,
    );
    _schemaMap['orderstatus'] =
        JsonSchema.create(OrderstatusSchema.json, refProvider: refProvider);
    _schemaMap['quote'] =
        JsonSchema.create(QuoteSchema.json, refProvider: refProvider);
    _schemaMap['resource'] =
        JsonSchema.create(ResourceSchema.json, refProvider: refProvider);
    _schemaMap['rfq'] =
        JsonSchema.create(RfqSchema.json, refProvider: refProvider);
    _schemaMap['rfqPrivate'] =
        JsonSchema.create(RfqPrivateSchema.json, refProvider: refProvider);
  }

  static RefProvider _createRefProvider(String schemasPath) {
    final schemaJson = json.decode(DefinitionsSchema.json);

    return RefProvider.sync(
      (ref) => ref == 'https://tbdex.dev/definitions.json' ? schemaJson : null,
    );
  }
}
