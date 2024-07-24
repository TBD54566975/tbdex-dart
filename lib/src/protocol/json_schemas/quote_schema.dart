class QuoteSchema {
  static const String json = r'''
  {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://tbdex.dev/quote.schema.json",
  "definitions": {
    "QuoteDetails": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "currencyCode": {
          "type": "string",
          "description": "ISO 4217 currency code string"
        },
        "subtotal": {
          "$ref": "definitions.json#/definitions/decimalString",
          "description": "The amount of currency paid for the exchange, excluding fees"
        },
        "fee": {
          "$ref": "definitions.json#/definitions/decimalString",
          "description": "The amount of currency paid in fees"
        },
        "total": {
          "$ref": "definitions.json#/definitions/decimalString",
          "description": "The total amount of currency to be paid in or paid out. It is always a sum of subtotal and fee"
        }
      },
      "required": ["currencyCode", "subtotal", "total"]
    }
  },
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "expiresAt": {
      "type": "string",
      "description": "When this quote expires. Expressed as ISO8601"
    },
    "payoutUnitsPerPayinUnit": {
      "type": "string",
      "description": "The exchange rate to convert from payin currency to payout currency. Expressed as an unrounded decimal string."
    },
    "payin": {
      "$ref": "#/definitions/QuoteDetails"
    },
    "payout": {
      "$ref": "#/definitions/QuoteDetails"
    }
  },
  "required": ["expiresAt", "payoutUnitsPerPayinUnit", "payin", "payout"]
}
''';
}