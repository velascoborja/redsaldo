import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/selected_product_preference.dart';

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _selectedProductKey = 'selectedProduct';
  static const _weeklyLimitKey = 'weeklyLimit';

  double get weeklyLimit => _prefs.getDouble(_weeklyLimitKey) ?? 55;

  SelectedProductPreference? get selectedProduct {
    final raw = _prefs.getString(_selectedProductKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return SelectedProductPreference.fromJson(
      jsonDecode(raw) as Map<String, Object?>,
    );
  }

  Future<void> saveWeeklyLimit(double value) {
    return _prefs.setDouble(_weeklyLimitKey, value);
  }

  Future<void> saveSelectedProduct(SelectedProductPreference product) {
    return _prefs.setString(_selectedProductKey, jsonEncode(product.toJson()));
  }

  Future<void> clearSelectedProduct() {
    return _prefs.remove(_selectedProductKey);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_selectedProductKey);
    await _prefs.remove(_weeklyLimitKey);
  }
}
