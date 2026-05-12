import 'product.dart';

class WeekRange {
  const WeekRange({
    required this.startUtc,
    required this.endUtc,
    required this.label,
  });

  final DateTime startUtc;
  final DateTime endUtc;
  final String label;

  bool contains(DateTime valueUtc) {
    final value = valueUtc.toUtc();
    return !value.isBefore(startUtc) && !value.isAfter(endUtc);
  }
}

class WeeklyBudgetSummary {
  const WeeklyBudgetSummary({
    required this.weeklyLimit,
    required this.weeklySpend,
    required this.remaining,
    required this.range,
    required this.transactions,
  });

  final double weeklyLimit;
  final double weeklySpend;
  final double remaining;
  final WeekRange range;
  final List<DomainTransaction> transactions;
}
