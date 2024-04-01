import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:path/path.dart' as p;

class Validator {
  factory Validator._internal() {
    _initialize();
    return Validator._();
  }

  static final Map<String, JsonSchema> _schemaMap = {};
  static final Validator _instance = Validator._internal();

  Validator._();

  static void validate(Map<String, dynamic> json, String schemaName) {
    _instance.validateJson(json, schemaName);
  }

  void validateJson(Map<String, dynamic> json, String schemaName) {
    final schema = _schemaMap[schemaName];
    if (schema == null) {
      throw Exception('no schema with name $schemaName exists');
    }
    final validationResult = schema.validate(json);
    if (validationResult.isValid == false) {
      _handleValidationError(validationResult.errors);
    }
  }

  void _handleValidationError(List<ValidationError> errors) {
    if (errors.isNotEmpty) {
      throw Exception(errors.join(', '));
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
