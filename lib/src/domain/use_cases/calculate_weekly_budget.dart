import 'package:timezone/timezone.dart' as tz;

import '../models/product.dart';
import '../models/weekly_budget.dart';

const _monthAbbrevs = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

WeekRange currentMadridWeek(DateTime nowUtc) {
  final madrid = tz.getLocation('Europe/Madrid');
  final madridNow = tz.TZDateTime.from(nowUtc.toUtc(), madrid);
  final todayStart = tz.TZDateTime(
    madrid,
    madridNow.year,
    madridNow.month,
    madridNow.day,
  );
  final startLocal = todayStart.subtract(
    Duration(days: madridNow.weekday - DateTime.monday),
  );
  final endLocal = startLocal
      .add(const Duration(days: 7))
      .subtract(const Duration(milliseconds: 1));
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
  required List<DomainTransaction> transactions,
}) {
  final range = currentMadridWeek(nowUtc);
  final inWeek = transactions
      .where((transaction) => range.contains(transaction.dateUtc))
      .toList(growable: false);
  final spend = inWeek
      .where((transaction) => transaction.amount < 0)
      .fold<double>(
        0,
        (total, transaction) => total + transaction.amount.abs(),
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
