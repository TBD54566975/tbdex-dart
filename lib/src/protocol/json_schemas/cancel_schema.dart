class CancelSchema {
  static const String json = r'''
  {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "https://tbdex.dev/cancel.schema.json",
    "type": "object",
    "additionalProperties": false,
    "properties": {
      "reason": {
        "type": "string"
      }
    }
  }''';
}