import 'dart:convert';

import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/message_data.dart';
import 'package:tbdex/src/protocol/models/quote.dart';
import 'package:test/test.dart';
import 'package:typeid/typeid.dart';

import '../../helpers/test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('Quote', () {
    test('can create a new quote', () {
      final quote = Quote.create(
        TestData.pfi,
        TestData.alice,
        TypeId.generate(MessageKind.rfq.name),
        QuoteData(
          expiresAt: '2022-01-01T00:00:00Z',
          payin: QuoteDetails(
            currencyCode: 'AUD',
            amount: '100',
            fee: '0.00',
          ),
          payout: QuoteDetails(
            currencyCode: 'BTC',
            amount: '0.12',
            fee: '0.00',
          ),
        ),
      );

      expect(quote.metadata.id, startsWith(MessageKind.quote.name));
      expect(quote.metadata.kind, equals(MessageKind.quote));
      expect(quote.metadata.protocol, equals('1.0'));
      expect(quote.data.payin.amount, equals('100'));
    });

    test('can parse and verify quote from a json string', () async {
      final quote = TestData.getQuote();
      await quote.sign(TestData.pfiDid);
      final json = jsonEncode(quote.toJson());
      final parsed = await Quote.parse(json);

      expect(parsed, isA<Quote>());
      expect(parsed.toString(), equals(json));
    });
  });
}
