String formatAmount(double value) {
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');
}

String formatEuros(double value) {
  return '${value.toStringAsFixed(2)} €';
}
