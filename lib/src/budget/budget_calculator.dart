import 'package:timezone/timezone.dart' as tz;

import '../edenred/edenred_models.dart';

const _monthAbbrevs = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

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
  final List<EdenredTransaction> transactions;
}

WeekRange currentMadridWeek(DateTime nowUtc) {
  final madrid = tz.getLocation('Europe/Madrid');
  final madridNow = tz.TZDateTime.from(nowUtc.toUtc(), madrid);
  final todayStart = tz.TZDateTime(madrid, madridNow.year, madridNow.month, madridNow.day);
  final startLocal = todayStart.subtract(Duration(days: madridNow.weekday - DateTime.monday));
  final endLocal = startLocal.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
  String fmt(DateTime d) => '${d.day} ${_monthAbbrevs[d.month - 1]}';

  return WeekRange(
    startUtc: startLocal.toUtc(),
    endUtc: endLocal.toUtc(),
    label: '${fmt(startLocal)} - ${fmt(endLocal)}',
  );
}

WeeklyBudgetSummary calculateWeeklyBudget({
  required double weeklyLimit,
  required DateTime nowUtc,
  required List<EdenredTransaction> transactions,
}) {
  final range = currentMadridWeek(nowUtc);
  final inWeek = transactions.where((t) => range.contains(t.dateUtc)).toList(growable: false);
  final spend = inWeek.where((t) => t.amount < 0).fold<double>(
        0,
        (total, t) => total + t.amount.abs(),
      );
  final roundedSpend = roundCurrency(spend);

  return WeeklyBudgetSummary(
    weeklyLimit: roundCurrency(weeklyLimit),
    weeklySpend: roundedSpend,
    remaining: roundCurrency(weeklyLimit - roundedSpend),
    range: range,
    transactions: inWeek,
  );
}

double roundCurrency(double value) {
  return (value * 100).roundToDouble() / 100;
}
