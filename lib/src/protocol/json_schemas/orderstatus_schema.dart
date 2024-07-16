class OrderstatusSchema {
  static const String json = r'''
  {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://tbdex.dev/orderstatus.schema.json",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "status": {
      "type":"string",
      "enum": [
        "PAYIN_PENDING", 
        "PAYIN_INITIATED", 
        "PAYIN_SETTLED", 
        "PAYIN_FAILED", 
        "PAYIN_EXPIRED",
        "PAYOUT_PENDING", 
        "PAYOUT_INITIATED", 
        "PAYOUT_SETTLED", 
        "PAYOUT_FAILED", 
        "REFUND_PENDING", 
        "REFUND_INITIATED", 
        "REFUND_SETTLED", 
        "REFUND_FAILED"
      ]
    },
    "details": {
      "type":"string"
    }
  },
  "required": ["status"]
}''';
}