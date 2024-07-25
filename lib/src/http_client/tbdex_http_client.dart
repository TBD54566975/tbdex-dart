import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tbdex/src/http_client/models/submit_cancel_request.dart';
import 'package:tbdex/src/http_client/models/submit_close_request.dart';
import 'package:tbdex/src/http_client/models/submit_order_request.dart';
import 'package:tbdex/tbdex.dart';
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

  static Future<Exchange> getExchange(
    BearerDid did,
    String pfiDid,
    String exchangeId,
  ) async {
    final requestToken = await _generateRequestToken(did, pfiDid);
    final headers = {'Authorization': 'Bearer $requestToken'};

    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final url = Uri.parse('$pfiServiceEndpoint/exchanges/$exchangeId');

    http.Response response;
    try {
      response = await _client.get(url, headers: headers);

      if (response.statusCode != 200) {
        throw ResponseError(
          message: 'failed to get exchange',
          status: response.statusCode,
          body: response.body,
        );
      }
    } on Exception catch (e) {
      if (e is ResponseError) rethrow;

      throw RequestError(
        message: 'failed to send get exchange request',
        url: url.toString(),
        cause: e,
      );
    }

    Exchange exchange;
    try {
      exchange = Parser.parseExchange(response.body);
    } on Exception catch (e) {
      throw ValidationError(
        message: 'failed to parse exchange',
        cause: e,
      );
    }

    return exchange;
  }

  static Future<List<String>> listExchanges(
    BearerDid did,
    String pfiDid,
  ) async {
    final requestToken = await _generateRequestToken(did, pfiDid);
    final headers = {'Authorization': 'Bearer $requestToken'};

    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final url = Uri.parse('$pfiServiceEndpoint/exchanges/');

    http.Response response;
    try {
      response = await _client.get(url, headers: headers);

      if (response.statusCode != 200) {
        throw ResponseError(
          message: 'failed to list exchange',
          status: response.statusCode,
          body: response.body,
        );
      }
    } on Exception catch (e) {
      if (e is ResponseError) rethrow;

      throw RequestError(
        message: 'failed to send list exchange request',
        url: url.toString(),
        cause: e,
      );
    }

    List<String> exchanges;
    try {
      exchanges = Parser.parseExchanges(response.body);
    } on Exception catch (e) {
      throw ValidationError(
        message: 'failed to parse exchange ids',
        cause: e,
      );
    }

    return exchanges;
  }

  static Future<List<Offering>> listOfferings(
    String pfiDid, {
    GetOfferingsFilter? filter,
  }) async {
    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final url = Uri.parse('$pfiServiceEndpoint/offerings/').replace(
      queryParameters: filter?.toJson(),
    );

    http.Response response;
    try {
      response = await _client.get(url);

      if (response.statusCode != 200) {
        throw ResponseError(
          message: 'failed to list offerings',
          status: response.statusCode,
          body: response.body,
        );
      }
    } on Exception catch (e) {
      if (e is ResponseError) rethrow;

      throw RequestError(
        message: 'failed to send list offerings request',
        url: url.toString(),
        cause: e,
      );
    }

    List<Offering> offerings;
    try {
      offerings = Parser.parseOfferings(response.body);
    } on Exception catch (e) {
      throw ValidationError(
        message: 'failed to parse offerings',
        cause: e,
      );
    }

    return offerings;
  }

  static Future<List<Balance>> listBalances(
    BearerDid did,
    String pfiDid,
  ) async {
    final requestToken = await _generateRequestToken(did, pfiDid);
    final headers = {'Authorization': 'Bearer $requestToken'};
    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final url = Uri.parse('$pfiServiceEndpoint/balances/');

    http.Response response;
    try {
      response = await _client.get(url, headers: headers);

      if (response.statusCode != 200) {
        throw ResponseError(
          message: 'failed to list balances',
          status: response.statusCode,
          body: response.body,
        );
      }
    } on Exception catch (e) {
      if (e is ResponseError) rethrow;

      throw RequestError(
        message: 'failed to send list balances request',
        url: url.toString(),
        cause: e,
      );
    }

    List<Balance> balances;
    try {
      balances = Parser.parseBalances(response.body);
    } on Exception catch (e) {
      throw ValidationError(
        message: 'failed to parse balances',
        cause: e,
      );
    }

    return balances;
  }

  static Future<void> createExchange(
    Rfq rfq, {
    String? replyTo,
  }) async {
    try {
      Validator.validateMessage(rfq);
    } on Exception catch (e) {
      throw ValidationError(message: 'invalid rfq message', cause: e);
    }

    final pfiDid = rfq.metadata.to;
    final body = jsonEncode(CreateExchangeRequest(rfq: rfq, replyTo: replyTo));

    await _submitMessage(pfiDid, body);
  }

  static Future<void> submitOrder(Order order) async {
    try {
      Validator.validateMessage(order);
    } on Exception catch (e) {
      throw ValidationError(message: 'invalid order message', cause: e);
    }

    final pfiDid = order.metadata.to;
    final exchangeId = order.metadata.exchangeId;
    final body = jsonEncode(SubmitOrderRequest(order: order));

    await _submitMessage(pfiDid, body, exchangeId: exchangeId);
  }

  static Future<void> submitClose(Close close) async {
    try {
      Validator.validateMessage(close);
    } on Exception catch (e) {
      throw ValidationError(message: 'invalid close message', cause: e);
    }

    final pfiDid = close.metadata.to;
    final exchangeId = close.metadata.exchangeId;
    final body = jsonEncode(SubmitCloseRequest(close: close));

    await _submitMessage(pfiDid, body, exchangeId: exchangeId);
  }

  static Future<void> submitCancel(Cancel cancel) async {
    try {
      Validator.validateMessage(cancel);
    } on Exception catch (e) {
      throw ValidationError(message: 'invalid cancel message', cause: e);
    }

    final pfiDid = cancel.metadata.to;
    final exchangeId = cancel.metadata.exchangeId;
    final body = jsonEncode(SubmitCancelRequest(cancel: cancel));

    await _submitMessage(pfiDid, body, exchangeId: exchangeId);
  }

  static Future<void> _submitMessage(
    String pfiDid,
    String requestBody, {
    String? exchangeId,
  }) async {
    final headers = {'Content-Type': _jsonHeader};

    final pfiServiceEndpoint = await _getPfiServiceEndpoint(pfiDid);
    final path = '/exchanges${exchangeId != null ? '/$exchangeId' : ''}';
    final url = Uri.parse(pfiServiceEndpoint + path);

    http.Response response;
    try {
      response = await (exchangeId == null
          ? _client.post(url, headers: headers, body: requestBody)
          : _client.put(url, headers: headers, body: requestBody));

      if (response.statusCode != 202) {
        throw ResponseError(
          message: exchangeId != null
              ? 'failed to create exchange'
              : 'failed to submit message',
          status: response.statusCode,
          body: response.body,
        );
      }
    } on Exception catch (e) {
      if (e is ResponseError) rethrow;

      throw RequestError(
        message: exchangeId != null
            ? 'failed to send create exchange request'
            : 'failed to send submit message request',
        url: url.toString(),
        cause: e,
      );
    }
  }

  static Future<String> _getPfiServiceEndpoint(String pfiDid) async {
    DidResolutionResult didResolutionResult;
    try {
      didResolutionResult = await DidResolver.resolve(pfiDid, options: _client);

      if (didResolutionResult.didDocument == null) {
        throw Exception(didResolutionResult.didResolutionMetadata.error);
      }
    } on Exception catch (e) {
      throw InvalidDidError(
        message: 'pfi did resolution failed',
        cause: e,
      );
    }

    List<String> pfiServiceEndpoints;
    try {
      final service = didResolutionResult.didDocument?.service?.firstWhere(
        (service) => service.type == 'PFI',
        orElse: () =>
            throw Exception('pfi did does not have service of type PFI'),
      );

      pfiServiceEndpoints = service?.serviceEndpoint ?? [];

      if (pfiServiceEndpoints.isEmpty) {
        throw Exception('no PFI service endpoints found');
      }
    } on Exception catch (e) {
      throw MissingServiceEndpointError(
        message: 'pfi service endpoint missing',
        cause: e,
      );
    }

    return pfiServiceEndpoints.first;
  }

  static Future<String> _generateRequestToken(
    BearerDid did,
    String pfiDid,
  ) async {
    final nowEpochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = nowEpochSeconds + _expirationDuration.inSeconds;

    String requestToken;
    try {
      requestToken = await Jwt.sign(
        did: did,
        payload: JwtClaims(
          aud: pfiDid,
          iss: did.uri,
          exp: exp,
          iat: nowEpochSeconds,
          jti: TypeId.generate(''),
        ),
      );
    } on Exception catch (e) {
      throw RequestTokenError(
        message: 'failed to sign request token',
        cause: e,
      );
    }
    return requestToken;
  }
}

class TbdexResponse<T> {
  final T? data;
  final int statusCode;

  TbdexResponse({required this.statusCode, this.data});
}
