class ParseRfqOmitPrivateData {
  static const String vector = r'''
  {
  "description": "RFQ with privateData omitted parses from string",
  "input": "{\"metadata\":{\"from\":\"did:dht:qyac4pru9ykcxbrutpaaxkmususxh4wtc4ctt19813zrie8uyy5y\",\"to\":\"did:dht:3whftgpbdjihx9ze9tdn575zqzm4qwccetnf1ybiibuzad7rrmyy\",\"protocol\":\"1.0\",\"kind\":\"rfq\",\"id\":\"rfq_01hw25hn37fdcs0m21z3z1fr09\",\"exchangeId\":\"rfq_01hw25hn37fdcs0m21z3z1fr09\",\"createdAt\":\"2024-04-22T05:48:01.511Z\"},\"data\":{\"offeringId\":\"offering_01hw25hn36f0kstngeye3bytfh\",\"payin\":{\"kind\":\"DEBIT_CARD\",\"amount\":\"20000.00\",\"paymentDetailsHash\":\"E6z4pXvZKD3H7h66sMRNq3CDeEqqrsZDqK6E-PpIsrM\"},\"payout\":{\"kind\":\"BTC_ADDRESS\",\"paymentDetailsHash\":\"oynR-RqIJct-GlVyVc7Qqw3A9RQjT4wX44-tZmfrud4\"},\"claimsHash\":\"yqSdLDlRiRJkhTYJF7yqfliaX064uxb4am5r3MD1cWw\"},\"signature\":\"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6cXlhYzRwcnU5eWtjeGJydXRwYWF4a211c3VzeGg0d3RjNGN0dDE5ODEzenJpZTh1eXk1eSMwIn0..ePt0IG_SHKM8Dp-WIIUwVDSs-dIi7yoCboatmMRIW1orPCThK5YN-eQEC5oZFoByoYSiXskyUIHnkCkU_nh1BQ\"}",
  "output": {
    "metadata": {
      "from": "did:dht:qyac4pru9ykcxbrutpaaxkmususxh4wtc4ctt19813zrie8uyy5y",
      "to": "did:dht:3whftgpbdjihx9ze9tdn575zqzm4qwccetnf1ybiibuzad7rrmyy",
      "protocol": "1.0",
      "kind": "rfq",
      "id": "rfq_01hw25hn37fdcs0m21z3z1fr09",
      "exchangeId": "rfq_01hw25hn37fdcs0m21z3z1fr09",
      "createdAt": "2024-04-22T05:48:01.511Z"
    },
    "data": {
      "offeringId": "offering_01hw25hn36f0kstngeye3bytfh",
      "payin": {
        "kind": "DEBIT_CARD",
        "amount": "20000.00",
        "paymentDetailsHash": "E6z4pXvZKD3H7h66sMRNq3CDeEqqrsZDqK6E-PpIsrM"
      },
      "payout": {
        "kind": "BTC_ADDRESS",
        "paymentDetailsHash": "oynR-RqIJct-GlVyVc7Qqw3A9RQjT4wX44-tZmfrud4"
      },
      "claimsHash": "yqSdLDlRiRJkhTYJF7yqfliaX064uxb4am5r3MD1cWw"
    },
    "signature": "eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6cXlhYzRwcnU5eWtjeGJydXRwYWF4a211c3VzeGg0d3RjNGN0dDE5ODEzenJpZTh1eXk1eSMwIn0..ePt0IG_SHKM8Dp-WIIUwVDSs-dIi7yoCboatmMRIW1orPCThK5YN-eQEC5oZFoByoYSiXskyUIHnkCkU_nh1BQ"
  },
  "error": false
}''';
}