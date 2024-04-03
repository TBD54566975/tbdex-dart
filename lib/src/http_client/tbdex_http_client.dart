import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tbdex/src/http_client/models/create_exchange_request.dart';
import 'package:tbdex/src/http_client/models/exchange.dart';
import 'package:tbdex/src/http_client/models/get_offerings_filter.dart';
import 'package:tbdex/src/protocol/models/close.dart';
import 'package:tbdex/src/protocol/models/offering.dart';
import 'package:tbdex/src/protocol/models/order.dart';
import 'package:tbdex/src/protocol/models/rfq.dart';
import 'package:tbdex/src/protocol/parser.dart';
import 'package:tbdex/src/protocol/validator.dart';
import 'package:typeid/typeid.dart';
import 'package:web5/web5.dart';

class TbdexHttpClient {
  static const String jsonHeader = 'application/json';
  static const _expirationDuration = Duration(minutes: 5);

  static http.Client _client = http.Client();

  // ignore: avoid_setters_without_getters
  static set client(http.Client client) {
    _client = client;
  }

  static Future<List<Offering>> getOfferings(
    String pfiDid, {
    GetOfferingsFilter? filter,
  }) async {
    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final baseUrl = Uri.parse('$pfiServiceEndpoint/offerings/');

    final url = Uri(
      scheme: baseUrl.scheme,
      host: baseUrl.host,
      path: baseUrl.path,
      queryParameters: filter?.toJson(),
    );
    final response = await _client.get(url);

    if (response.statusCode != 200) {
      throw Exception(response);
    }

    return Parser.parseOfferings(response.body);
  }

  static Future<Exchange> getExchange(
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

    if (response.statusCode != 200) {
      throw Exception('failed to fetch exchange: ${response.body}');
    }

    return Parser.parseExchange(response.body);
  }

  static Future<List<Exchange>> getExchanges(
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

    if (response.statusCode != 200) {
      throw Exception('failed to fetch exchanges: ${response.body}');
    }

    return Parser.parseExchanges(response.body);
  }

  static Future<void> createExchange(
    Rfq rfq, {
    String? replyTo,
  }) async {
    Validator.validateMessage(rfq);
    final pfiDid = rfq.metadata.to;
    final body = jsonEncode(
      CreateExchangeRequest(rfq: rfq, replyTo: replyTo),
    );

    await _submitMessage(pfiDid, body);
  }

  static Future<void> submitOrder(Order order) async {
    Validator.validateMessage(order);
    final pfiDid = order.metadata.to;
    final exchangeId = order.metadata.exchangeId;

    final body = jsonEncode(order.toJson());

    await _submitMessage(pfiDid, body, exchangeId: exchangeId);
  }

  static Future<void> submitClose(Close close) async {
    Validator.validateMessage(close);
    final pfiDid = close.metadata.to;
    final exchangeId = close.metadata.exchangeId;

    final body = jsonEncode(close.toJson());

    await _submitMessage(pfiDid, body, exchangeId: exchangeId);
  }

  static Future<void> _submitMessage(
    String pfiDid,
    String requestBody, {
    String? exchangeId,
  }) async {
    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final path = '/exchanges${exchangeId != null ? '/$exchangeId' : ''}';

    final url = Uri.parse(pfiServiceEndpoint + path);
    final response = await _client.post(
      url,
      headers: {'Content-Type': jsonHeader},
      body: requestBody,
    );

    if (response.statusCode != 201) {
      throw Exception(response);
    }
  }

  static Future<String> _getPfiServiceEndpoint(String pfiDid) async {
    final didResolutionResult = await DidResolver.resolve(pfiDid);

    if (didResolutionResult.didDocument == null) {
      throw Exception('did resolution failed');
    }

    final service = didResolutionResult.didDocument?.service?.firstWhere(
      (service) => service.type == 'PFI',
      orElse: () => throw Exception('did does not have service of type PFI'),
    );

    return service?.serviceEndpoint ?? '';
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