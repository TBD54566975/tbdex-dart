class ParseQuote {
  static const String vector = r'''
  {
  "description": "Quote parses from string",
  "input": "{\"metadata\":{\"exchangeId\":\"rfq_01hw25hn2te5rt4c6fnkb877xg\",\"from\":\"did:dht:3whftgpbdjihx9ze9tdn575zqzm4qwccetnf1ybiibuzad7rrmyy\",\"to\":\"did:dht:qyac4pru9ykcxbrutpaaxkmususxh4wtc4ctt19813zrie8uyy5y\",\"protocol\":\"1.0\",\"kind\":\"quote\",\"id\":\"quote_01hw25hn2vfd0944t9xp7jbx0t\",\"createdAt\":\"2024-04-22T05:48:01.499Z\"},\"data\":{\"expiresAt\":\"2024-04-22T05:48:01.499Z\",\"payin\":{\"currencyCode\":\"BTC\",\"amount\":\"0.01\",\"fee\":\"0.0001\",\"paymentInstruction\":{\"link\":\"tbdex.io/example\",\"instruction\":\"Fake instruction\"}},\"payout\":{\"currencyCode\":\"USD\",\"amount\":\"1000.00\",\"paymentInstruction\":{\"link\":\"tbdex.io/example\",\"instruction\":\"Fake instruction\"}}},\"signature\":\"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6M3doZnRncGJkamloeDl6ZTl0ZG41NzV6cXptNHF3Y2NldG5mMXliaWlidXphZDdycm15eSMwIn0..sHQBr_s8EEx81hf4I8-qaY_ya4wWtE_wN93YY5-y22bG9RyiX4PAnwJUQJewa8STrK-M38yVNQDaBnqs1O9WAQ\"}",
  "output": {
    "metadata": {
      "exchangeId": "rfq_01hw25hn2te5rt4c6fnkb877xg",
      "from": "did:dht:3whftgpbdjihx9ze9tdn575zqzm4qwccetnf1ybiibuzad7rrmyy",
      "to": "did:dht:qyac4pru9ykcxbrutpaaxkmususxh4wtc4ctt19813zrie8uyy5y",
      "protocol": "1.0",
      "kind": "quote",
      "id": "quote_01hw25hn2vfd0944t9xp7jbx0t",
      "createdAt": "2024-04-22T05:48:01.499Z"
    },
    "data": {
      "expiresAt": "2024-04-22T05:48:01.499Z",
      "payin": {
        "currencyCode": "BTC",
        "amount": "0.01",
        "fee": "0.0001",
        "paymentInstruction": {
          "link": "tbdex.io/example",
          "instruction": "Fake instruction"
        }
      },
      "payout": {
        "currencyCode": "USD",
        "amount": "1000.00",
        "paymentInstruction": {
          "link": "tbdex.io/example",
          "instruction": "Fake instruction"
        }
      }
    },
    "signature": "eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6M3doZnRncGJkamloeDl6ZTl0ZG41NzV6cXptNHF3Y2NldG5mMXliaWlidXphZDdycm15eSMwIn0..sHQBr_s8EEx81hf4I8-qaY_ya4wWtE_wN93YY5-y22bG9RyiX4PAnwJUQJewa8STrK-M38yVNQDaBnqs1O9WAQ"
  },
  "error": false
}''';
}