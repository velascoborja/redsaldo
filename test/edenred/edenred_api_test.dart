import 'dart:async';
import 'dart:convert';

import 'package:edenred_55_app/src/config/edenred_config.dart';
import 'package:edenred_55_app/src/data/services/edenred_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('EdenredApi', () {
    test('fetchProducts posts Edenred headers and objApp body', () async {
      final client = RecordingClient(
        (request) => http.Response(
          jsonEncode({
            'response': [
              {
                'idTicket': 1,
                'productType': {'ProductTypeDescription': 'Restaurant'},
              },
            ],
          }),
          200,
        ),
      );
      final api = EdenredApi(client);

      final products = await api.fetchProducts(accessToken: 'access-token');

      expect(products.single.idTicket, 1);
      expect(client.requests, hasLength(1));
      final request = client.requests.single;
      expect(
        request.url,
        Uri.parse('https://webservices.edenred.es/myedenred/v2/Products'),
      );
      expect(request.method, 'POST');
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(
        request.headers['content-type'],
        'application/json; charset=UTF-8',
      );
      expect(request.headers['user-agent'], 'okhttp/4.12.0');
      expect(jsonDecode(request.body), {
        'objApp': {
          'idioma': EdenredConfig.apiLanguage,
          'platform': EdenredConfig.platform,
          'version': EdenredConfig.appVersion,
          'compatiblePlasticless': false,
          'devices': [],
        },
      });
    });

    test('fetchBalance posts idTicket and normalizes d envelope', () async {
      final client = RecordingClient(
        (request) => http.Response(
          jsonEncode({
            'd': {'saldo': 45.67},
          }),
          200,
        ),
      );
      final api = EdenredApi(client);

      final balance = await api.fetchBalance(accessToken: 'token', idTicket: 2);

      expect(balance.amount, 45.67);
      expect(
        client.requests.single.url,
        Uri.parse('https://webservices.edenred.es/myedenred/v2/ConsultaSaldo'),
      );
      expect(jsonDecode(client.requests.single.body), {
        'objApp': {
          'idioma': EdenredConfig.apiLanguage,
          'platform': EdenredConfig.platform,
          'version': EdenredConfig.appVersion,
          'idTicket': 2,
        },
      });
    });

    test(
      'fetchTransactions posts soloRecientes string and normalizes arrays',
      () async {
        final client = RecordingClient(
          (request) => http.Response(
            jsonEncode({
              'd': {
                'response': [
                  {'id': 'tx-1', 'businessName': 'Shop', 'amount': 10},
                ],
              },
            }),
            200,
          ),
        );
        final api = EdenredApi(client);

        final transactions = await api.fetchTransactions(
          accessToken: 'token',
          idTicket: 3,
        );

        expect(transactions.single.id, 'tx-1');
        expect(
          client.requests.single.url,
          Uri.parse(
            'https://webservices.edenred.es/myedenred/v2/HistoricoTransacciones',
          ),
        );
        expect(jsonDecode(client.requests.single.body), {
          'objApp': {
            'idioma': EdenredConfig.apiLanguage,
            'platform': EdenredConfig.platform,
            'version': EdenredConfig.appVersion,
            'idTicket': 3,
            'soloRecientes': '0',
          },
        });
      },
    );

    test('normalizes top-level arrays', () async {
      final client = RecordingClient(
        (request) => http.Response(
          jsonEncode([
            {'idTicket': 1},
            {'idTicket': 2},
          ]),
          200,
        ),
      );
      final api = EdenredApi(client);

      final products = await api.fetchProducts(accessToken: 'token');

      expect(products.map((product) => product.idTicket), [1, 2]);
    });

    test('normalizes top-level products keyed arrays', () async {
      final client = RecordingClient(
        (request) => http.Response(
          jsonEncode({
            'products': [
              {'idTicket': 1},
            ],
          }),
          200,
        ),
      );
      final api = EdenredApi(client);

      final products = await api.fetchProducts(accessToken: 'token');

      expect(products.single.idTicket, 1);
    });

    test('uses top-level products when response is boolean metadata', () async {
      final client = RecordingClient(
        (request) => http.Response(
          jsonEncode({
            'error': {'errorCode': 0},
            'response': true,
            'products': [
              {'idTicket': 123},
            ],
          }),
          200,
        ),
      );
      final api = EdenredApi(client);

      final products = await api.fetchProducts(accessToken: 'token');

      expect(products.single.idTicket, 123);
    });

    test('normalizes top-level transactions keyed arrays', () async {
      final client = RecordingClient(
        (request) => http.Response(
          jsonEncode({
            'transactions': [
              {'id': 'tx-1'},
            ],
          }),
          200,
        ),
      );
      final api = EdenredApi(client);

      final transactions = await api.fetchTransactions(
        accessToken: 'token',
        idTicket: 3,
      );

      expect(transactions.single.id, 'tx-1');
    });

    test(
      'throws EdenredApiException for non-2xx and non-object JSON',
      () async {
        final failingApi = EdenredApi(
          RecordingClient((request) => http.Response('nope', 500)),
        );
        await expectLater(
          failingApi.fetchProducts(accessToken: 'token'),
          throwsA(isA<EdenredApiException>()),
        );

        final scalarApi = EdenredApi(
          RecordingClient((request) => http.Response('"nope"', 200)),
        );
        await expectLater(
          scalarApi.fetchProducts(accessToken: 'token'),
          throwsA(isA<EdenredApiException>()),
        );
      },
    );
  });
}

class RecordingClient extends http.BaseClient {
  RecordingClient(this._handler);

  final FutureOr<http.Response> Function(http.Request request) _handler;
  final List<http.Request> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final copied = _copyRequest(request as http.Request);
    requests.add(copied);
    final response = await _handler(copied);

    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
      reasonPhrase: response.reasonPhrase,
    );
  }

  http.Request _copyRequest(http.Request request) {
    final copied = http.Request(request.method, request.url)
      ..bodyBytes = request.bodyBytes;
    copied.headers.addAll(request.headers);
    return copied;
  }
}
