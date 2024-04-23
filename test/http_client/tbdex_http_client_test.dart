import 'dart:convert';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:tbdex/src/http_client/tbdex_http_client.dart';
import 'package:test/test.dart';

import '../test_data.dart';

class MockClient extends Mock implements HttpClient {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

class MockHttpRequest extends Mock implements HttpClientRequest {}

class MockHttpResponse extends Mock implements HttpClientResponse {}

void main() async {
  const pfiDid = 'did:web:localhost%3A8892:ingress';
  const didUrl = 'http://localhost:8892/ingress/did.json';
  const pfiServiceEndpoint = 'http://localhost:8892/ingress/pfi';

  const didDoc =
      '''{"id":"did:web:localhost%3A8892:ingress","verificationMethod":[{"id":"#0","type":"JsonWebKey","controller":"did:web:localhost%3A8892:ingress","publicKeyJwk":{"kty":"OKP","crv":"Ed25519","x":"oQ6Nl6pZjDa0I2MIsPV7q7aXX7moneoIC0XprR6ull8"}}],"service":[{"id":"#pfi","type":"PFI","serviceEndpoint":["localhost:8892/ingress/pfi"]}]}''';

  late MockClient client;
  late MockHttpHeaders headers;

  late MockHttpRequest didRequest;
  late MockHttpResponse didResponse;

  late MockHttpRequest clientRequest;
  late MockHttpResponse clientResponse;

  await TestData.initializeDids();

  group('TbdexHttpClient', () {
    setUp(() {
      client = MockClient();
      headers = MockHttpHeaders();

      didRequest = MockHttpRequest();
      didResponse = MockHttpResponse();

      clientRequest = MockHttpRequest();
      clientResponse = MockHttpResponse();

      TbdexHttpClient.client = client;

      when(() => didResponse.statusCode).thenReturn(200);
      when(() => didResponse.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(didDoc));
      when(() => didRequest.close()).thenAnswer((_) async => didResponse);
      when(
        () => client.getUrl(Uri.parse(didUrl)),
      ).thenAnswer((_) async => didRequest);
    });

    test('can get exchange', () async {
      when(() => clientRequest.headers).thenReturn(headers);
      when(() => clientResponse.statusCode).thenReturn(200);
      when(() => clientResponse.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(TestData.getExchangeResponse()));
      when(() => clientRequest.close()).thenAnswer((_) async => clientResponse);
      when(
        () => client
            .getUrl(Uri.parse('$pfiServiceEndpoint/exchanges/exchange_id')),
      ).thenAnswer((_) async => clientRequest);

      final exchange = await TbdexHttpClient.getExchange(
        TestData.aliceDid,
        pfiDid,
        'exchange_id',
      );

      expect(exchange.length, 2);

      verify(
        () => client
            .getUrl(Uri.parse('$pfiServiceEndpoint/exchanges/exchange_id')),
      ).called(1);
    });

    test('can get exchanges', () async {
      when(() => clientRequest.headers).thenReturn(headers);
      when(() => clientResponse.statusCode).thenReturn(200);
      when(() => clientResponse.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(TestData.getExchangesResponse()));
      when(() => clientRequest.close()).thenAnswer((_) async => clientResponse);
      when(
        () => client.getUrl(Uri.parse('$pfiServiceEndpoint/exchanges/')),
      ).thenAnswer((_) async => clientRequest);

      final exchanges = await TbdexHttpClient.getExchanges(
        TestData.aliceDid,
        pfiDid,
      );

      expect(exchanges.length, 1);

      verify(
        () => client.getUrl(Uri.parse('$pfiServiceEndpoint/exchanges/')),
      ).called(1);
    });

    test('can get offerings', () async {
      when(() => clientResponse.statusCode).thenReturn(200);
      when(() => clientResponse.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(TestData.getOfferingResponse()));
      when(() => clientRequest.close()).thenAnswer((_) async => clientResponse);
      when(
        () => client.getUrl(Uri.parse('$pfiServiceEndpoint/offerings/')),
      ).thenAnswer((_) async => clientRequest);

      final offerings = await TbdexHttpClient.getOfferings(pfiDid);

      expect(offerings.length, 1);

      verify(
        () => client.getUrl(Uri.parse('$pfiServiceEndpoint/offerings/')),
      ).called(1);
    });

    test('can create exchange', () async {
      final rfq = TestData.getRfq(to: pfiDid);
      await rfq.sign(TestData.aliceDid);

      clientRequest
          .write(TestData.getCreateExchangeRequest(rfq, replyTo: 'reply_to'));
      when(() => clientRequest.headers).thenReturn(headers);
      when(() => clientResponse.statusCode).thenReturn(201);
      when(() => clientResponse.transform(utf8.decoder)).thenAnswer(
        (_) => Stream.value(''),
      );
      when(() => clientRequest.close()).thenAnswer((_) async => clientResponse);
      when(
        () => client.postUrl(Uri.parse('$pfiServiceEndpoint/exchanges')),
      ).thenAnswer((_) async => clientRequest);

      await TbdexHttpClient.createExchange(rfq, replyTo: 'reply_to');

      verify(
        () => client.postUrl(
          Uri.parse('$pfiServiceEndpoint/exchanges'),
        ),
      ).called(1);
    });

    test('can submit order', () async {
      final order = TestData.getOrder(to: pfiDid);
      final exchangeId = order.metadata.exchangeId;
      await order.sign(TestData.aliceDid);

      clientRequest.write(TestData.getSubmitOrderRequest(order));

      when(() => clientRequest.headers).thenReturn(headers);
      when(() => clientResponse.statusCode).thenReturn(201);
      when(() => clientResponse.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(''));
      when(() => clientRequest.close()).thenAnswer((_) async => clientResponse);

      when(
        () => client
            .postUrl(Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId')),
      ).thenAnswer((_) async => clientRequest);

      await TbdexHttpClient.submitOrder(order);

      verify(
        () => client.postUrl(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
        ),
      ).called(1);
    });

    test('can submit close', () async {
      final close = TestData.getClose(to: pfiDid);
      final exchangeId = close.metadata.exchangeId;
      await close.sign(TestData.aliceDid);

      clientRequest.write(TestData.getSubmitCloseRequest(close));
      when(() => clientRequest.headers).thenReturn(headers);
      when(() => clientResponse.statusCode).thenReturn(201);
      when(() => clientResponse.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(''));
      when(() => clientRequest.close()).thenAnswer((_) async => clientResponse);
      when(
        () => client
            .postUrl(Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId')),
      ).thenAnswer((_) async => clientRequest);

      await TbdexHttpClient.submitClose(close);

      verify(
        () => client.postUrl(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
        ),
      ).called(1);
    });
  });
}
