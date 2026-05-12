import 'package:edenred_55_app/src/edenred/edenred_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EdenredProduct', () {
    test('requires idTicket and prefers ProductTypeDescription for label', () {
      final product = EdenredProduct.fromJson({
        'idTicket': 123,
        'active': true,
        'estado': 'ACTIVA',
        'productType': {
          'ProductTypeDescription': 'Ticket Restaurant',
          'description': 'Fallback description',
        },
        'cardNumber': '4111111111111111',
        'name': 'Private Person',
      });

      expect(product.idTicket, 123);
      expect(product.label, 'Ticket Restaurant');
      expect(product.active, isTrue);
      expect(product.status, 'ACTIVA');
    });

    test('falls back through product type description and generated label', () {
      expect(
        EdenredProduct.fromJson({
          'idTicket': 55,
          'productType': {'description': 'Transport'},
        }).label,
        'Transport',
      );
      expect(
        EdenredProduct.fromJson({'idTicket': 123}).label,
        'Edenred product 123',
      );
    });

    test('throws when idTicket is missing or invalid', () {
      expect(
        () => EdenredProduct.fromJson({'productType': {}}),
        throwsA(isA<EdenredModelException>()),
      );
      expect(
        () => EdenredProduct.fromJson({'idTicket': 'not numeric'}),
        throwsA(isA<EdenredModelException>()),
      );
    });
  });

  group('EdenredBalance', () {
    test('parses balance or saldo numeric values to double', () {
      expect(EdenredBalance.fromJson({'balance': 12}).amount, 12.0);
      expect(EdenredBalance.fromJson({'saldo': '34.56'}).amount, 34.56);
    });

    test('defaults invalid or missing balance to zero', () {
      expect(EdenredBalance.fromJson({}).amount, 0);
      expect(EdenredBalance.fromJson({'balance': 'not numeric'}).amount, 0);
    });
  });

  group('EdenredTransaction', () {
    test('parses transaction variants and misspelled business name', () {
      final transaction = EdenredTransaction.fromJson({
        'idTransaccion': 987,
        'fecha': '2026-05-11T10:15:30+02:00',
        'description': 'Lunch',
        'amount': '-10.25',
        'bussinessName': 'Cafe Central',
        'city': 'Madrid',
        'province': 'Madrid',
      });

      expect(transaction.id, '987');
      expect(transaction.dateUtc, DateTime.utc(2026, 5, 11, 8, 15, 30));
      expect(transaction.description, 'Lunch');
      expect(transaction.amount, -10.25);
      expect(transaction.businessName, 'Cafe Central');
      expect(transaction.city, 'Madrid');
      expect(transaction.province, 'Madrid');
    });

    test('uses id fallback and default strings', () {
      final transaction = EdenredTransaction.fromJson({'id': 'tx-1'});

      expect(transaction.id, 'tx-1');
      expect(
        transaction.dateUtc,
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
      expect(transaction.description, '');
      expect(transaction.amount, 0);
      expect(transaction.businessName, '');
      expect(transaction.city, '');
      expect(transaction.province, '');
    });
  });

  group('parseEdenredDate', () {
    test('handles Unix milliseconds and .NET ticks', () {
      expect(
        parseEdenredDate(1715421600000),
        DateTime.fromMillisecondsSinceEpoch(1715421600000, isUtc: true),
      );
      expect(
        parseEdenredDate(639138614980000000),
        DateTime.fromMillisecondsSinceEpoch(1778264698000, isUtc: true),
      );
    });

    test('handles ISO strings and returns Unix epoch for invalid values', () {
      expect(
        parseEdenredDate('2026-05-11T10:15:30+02:00'),
        DateTime.utc(2026, 5, 11, 8, 15, 30),
      );
      expect(
        parseEdenredDate('not a date'),
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
      expect(
        parseEdenredDate(null),
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
    });
  });
}
