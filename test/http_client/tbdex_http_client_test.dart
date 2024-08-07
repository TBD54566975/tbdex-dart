import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tbdex/src/http_client/exceptions/http_exceptions.dart';
import 'package:tbdex/src/http_client/tbdex_http_client.dart';
import 'package:test/test.dart';

import '../helpers/mocks.dart';
import '../helpers/test_data.dart';

void main() async {
  const pfiDid = 'did:web:localhost%3A8892:ingress';
  const didUrl = 'http://localhost:8892/ingress/did.json';
  const pfiServiceEndpoint = 'http://localhost:8892/ingress/pfi';

  const didDoc =
      '''{"id":"did:web:localhost%3A8892:ingress","verificationMethod":[{"id":"#0","type":"JsonWebKey","controller":"did:web:localhost%3A8892:ingress","publicKeyJwk":{"kty":"OKP","crv":"Ed25519","x":"oQ6Nl6pZjDa0I2MIsPV7q7aXX7moneoIC0XprR6ull8"}}],"service":[{"id":"#pfi","type":"PFI","serviceEndpoint":["http://localhost:8892/ingress/pfi"]}]}''';

  late MockHttpClient mockHttpClient;

  await TestData.initializeDids();

  group('TbdexHttpClient', () {
    setUp(() {
      mockHttpClient = MockHttpClient();
      TbdexHttpClient.client = mockHttpClient;

      when(
        () => mockHttpClient.get(Uri.parse(didUrl)),
      ).thenAnswer((_) async => http.Response(didDoc, 200));
    });

    test('can get exchange', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/exchanges/1234'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(TestData.getExchangeResponse(), 200),
      );

      final response =
          await TbdexHttpClient.getExchange(TestData.aliceDid, pfiDid, '1234');
      expect(response.length, 2);

      verify(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/exchanges/1234'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('get exchange throws ResponseError', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/exchanges/1234'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('Error', 400),
      );

      expect(
        () async => TbdexHttpClient.getExchange(
          TestData.aliceDid,
          pfiDid,
          '1234',
        ),
        throwsA(isA<ResponseError>()),
      );
    });

    test('can list exchanges', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/exchanges/'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(TestData.listExchangesResponse(), 200),
      );

      final response =
          await TbdexHttpClient.listExchanges(TestData.aliceDid, pfiDid);
      expect(response.length, 3);

      verify(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/exchanges/'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('list exchanges throws ResponseError', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/exchanges/'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('Error', 400),
      );

      expect(
        () async => TbdexHttpClient.listExchanges(TestData.aliceDid, pfiDid),
        throwsA(isA<ResponseError>()),
      );
    });

    test('can list offerings', () async {
      when(
        () => mockHttpClient.get(Uri.parse('$pfiServiceEndpoint/offerings/')),
      ).thenAnswer(
        (_) async => http.Response(TestData.getOfferingResponse(), 200),
      );

      final response = await TbdexHttpClient.listOfferings(pfiDid);
      expect(response.length, 1);

      verify(
        () => mockHttpClient.get(Uri.parse('$pfiServiceEndpoint/offerings/')),
      ).called(1);
    });

    test('list offerings throws ResponseError', () async {
      when(
        () => mockHttpClient.get(Uri.parse('$pfiServiceEndpoint/offerings/')),
      ).thenAnswer(
        (_) async => http.Response('Error', 400),
      );

      expect(
        () async => TbdexHttpClient.listOfferings(pfiDid),
        throwsA(isA<ResponseError>()),
      );
    });

    test('can list balances', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/balances/'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(TestData.listBalancesResponse(), 200),
      );

      final response = await TbdexHttpClient.listBalances(TestData.aliceDid, pfiDid);
      expect(response.length, 1);

      verify(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/balances/'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('list balances throws ResponseError', () async {
      when(
        () => mockHttpClient.get(
          Uri.parse('$pfiServiceEndpoint/balances/'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('Error', 400),
      );

      expect(
        () async => TbdexHttpClient.listBalances(TestData.aliceDid, pfiDid),
        throwsA(isA<ResponseError>()),
      );
    });

    test('can create exchange', () async {
      final rfq = TestData.getRfq(to: pfiDid);
      await rfq.sign(TestData.aliceDid);

      when(
        () => mockHttpClient.post(
          Uri.parse('$pfiServiceEndpoint/exchanges'),
          headers: any(named: 'headers'),
          body: TestData.getCreateExchangeRequest(rfq, replyTo: 'reply_to'),
        ),
      ).thenAnswer(
        (_) async => http.Response('', 202),
      );

      await TbdexHttpClient.createExchange(rfq, replyTo: 'reply_to');

      verify(
        () => mockHttpClient.post(
          Uri.parse('$pfiServiceEndpoint/exchanges'),
          headers: any(named: 'headers'),
          body: TestData.getCreateExchangeRequest(rfq, replyTo: 'reply_to'),
        ),
      ).called(1);
    });

    test('create exchange throws ResponseError', () async {
      final rfq = TestData.getRfq(to: pfiDid);
      await rfq.sign(TestData.aliceDid);

      when(
        () => mockHttpClient.post(
          Uri.parse('$pfiServiceEndpoint/exchanges'),
          headers: any(named: 'headers'),
          body: TestData.getCreateExchangeRequest(rfq, replyTo: 'reply_to'),
        ),
      ).thenAnswer(
        (_) async => http.Response('Error', 400),
      );

      expect(
        () async => TbdexHttpClient.createExchange(rfq, replyTo: 'reply_to'),
        throwsA(isA<ResponseError>()),
      );
    });

    test('can submit order', () async {
      final order = TestData.getOrder(to: pfiDid);
      final exchangeId = order.metadata.exchangeId;
      await order.sign(TestData.aliceDid);

      when(
        () => mockHttpClient.put(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
          headers: any(named: 'headers'),
          body: TestData.getSubmitOrderRequest(order),
        ),
      ).thenAnswer(
        (_) async => http.Response('', 202),
      );

      await TbdexHttpClient.submitOrder(order);

      verify(
        () => mockHttpClient.put(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
          headers: any(named: 'headers'),
          body: TestData.getSubmitOrderRequest(order),
        ),
      ).called(1);
    });

    test('submit order throws ResponseError', () async {
      final order = TestData.getOrder(to: pfiDid);
      final exchangeId = order.metadata.exchangeId;
      await order.sign(TestData.aliceDid);

      when(
        () => mockHttpClient.put(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
          headers: any(named: 'headers'),
          body: TestData.getSubmitOrderRequest(order),
        ),
      ).thenAnswer(
        (_) async => http.Response('Error', 400),
      );

      expect(
        () async => TbdexHttpClient.submitOrder(order),
        throwsA(isA<ResponseError>()),
      );
    });

    test('can submit close', () async {
      final close = TestData.getClose(to: pfiDid);
      final exchangeId = close.metadata.exchangeId;
      await close.sign(TestData.aliceDid);

      when(
        () => mockHttpClient.put(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
          headers: any(named: 'headers'),
          body: TestData.getSubmitCloseRequest(close),
        ),
      ).thenAnswer(
        (_) async => http.Response('', 202),
      );

      await TbdexHttpClient.submitClose(close);

      verify(
        () => mockHttpClient.put(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
          headers: any(named: 'headers'),
          body: TestData.getSubmitCloseRequest(close),
        ),
      ).called(1);
    });

    test('submit close throws ResponseError', () async {
      final close = TestData.getClose(to: pfiDid);
      final exchangeId = close.metadata.exchangeId;
      await close.sign(TestData.aliceDid);

      when(
        () => mockHttpClient.put(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
          headers: any(named: 'headers'),
          body: TestData.getSubmitCloseRequest(close),
        ),
      ).thenAnswer(
        (_) async => http.Response('Error', 400),
      );

      expect(
        () async => TbdexHttpClient.submitClose(close),
        throwsA(isA<ResponseError>()),
      );
    });
  });
}
