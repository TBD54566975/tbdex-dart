import 'dart:convert';

import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/resource_data.dart';
import 'package:web5/web5.dart';

class TestData {
  static const String alice = 'alice';
  static const String pfi = 'pfi';

  static final _aliceKeyManager = InMemoryKeyManager();
  static final _pfiKeyManager = InMemoryKeyManager();

  static late final BearerDid aliceDid;
  static late final BearerDid pfiDid;

  static Future<void> initializeDids() async {
    aliceDid = await DidJwk.create(keyManager: _aliceKeyManager);
    pfiDid = await DidJwk.create(keyManager: _pfiKeyManager);
  }

  static Offering getOffering() {
    return Offering.create(
      pfiDid.uri,
      OfferingData(
        description: 'A sample offering',
        payoutUnitsPerPayinUnit: '1',
        payinCurrency: CurrencyDetails(
          currencyCode: 'AUD',
          minAmount: '0.01',
          maxAmount: '100.00',
        ),
        payoutCurrency: CurrencyDetails(currencyCode: 'USDC'),
        payinMethods: [
          PaymentMethod(
            kind: 'BTC_ADDRESS',
            requiredPaymentDetails: requiredPaymentDetailsSchema(),
          ),
        ],
        payoutMethods: [
          PaymentMethod(
            kind: 'MOMO',
            requiredPaymentDetails: requiredPaymentDetailsSchema(),
          ),
        ],
      ),
    );
  }

  static Map<String, dynamic> requiredPaymentDetailsSchema() {
    return jsonDecode(r'''
  {
    "$schema": "http://json-schema.org/draft-07/schema",
    "additionalProperties": false,
    "type": "object",
    "properties": {
      "phoneNumber": {
        "minLength": 12,
        "pattern": "^+2547[0-9]{8}$",
        "description": "Mobile Money account number of the Recipient",
        "type": "string",
        "title": "Phone Number",
        "maxLength": 12
      }
    },
    "required": [
      "accountNumber"
    ]
  }
  ''');
  }
}
