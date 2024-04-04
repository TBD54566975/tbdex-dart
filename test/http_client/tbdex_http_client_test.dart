import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tbdex/src/http_client/tbdex_http_client.dart';
import 'package:test/test.dart';

import '../test_data.dart';

class MockClient extends Mock implements http.Client {}

void main() async {
  const pfiDid = 'did:dht:74hg1efatndi8enx3e4z6c4u8ieh1xfkyay4ntg4dg1w6risu35y';
  const pfiServiceEndpoint = 'http://localhost:8892/ingress/pfi';

  late MockClient mockHttpClient;
  await TestData.initializeDids();

  group('TbdexHttpClient', () {
    setUp(() {
      mockHttpClient = MockClient();
      TbdexHttpClient.client = mockHttpClient;
    });

    test('can get exchange', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/exchanges/exchange_id'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(TestData.getExchangeResponse(), 200),
      );

      final exchange = await TbdexHttpClient.getExchange(
        TestData.aliceDid,
        pfiDid,
        'exchange_id',
      );

      expect(exchange.length, 2);

      verify(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/exchanges/exchange_id'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('can get exchanges', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/exchanges/'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(TestData.getExchangesResponse(), 200),
      );

      final exchanges = await TbdexHttpClient.getExchanges(
        TestData.aliceDid,
        pfiDid,
      );

      expect(exchanges.length, 1);

      verify(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/exchanges/'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('can get offerings', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/offerings/'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(TestData.getOfferingResponse(), 200),
      );

      final offerings = await TbdexHttpClient.getOfferings(pfiDid);

      expect(offerings.length, 1);

      verify(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/offerings/'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('can create exchange', () async {
      final rfq = TestData.getRfq(to: pfiDid);
      await rfq.sign(TestData.aliceDid);
      final request =
          TestData.getCreateExchangeRequest(rfq, replyTo: 'reply_to');

      when(
        () => mockHttpClient.post(
          Uri.parse('$pfiServiceEndpoint/exchanges'),
          headers: any(named: 'headers'),
          body: request,
        ),
      ).thenAnswer(
        (_) async => http.Response('', 201),
      );

      await TbdexHttpClient.createExchange(rfq, replyTo: 'reply_to');

      verify(
        () => mockHttpClient.post(
          Uri.parse('$pfiServiceEndpoint/exchanges'),
          headers: any(named: 'headers'),
          body: request,
        ),
      ).called(1);
    });

    test('can submit order', () async {
      final order = TestData.getOrder(to: pfiDid);
      final exchangeId = order.metadata.exchangeId;
      await order.sign(TestData.aliceDid);
      final request = TestData.getSubmitOrderRequest(order);

      when(
        () => mockHttpClient.post(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
          headers: any(named: 'headers'),
          body: request,
        ),
      ).thenAnswer(
        (_) async => http.Response('', 201),
      );

      await TbdexHttpClient.submitOrder(order);

      verify(
        () => mockHttpClient.post(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
          headers: any(named: 'headers'),
          body: request,
        ),
      ).called(1);
    });

    test('can submit close', () async {
      final close = TestData.getClose(to: pfiDid);
      final exchangeId = close.metadata.exchangeId;
      await close.sign(TestData.aliceDid);
      final request = TestData.getSubmitCloseRequest(close);

      when(
        () => mockHttpClient.post(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
          headers: any(named: 'headers'),
          body: request,
        ),
      ).thenAnswer(
        (_) async => http.Response('', 201),
      );

      await TbdexHttpClient.submitClose(close);

      verify(
        () => mockHttpClient.post(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
          headers: any(named: 'headers'),
          body: request,
        ),
      ).called(1);
    });
  });
}
