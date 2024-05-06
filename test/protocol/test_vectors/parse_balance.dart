class ParseBalance {
  static const String vector = r'''
  {
  "description": "Balance parses from string",
  "input": "{\"metadata\":{\"from\":\"did:dht:3whftgpbdjihx9ze9tdn575zqzm4qwccetnf1ybiibuzad7rrmyy\",\"kind\":\"balance\",\"id\":\"balance_01hw25hn2pej6rdnd5qnh96wxj\",\"createdAt\":\"2024-04-22T05:48:01.494Z\",\"protocol\":\"1.0\"},\"data\":{\"currencyCode\":\"USD\",\"available\":\"400.00\"},\"signature\":\"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6M3doZnRncGJkamloeDl6ZTl0ZG41NzV6cXptNHF3Y2NldG5mMXliaWlidXphZDdycm15eSMwIn0..v6cJEJuEOjCes3-7UJvkyMgPRUk9dD3h_COfjSEQJiNMpQ7DOMTnFAVd-g_gsO4Y5FBqnKT8B9N86pFPoebNCQ\"}",
  "output": {
    "metadata": {
      "from": "did:dht:3whftgpbdjihx9ze9tdn575zqzm4qwccetnf1ybiibuzad7rrmyy",
      "kind": "balance",
      "id": "balance_01hw25hn2pej6rdnd5qnh96wxj",
      "createdAt": "2024-04-22T05:48:01.494Z",
      "protocol": "1.0"
    },
    "data": {
      "currencyCode": "USD",
      "available": "400.00"
    },
    "signature": "eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6M3doZnRncGJkamloeDl6ZTl0ZG41NzV6cXptNHF3Y2NldG5mMXliaWlidXphZDdycm15eSMwIn0..v6cJEJuEOjCes3-7UJvkyMgPRUk9dD3h_COfjSEQJiNMpQ7DOMTnFAVd-g_gsO4Y5FBqnKT8B9N86pFPoebNCQ"
  },
  "error": false
}''';
}