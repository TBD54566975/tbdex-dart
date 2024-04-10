import 'dart:convert';

import 'package:tbdex/src/http_client/models/exchange.dart';
import 'package:tbdex/src/protocol/models/message.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/quote.dart';
import 'package:tbdex/src/protocol/models/resource.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:tbdex/src/protocol/parser.dart';
import 'package:test/test.dart';

import '../test_data.dart';

void main() async {
  await TestData.initializeDids();

  group('Parser', () {
    test('can parse a message', () async {
      final rfq = TestData.getRfq();
      await rfq.sign(TestData.aliceDid);

      final json = jsonEncode(rfq.toJson());
      final parsed = Parser.parseMessage(json);

      expect(parsed, isA<Message>());
      expect(parsed, isA<Rfq>());
      expect(parsed.toString(), equals(json));
    });

    test('can parse a resource', () async {
      final offering = TestData.getOffering();
      final json = jsonEncode(offering.toJson());
      final parsed = Parser.parseResource(json);

      expect(parsed, isA<Resource>());
      expect(parsed, isA<Offering>());
      expect(parsed.toString(), equals(json));
    });

    test('can parse an exchange', () async {
      final rfq = TestData.getRfq();
      final quote = TestData.getQuote();
      final rfqJson = jsonEncode(rfq.toJson());
      final quoteJson = jsonEncode(quote.toJson());

      final exchange = Parser.parseExchange(
        jsonEncode({
          'data': [rfq, quote],
        }),
      );

      expect(exchange.first, isA<Rfq>());
      expect(exchange.last, isA<Quote>());
      expect(exchange.first.toString(), equals(rfqJson));
      expect(exchange.last.toString(), equals(quoteJson));
    });

    test('can parse a list of exchanges', () async {
      final rfq = TestData.getRfq();
      final quote = TestData.getQuote();
      final rfqJson = jsonEncode(rfq.toJson());
      final quoteJson = jsonEncode(quote.toJson());

      final exchanges = Parser.parseExchanges(
        jsonEncode({
          'data': [
            [rfq, quote],
            [rfq, quote],
          ],
        }),
      );

      expect(exchanges, isA<List<Exchange>>());
      expect(exchanges.first, isA<Exchange>());
      expect(exchanges.first.first, isA<Rfq>());
      expect(exchanges[1].last, isA<Quote>());
      expect(exchanges.first.first.toString(), equals(rfqJson));
      expect(exchanges[1].last.toString(), equals(quoteJson));
    });

    test('can parse a list of offerings', () async {
      final offering = TestData.getOffering();
      final offeringJson = jsonEncode(offering.toJson());

      final offerings = Parser.parseOfferings(
        jsonEncode({
          'data': [offering, offering],
        }),
      );

      expect(offerings.first, isA<Offering>());
      expect(offerings.last, isA<Offering>());
      expect(offerings.first.toString(), equals(offeringJson));
      expect(offerings.last.toString(), equals(offeringJson));
    });

    test('parse throws error if json is null', () {
      expect(
        () => Parser.parseMessage(jsonEncode(null)),
        throwsA(isA<Exception>()),
      );
    });

    test('parse throws error if json is empty', () {
      expect(
        () => Parser.parseMessage(jsonEncode({})),
        throwsA(isA<Exception>()),
      );
    });

    test('parse throws error if metadata does not exist', () {
      expect(
        () => Parser.parseMessage(jsonEncode({'fake': ''})),
        throwsA(isA<Exception>()),
      );
    });

    test('parse throws error if metadata is not a json', () {
      expect(
        () => Parser.parseMessage(jsonEncode({'metadata': ''})),
        throwsA(isA<Exception>()),
      );
    });

    test('parse throws error if metadata is empty', () {
      expect(
        () => Parser.parseMessage(
          jsonEncode({'metadata': {}}),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('parse throws error if kind does not exist', () {
      expect(
        () => Parser.parseMessage(
          jsonEncode({
            'metadata': {'fake': ''},
          }),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('parse throws error if kind is not a string', () {
      expect(
        () => Parser.parseMessage(
          jsonEncode({
            'metadata': {'kind': null},
          }),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
