import 'dart:convert';

import 'package:json_schema/json_schema.dart';
import 'package:tbdex/src/http_client/models/create_exchange_request.dart';
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
              kind: 'DEBIT_CARD',
              requiredPaymentDetails: requiredPaymentDetailsSchema(),
            ),
          ],
        ),
        payout: PayoutDetails(
          currencyCode: 'USDC',
          methods: [
            PayoutMethod(
              estimatedSettlementTime: 0,
              kind: 'DEBIT_CARD',
              requiredPaymentDetails: requiredPaymentDetailsSchema(),
            ),
          ],
        ),
      ),
    );
  }

  static Rfq getRfq({
    String? offeringId,
    String? amount,
    String? payinKind,
    String? payoutKind,
  }) {
    return Rfq.create(
      pfiDid.uri,
      aliceDid.uri,
      RfqData(
        offeringId: offeringId ?? TypeId.generate(ResourceKind.offering.name),
        payin: SelectedPayinMethod(
          amount: amount ?? '100',
          kind: payinKind ?? 'DEBIT_CARD',
        ),
        payout: SelectedPayoutMethod(
          kind: payoutKind ?? 'DEBIT_CARD',
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

  static String getOfferingResponse() {
    final offering = TestData.getOffering();
    final mockOfferings = [offering];
    return jsonEncode({'data': mockOfferings.map((e) => e.toJson()).toList()});
  }

  static String getExchangeResponse() {
    final offering = TestData.getOffering();
    final rfq = TestData.getRfq(offeringId: offering.metadata.id);
    final quote = TestData.getQuote();
    final mockExchange = [rfq, quote];

    final jsonData = mockExchange.map((message) {
      if (message is Rfq) {
        return message.toJson();
      } else if (message is Quote) {
        return message.toJson();
      }
    }).toList();

    return jsonEncode({'data': jsonData});
  }

  static String getExchangesResponse() {
    final offering = TestData.getOffering();
    final rfq = TestData.getRfq(offeringId: offering.metadata.id);
    final quote = TestData.getQuote();

    final mockExchanges = [
      [rfq, quote],
      [rfq, quote],
    ];

    final jsonData = mockExchanges
        .map(
          (exchangeList) => exchangeList.map((message) {
            if (message is Rfq) {
              return message.toJson();
            } else if (message is Quote) {
              return message.toJson();
            }
          }).toList(),
        )
        .toList();

    return jsonEncode({'data': jsonData});
  }

  static String getCreateExchangeRequest(Rfq rfq, {String? replyTo}) =>
      jsonEncode(CreateExchangeRequest(rfq: rfq, replyTo: replyTo));

  static String getSubmitOrderRequest(Order order) =>
      jsonEncode(order.toJson());

  static String getSubmitCloseRequest(Close close) =>
      jsonEncode(close.toJson());

  static JsonSchema requiredPaymentDetailsSchema() {
    return JsonSchema.create(
      jsonDecode(r'''
        {
          "$schema": "http://json-schema.org/draft-07/schema#",
          "type": "object",
          "properties": {
            "cardNumber": {
              "type": "string",
              "description": "The 16-digit debit card number",
              "minLength": 16,
              "maxLength": 16
            },
            "expiryDate": {
              "type": "string",
              "description": "The expiry date of the card in MM/YY format",
              "pattern": "^(0[1-9]|1[0-2])\\/([0-9]{2})$"
            },
            "cardHolderName": {
              "type": "string",
              "description": "Name of the cardholder as it appears on the card"
            },
            "cvv": {
              "type": "string",
              "description": "The 3-digit CVV code",
              "minLength": 3,
              "maxLength": 3
            }
          },
          "required": ["cardNumber", "expiryDate", "cardHolderName", "cvv"],
          "additionalProperties": false
        }
    '''),
    );
  }
}
