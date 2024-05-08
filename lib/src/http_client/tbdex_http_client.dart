import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:tbdex/src/http_client/models/create_exchange_request.dart';
import 'package:tbdex/src/http_client/models/exchange.dart';
import 'package:tbdex/src/http_client/models/get_offerings_filter.dart';
import 'package:tbdex/src/http_client/models/submit_close_request.dart';
import 'package:tbdex/src/http_client/models/submit_order_request.dart';
import 'package:tbdex/src/protocol/models/close.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:tbdex/src/protocol/parser.dart';
import 'package:tbdex/src/protocol/validator.dart';
import 'package:typeid/typeid.dart';
import 'package:web5/web5.dart';

class TbdexHttpClient {
  TbdexHttpClient._();

  static const _jsonHeader = 'application/json';
  static const _expirationDuration = Duration(minutes: 5);

  static http.Client _client = http.Client();

  // ignore: avoid_setters_without_getters
  static set client(http.Client client) {
    _client = client;
  }

  static Future<TbdexResponse<Exchange?>> getExchange(
    BearerDid did,
    String pfiDid,
    String exchangeId,
  ) async {
    final requestToken = await _generateRequestToken(did, pfiDid);
    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final url = Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId');

    final response = await _client.get(
      url,
      headers: {
        'Authorization': 'Bearer $requestToken',
      },
    );

    return response.statusCode == 200
        ? TbdexResponse(
            data: Parser.parseExchange(response.body),
            statusCode: response.statusCode,
          )
        : TbdexResponse(statusCode: response.statusCode);
  }

  static Future<TbdexResponse<List<String>?>> listExchanges(
    BearerDid did,
    String pfiDid,
  ) async {
    final requestToken = await _generateRequestToken(did, pfiDid);
    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final url = Uri.parse('$pfiServiceEndpoint/exchanges/');

    final response = await _client.get(
      url,
      headers: {
        'Authorization': 'Bearer $requestToken',
      },
    );

    return response.statusCode == 200
        ? TbdexResponse(
            data: Parser.parseExchanges(response.body),
            statusCode: response.statusCode,
          )
        : TbdexResponse(statusCode: response.statusCode);
  }

  static Future<TbdexResponse<List<Offering>?>> listOfferings(
    String pfiDid, {
    GetOfferingsFilter? filter,
  }) async {
    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final url = Uri.parse('$pfiServiceEndpoint/offerings/').replace(
      queryParameters: filter?.toJson(),
    );

    final response = await _client.get(url);

    return response.statusCode == 200
        ? TbdexResponse(
            data: Parser.parseOfferings(response.body),
            statusCode: response.statusCode,
          )
        : TbdexResponse(statusCode: response.statusCode);
  }

  static Future<TbdexResponse<void>> createExchange(
    Rfq rfq, {
    String? replyTo,
  }) async {
    Validator.validateMessage(rfq);
    final pfiDid = rfq.metadata.to;
    final body = jsonEncode(CreateExchangeRequest(rfq: rfq, replyTo: replyTo));

    return _submitMessage(pfiDid, body);
  }

  static Future<TbdexResponse<void>> submitOrder(Order order) async {
    Validator.validateMessage(order);
    final pfiDid = order.metadata.to;
    final exchangeId = order.metadata.exchangeId;
    final body = jsonEncode(SubmitOrderRequest(order: order));

    return _submitMessage(pfiDid, body, exchangeId: exchangeId);
  }

  static Future<TbdexResponse<void>> submitClose(Close close) async {
    Validator.validateMessage(close);
    final pfiDid = close.metadata.to;
    final exchangeId = close.metadata.exchangeId;
    final body = jsonEncode(SubmitCloseRequest(close: close));

    return _submitMessage(pfiDid, body, exchangeId: exchangeId);
  }

  static Future<TbdexResponse<void>> _submitMessage(
    String pfiDid,
    String requestBody, {
    String? exchangeId,
  }) async {
    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final path = '/exchanges${exchangeId != null ? '/$exchangeId' : ''}';
    final url = Uri.parse(pfiServiceEndpoint + path);
    final headers = {'Content-Type': _jsonHeader};

    final response = await (exchangeId == null
        ? _client.post(url, headers: headers, body: requestBody)
        : _client.put(url, headers: headers, body: requestBody));

    return TbdexResponse(statusCode: response.statusCode);
  }

  static Future<String> _getPfiServiceEndpoint(String pfiDid) async {
    final didResolutionResult =
        await DidResolver.resolve(pfiDid, options: _client);

    if (didResolutionResult.didDocument == null) {
      throw Exception('did resolution failed');
    }

    final service = didResolutionResult.didDocument?.service?.firstWhere(
      (service) => service.type == 'PFI',
      orElse: () => throw Exception('did does not have service of type PFI'),
    );

    final endpoint = service?.serviceEndpoint ?? [];

    if (endpoint.isEmpty) {
      throw Exception('no service endpoints found');
    }
    return endpoint[0];
  }

  static Future<String> _generateRequestToken(
    BearerDid did,
    String pfiDid,
  ) async {
    final nowEpochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = nowEpochSeconds + _expirationDuration.inSeconds;

    return Jwt.sign(
      did: did,
      payload: JwtClaims(
        aud: pfiDid,
        iss: did.uri,
        exp: exp,
        iat: nowEpochSeconds,
        jti: TypeId.generate(''),
      ),
    );
  }
}

class TbdexResponse<T> {
  final T? data;
  final int statusCode;

  TbdexResponse({required this.statusCode, this.data});
}
