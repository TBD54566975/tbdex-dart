import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tbdex/src/http_client/models/exchange.dart';
import 'package:tbdex/src/http_client/tbdex_http_client.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:test/test.dart';

import '../test_data.dart';

class MockClient extends Mock implements http.Client {}

void main() async {
  late MockClient mockHttpClient;
  await TestData.initializeDids();

  group('TbdexHttpClient', () {
    setUp(() {
      mockHttpClient = MockClient();
      TbdexHttpClient.client = mockHttpClient;
    });

    setUpAll(() {
      registerFallbackValue(Uri());
    });

    test('can get offerings', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(TestData.getOfferingResponse(), 200),
      );

      final offerings = await TbdexHttpClient.getOfferings(TestData.pfiDid.uri);

      expect(offerings, isA<List<Offering>>());
    });

    test('can get exchange', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(TestData.getExchangeResponse(), 200),
      );

      final offerings = await TbdexHttpClient.getExchange(
        TestData.pfiDid,
        TestData.aliceDid.uri,
        'exchange_id',
      );

      expect(offerings, isA<Exchange>());
    });

    test('can get exchanges', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
        (_) async => http.Response(TestData.getExchangesResponse(), 200),
      );

      final offerings = await TbdexHttpClient.getExchanges(
        TestData.pfiDid,
        TestData.aliceDid.uri,
      );

      expect(offerings, isA<List<Exchange>>());
    });

    test('can create exchange', () async {
      final rfq = TestData.getRfq();
      await rfq.sign(TestData.aliceDid);
      final request =
          TestData.getCreateExchangeRequest(rfq, replyTo: 'reply_to');

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('', 201),
      );

      await TbdexHttpClient.createExchange(rfq, replyTo: 'reply_to');

      final captured = verify(
        () => mockHttpClient.post(
          captureAny(),
          headers: captureAny(named: 'headers'),
          body: captureAny(named: 'body'),
        ),
      ).captured;

      expect(captured[0].toString(), contains('/exchanges'));
      expect(captured[1], {'Content-Type': 'application/json'});
      expect(captured[2], equals(request));
    });

    test('can submit order', () async {
      final order = TestData.getOrder();
      await order.sign(TestData.aliceDid);
      final request = TestData.getSubmitOrderRequest(order);

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('', 201),
      );

      await TbdexHttpClient.submitOrder(order);

      final captured = verify(
        () => mockHttpClient.post(
          captureAny(),
          headers: captureAny(named: 'headers'),
          body: captureAny(named: 'body'),
        ),
      ).captured;

      expect(captured[0].toString(), contains('/exchanges'));
      expect(captured[1], {'Content-Type': 'application/json'});
      expect(captured[2], equals(request));
    });

    test('can submit close', () async {
      final close = TestData.getClose();
      await close.sign(TestData.aliceDid);
      final request = TestData.getSubmitCloseRequest(close);

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('', 201),
      );

      await TbdexHttpClient.submitClose(close);

      final captured = verify(
        () => mockHttpClient.post(
          captureAny(),
          headers: captureAny(named: 'headers'),
          body: captureAny(named: 'body'),
        ),
      ).captured;

      expect(captured[0].toString(), contains('/exchanges'));
      expect(captured[1], {'Content-Type': 'application/json'});
      expect(captured[2], equals(request));
    });
  });
}
