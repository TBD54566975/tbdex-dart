import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:path/path.dart' as p;

class Validator {
  static final Map<String, JsonSchema> _schemaMap = {};

  static Future<void> initialize() async {
    final schemasPath = p.join('tbdex', 'hosted', 'json-schemas');
    final refProvider = await _createRefProvider(schemasPath);

    var schemaFiles = {
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
      var schemaName = entry.key;
      var filename = entry.value;
      final filePath = p.join(schemasPath, filename);

      var schemaJsonString = await File(filePath).readAsString();
      var schemaJson = json.decode(schemaJsonString);

      _schemaMap[schemaName] =
          JsonSchema.create(schemaJson, refProvider: refProvider);
    }
  }

  static void validate(Map<String, dynamic> json, String schemaName) {
    final schema = _schemaMap[schemaName];
    if (schema == null) {
      throw Exception('no schema with name $schemaName exists');
    }
    final validationResult = schema.validate(json);
    if (validationResult.isValid == false) {
      _handleValidationError(validationResult.errors);
    }
  }

  static Future<RefProvider> _createRefProvider(String schemasPath) async {
    final schemaJson = json.decode(
      await File(p.join(schemasPath, 'definitions.json')).readAsString(),
    );

    return RefProvider.sync(
      (ref) => ref == 'https://tbdex.dev/definitions.json' ? schemaJson : null,
    );
  }

  static void _handleValidationError(List<ValidationError> errors) {
    if (errors.isNotEmpty) {
      throw Exception(errors.join(', '));
    }
  }
}
