import 'dart:convert';

import 'package:tbdex/src/protocol/models/close.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/order_status.dart';
import 'package:tbdex/src/protocol/models/quote.dart';
import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/models/resource_data.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:typeid/typeid.dart';
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
        payin: PayinDetails(
          currencyCode: 'AUD',
          min: '0.01',
          max: '100.00',
          methods: [
            PayinMethod(
              kind: 'BTC_ADDRESS',
              requiredPaymentDetails: requiredPaymentDetailsSchema(),
            ),
          ],
        ),
        payout: PayoutDetails(
          currencyCode: 'USDC',
          methods: [
            PayoutMethod(
              estimatedSettlementTime: 0,
              kind: 'BANK',
              requiredPaymentDetails: requiredPaymentDetailsSchema(),
            ),
          ],
        ),
      ),
    );
  }

  static Rfq getRfq() {
    return Rfq.create(
      pfiDid.uri,
      aliceDid.uri,
      RfqData(
        offeringId: TypeId.generate(ResourceKind.offering.name),
        payin: SelectedPayinMethod(
          amount: '100',
          kind: 'BTC_ADDRESS',
        ),
        payout: SelectedPayoutMethod(
          kind: 'BANK',
        ),
        claims: [],
      ),
    );
  }

  static Quote getQuote() {
    return Quote.create(
      aliceDid.uri,
      pfiDid.uri,
      TypeId.generate(MessageKind.rfq.name),
      QuoteData(
        expiresAt: '2022-01-01T00:00:00Z',
        payin: QuoteDetails(
          currencyCode: 'AUD',
          amount: '100',
          fee: '0.01',
          paymentInstruction: PaymentInstruction(
            link: 'https://block.xyz',
            instruction: 'payin instruction',
          ),
        ),
        payout: QuoteDetails(
          currencyCode: 'BTC',
          amount: '0.12',
          fee: '0.02',
          paymentInstruction: PaymentInstruction(
            link: 'https://block.xyz',
            instruction: 'payout instruction',
          ),
        ),
      ),
    );
  }

  static Order getOrder() {
    return Order.create(
      aliceDid.uri,
      pfiDid.uri,
      TypeId.generate(MessageKind.rfq.name),
    );
  }

  static OrderStatus getOrderStatus() {
    return OrderStatus.create(
      aliceDid.uri,
      pfiDid.uri,
      TypeId.generate(MessageKind.rfq.name),
      OrderStatusData(orderStatus: 'order status'),
    );
  }

  static Close getClose() {
    return Close.create(
      aliceDid.uri,
      pfiDid.uri,
      TypeId.generate(MessageKind.rfq.name),
      CloseData(reason: 'reason'),
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
