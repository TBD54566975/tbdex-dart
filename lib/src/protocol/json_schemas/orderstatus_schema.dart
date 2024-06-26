class OrderstatusSchema {
  static const String json = r'''
  {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://tbdex.dev/orderstatus.schema.json",
  "type": "object",
  "required": [
    "orderStatus"
  ],
  "additionalProperties": false,
  "properties": {
    "orderStatus": {
      "type":"string"
    }
  }
}''';
}