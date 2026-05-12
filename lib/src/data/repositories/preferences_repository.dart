import '../../domain/models/product.dart';
import '../models/selected_product_preference.dart';
import '../services/app_preferences_service.dart';

abstract class PreferencesRepository {
  double get weeklyLimit;

  SelectedProduct? get selectedProduct;

  Future<void> saveWeeklyLimit(double value);

  Future<void> saveSelectedProduct(SelectedProduct product);

  Future<void> clearSelectedProduct();

  Future<void> clearAll();
}

class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl({required AppPreferences preferences})
    : _preferences = preferences;

  final AppPreferences _preferences;

  @override
  double get weeklyLimit => _preferences.weeklyLimit;

  @override
  SelectedProduct? get selectedProduct {
    final product = _preferences.selectedProduct;
    if (product == null) {
      return null;
    }

    return SelectedProduct(
      idTicket: product.idTicket,
      label: product.label,
      active: product.active,
      status: product.status,
    );
  }

  @override
  Future<void> saveWeeklyLimit(double value) {
    return _preferences.saveWeeklyLimit(value);
  }

  @override
  Future<void> saveSelectedProduct(SelectedProduct product) {
    return _preferences.saveSelectedProduct(
      SelectedProductPreference(
        idTicket: product.idTicket,
        label: product.label,
        active: product.active,
        status: product.status,
      ),
    );
  }

  @override
  Future<void> clearSelectedProduct() {
    return _preferences.clearSelectedProduct();
  }

  @override
  Future<void> clearAll() {
    return _preferences.clearAll();
  }
}
