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
  const pfiServiceEndpoint = 'http://localhost:8892/ingress/pfi';

  late MockClient client;
  late MockHttpHeaders headers;
  late MockHttpRequest request;
  late MockHttpResponse response;
  await TestData.initializeDids();

  group('TbdexHttpClient', () {
    setUp(() {
      client = MockClient();
      headers = MockHttpHeaders();
      request = MockHttpRequest();
      response = MockHttpResponse();

      TbdexHttpClient.client = client;
    });

    test('can get exchange', () async {
      when(() => request.headers).thenReturn(headers);
      when(() => request.close()).thenAnswer((_) async => response);

      when(() => response.statusCode).thenReturn(200);
      when(() => response.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(TestData.getExchangeResponse()));

      when(
        () => client
            .getUrl(Uri.parse('$pfiServiceEndpoint/exchanges/exchange_id')),
      ).thenAnswer((_) async => request);

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
      when(() => request.headers).thenReturn(headers);
      when(() => request.close()).thenAnswer((_) async => response);

      when(() => response.statusCode).thenReturn(200);
      when(() => response.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(TestData.getExchangesResponse()));

      when(
        () => client.getUrl(Uri.parse('$pfiServiceEndpoint/exchanges/')),
      ).thenAnswer((_) async => request);

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
      when(() => request.close()).thenAnswer((_) async => response);

      when(() => response.statusCode).thenReturn(200);
      when(() => response.transform(utf8.decoder))
          .thenAnswer((_) => Stream.value(TestData.getOfferingResponse()));

      when(
        () => client.getUrl(Uri.parse('$pfiServiceEndpoint/offerings/')),
      ).thenAnswer((_) async => request);

      final offerings = await TbdexHttpClient.getOfferings(pfiDid);

      expect(offerings.length, 1);

      verify(
        () => client.getUrl(Uri.parse('$pfiServiceEndpoint/offerings/')),
      ).called(1);
    });

    test('can create exchange', () async {
      final rfq = TestData.getRfq(to: pfiDid);
      await rfq.sign(TestData.aliceDid);
      request
          .write(TestData.getCreateExchangeRequest(rfq, replyTo: 'reply_to'));

      when(() => request.headers).thenReturn(headers);
      when(() => request.close()).thenAnswer((_) async => response);

      when(() => response.statusCode).thenReturn(201);
      when(() => response.transform(utf8.decoder)).thenAnswer(
        (_) => Stream.value(
          '',
        ),
      );

      when(
        () => client.postUrl(Uri.parse('$pfiServiceEndpoint/exchanges')),
      ).thenAnswer((_) async => request);

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

      request.write(TestData.getSubmitOrderRequest(order));

      when(() => request.headers).thenReturn(headers);
      when(() => request.close()).thenAnswer((_) async => response);

      when(() => response.statusCode).thenReturn(201);
      when(() => response.transform(utf8.decoder)).thenAnswer(
        (_) => Stream.value(''),
      );

      when(
        () => client
            .postUrl(Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId')),
      ).thenAnswer((_) async => request);

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

      request.write(TestData.getSubmitCloseRequest(close));

      when(() => request.headers).thenReturn(headers);
      when(() => request.close()).thenAnswer((_) async => response);

      when(() => response.statusCode).thenReturn(201);
      when(() => response.transform(utf8.decoder)).thenAnswer(
        (_) => Stream.value(''),
      );

      when(
        () => client
            .postUrl(Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId')),
      ).thenAnswer((_) async => request);

      await TbdexHttpClient.submitClose(close);

      verify(
        () => client.postUrl(
          Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId'),
        ),
      ).called(1);
    });
  });
}
