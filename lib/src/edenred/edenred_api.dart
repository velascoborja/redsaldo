import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/edenred_config.dart';
import '../state/app_gateways.dart';
import 'edenred_models.dart';

class EdenredApi implements AppEdenredGateway {
  EdenredApi(this._client);

  static const String _baseUrl = 'https://webservices.edenred.es/myedenred/v2';

  final http.Client _client;

  @override
  Future<List<EdenredProduct>> fetchProducts({required String accessToken}) async {
    final decoded = await _post(
      accessToken: accessToken,
      path: 'Products',
      fields: const <String, Object?>{
        'compatiblePlasticless': false,
        'devices': <Object?>[],
      },
    );

    return _normalizeArray(
      decoded,
      arrayKeys: const <String>['products'],
    ).map((item) => EdenredProduct.fromJson(item)).toList(growable: false);
  }

  @override
  Future<EdenredBalance> fetchBalance({required String accessToken, required int idTicket}) async {
    final decoded = await _post(
      accessToken: accessToken,
      path: 'ConsultaSaldo',
      fields: <String, Object?>{'idTicket': idTicket},
    );

    return EdenredBalance.fromJson(_normalizeObject(decoded));
  }

  @override
  Future<List<EdenredTransaction>> fetchTransactions({
    required String accessToken,
    required int idTicket,
  }) async {
    final decoded = await _post(
      accessToken: accessToken,
      path: 'HistoricoTransacciones',
      fields: <String, Object?>{'idTicket': idTicket, 'soloRecientes': '0'},
    );

    return _normalizeArray(
      decoded,
      arrayKeys: const <String>['transactions'],
    ).map((item) => EdenredTransaction.fromJson(item)).toList(growable: false);
  }

  Future<Object?> _post({
    required String accessToken,
    required String path,
    required Map<String, Object?> fields,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/$path'),
      headers: <String, String>{
        'authorization': 'Bearer $accessToken',
        'content-type': 'application/json; charset=UTF-8',
        'user-agent': 'okhttp/4.12.0',
      },
      body: jsonEncode(<String, Object?>{
        'objApp': <String, Object?>{
          'idioma': EdenredConfig.apiLanguage,
          'platform': EdenredConfig.platform,
          'version': EdenredConfig.appVersion,
          ...fields,
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw EdenredApiException(
        'Edenred API request failed with status ${response.statusCode}.',
      );
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const EdenredApiException(
        'Edenred API response was not valid JSON.',
      );
    }
  }

  static List<Map<String, dynamic>> _normalizeArray(
    Object? decoded, {
    required List<String> arrayKeys,
  }) {
    final array = _extractArray(decoded, arrayKeys);
    if (array == null) {
      throw const EdenredApiException(
        'Edenred API response did not contain a list.',
      );
    }

    return array
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }

          throw const EdenredApiException(
            'Edenred API response list contained a non-object item.',
          );
        })
        .toList(growable: false);
  }

  static List<Object?>? _extractArray(Object? decoded, List<String> arrayKeys) {
    if (decoded is List<Object?>) {
      return decoded;
    }
    if (decoded is List) {
      return List<Object?>.from(decoded);
    }
    if (decoded is Map<String, dynamic>) {
      for (final key in arrayKeys) {
        if (decoded.containsKey(key)) {
          final value = decoded[key];
          if (value is List<Object?>) {
            return value;
          }
          if (value is List) {
            return List<Object?>.from(value);
          }
        }
      }
      final response = decoded['response'];
      if (response is Map || response is List) {
        return _extractArray(response, arrayKeys);
      }
      final d = decoded['d'];
      if (d is Map || d is List) {
        return _extractArray(d, arrayKeys);
      }
    }
    if (decoded is Map) {
      return _extractArray(Map<String, dynamic>.from(decoded), arrayKeys);
    }

    return null;
  }

  static Map<String, dynamic> _normalizeObject(Object? decoded) {
    final unwrapped = _unwrapEnvelope(decoded);
    if (unwrapped is Map<String, dynamic>) {
      return unwrapped;
    }
    if (unwrapped is Map) {
      return Map<String, dynamic>.from(unwrapped);
    }

    throw const EdenredApiException(
      'Edenred API response did not contain an object.',
    );
  }

  static Object? _unwrapEnvelope(Object? decoded) {
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('response')) {
        return _unwrapEnvelope(decoded['response']);
      }
      if (decoded.containsKey('d')) {
        return _unwrapEnvelope(decoded['d']);
      }

      return decoded;
    }
    if (decoded is Map) {
      return _unwrapEnvelope(Map<String, dynamic>.from(decoded));
    }
    if (decoded is List<Object?>) {
      return decoded;
    }

    throw const EdenredApiException(
      'Edenred API response did not contain an object.',
    );
  }
}

class EdenredApiException implements Exception {
  const EdenredApiException(this.message);

  final String message;

  @override
  String toString() => 'EdenredApiException: $message';
}
