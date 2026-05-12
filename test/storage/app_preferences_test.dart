import 'package:edenred_55_app/src/storage/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('weekly limit defaults to 55 euros', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = AppPreferences(await SharedPreferences.getInstance());

    expect(prefs.weeklyLimit, 55);
  });

  test('stores selected product and weekly limit', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = AppPreferences(await SharedPreferences.getInstance());

    await prefs.saveSelectedProduct(
      const SelectedProductPreference(
        idTicket: 123,
        label: 'Ticket Restaurant',
        active: true,
        status: 'ACTIVA',
      ),
    );
    await prefs.saveWeeklyLimit(40.5);

    expect(prefs.selectedProduct?.idTicket, 123);
    expect(prefs.selectedProduct?.label, 'Ticket Restaurant');
    expect(prefs.weeklyLimit, 40.5);
  });
}
