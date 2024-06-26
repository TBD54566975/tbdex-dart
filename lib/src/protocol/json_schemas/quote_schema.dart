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
        "amount": {
          "$ref": "definitions.json#/definitions/decimalString",
          "description": "The amount of currency expressed in the smallest respective unit"
        },
        "fee": {
          "$ref": "definitions.json#/definitions/decimalString",
          "description": "The amount paid in fees"
        },
        "paymentInstruction": {
          "$ref": "#/definitions/PaymentInstruction"
        }
      },
      "required": ["currencyCode", "amount"]
    },
    "PaymentInstruction": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "link": {
          "type": "string",
          "description": "Link to allow Alice to pay PFI, or be paid by the PFI"
        },
        "instruction": {
          "type": "string",
          "description": "Instruction on how Alice can pay PFI, or how Alice can be paid by the PFI"
        }
      }
    }
  },
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "expiresAt": {
      "type": "string",
      "description": "When this quote expires. Expressed as ISO8601"
    },
    "payin": {
      "$ref": "#/definitions/QuoteDetails"
    },
    "payout": {
      "$ref": "#/definitions/QuoteDetails"
    }
  },
  "required": ["expiresAt", "payin", "payout"]
}
''';
}