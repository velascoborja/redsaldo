import 'dart:convert';

import 'package:edenred_55_app/src/data/repositories/preferences_repository.dart';
import 'package:edenred_55_app/src/data/services/app_preferences_service.dart';
import 'package:edenred_55_app/src/domain/models/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'maps selected product and weekly limit through persisted keys',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final sharedPreferences = await SharedPreferences.getInstance();
      final repository = PreferencesRepositoryImpl(
        preferences: AppPreferences(sharedPreferences),
      );

      await repository.saveWeeklyLimit(42.5);
      await repository.saveSelectedProduct(
        const SelectedProduct(
          idTicket: 123,
          label: 'Ticket Restaurant',
          active: true,
          status: 'ACTIVA',
        ),
      );

      final rawProduct = sharedPreferences.getString('selectedProduct');
      final decoded = jsonDecode(rawProduct!) as Map<String, Object?>;

      expect(sharedPreferences.getDouble('weeklyLimit'), 42.5);
      expect(decoded['idTicket'], 123);
      expect(decoded['label'], 'Ticket Restaurant');
      expect(decoded['active'], isTrue);
      expect(decoded['status'], 'ACTIVA');
      expect(repository.weeklyLimit, 42.5);
      expect(repository.selectedProduct?.idTicket, 123);
      expect(repository.selectedProduct?.label, 'Ticket Restaurant');
      expect(repository.selectedProduct?.active, isTrue);
      expect(repository.selectedProduct?.status, 'ACTIVA');
    },
  );
}
