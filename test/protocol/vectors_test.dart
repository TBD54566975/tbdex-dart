import 'dart:convert';

import 'package:tbdex/tbdex.dart';
import 'package:test/test.dart';

import 'test_vectors/parse_close.dart';
import 'test_vectors/parse_offering.dart';
import 'test_vectors/parse_order.dart';
import 'test_vectors/parse_orderstatus.dart';
import 'test_vectors/parse_quote.dart';
import 'test_vectors/parse_rfq.dart';

void main() {
  group('Vectors', () {
    test('can parse offering test vector', () async {
      final json = jsonDecode(ParseOffering.vector) as Map<String, dynamic>;
      final parsed = await Offering.parse(json['input']);

      expect(parsed, isA<Offering>());
      expect(parsed.toJson(), equals(json['output']));
    });

    test('can parse rfq test vector', () async {
      final json = jsonDecode(ParseRfq.vector) as Map<String, dynamic>;
      final parsed = await Rfq.parse(json['input']);

      expect(parsed, isA<Rfq>());
      expect(parsed.toJson(), equals(json['output']));
    });

    test('can parse order test vector', () async {
      final json = jsonDecode(ParseOrder.vector) as Map<String, dynamic>;
      final parsed = await Order.parse(json['input']);

      expect(parsed, isA<Order>());
      expect(parsed.toJson(), equals(json['output']));
    });

    test('can parse orderstatus test vector', () async {
      final json = jsonDecode(ParseOrderstatus.vector) as Map<String, dynamic>;
      final parsed = await OrderStatus.parse(json['input']);

      expect(parsed, isA<OrderStatus>());
      expect(parsed.toJson(), equals(json['output']));
    });

    test('can parse quote test vector', () async {
      final json = jsonDecode(ParseQuote.vector) as Map<String, dynamic>;
      final parsed = await Quote.parse(json['input']);

      expect(parsed, isA<Quote>());
      expect(parsed.toJson(), equals(json['output']));
    });

    test('can parse close test vector', () async {
      final json = jsonDecode(ParseClose.vector) as Map<String, dynamic>;
      final parsed = await Close.parse(json['input']);

      expect(parsed, isA<Close>());
      expect(parsed.toJson(), equals(json['output']));
    });
  });
}
