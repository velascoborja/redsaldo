import 'package:edenred_55_app/src/budget/budget_calculator.dart';
import 'package:edenred_55_app/src/edenred/edenred_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('builds current Monday-Sunday range in Europe Madrid time', () {
    final range = currentMadridWeek(DateTime.utc(2026, 5, 6, 12));

    expect(range.startUtc, DateTime.utc(2026, 5, 3, 22));
    expect(range.endUtc, DateTime.utc(2026, 5, 10, 21, 59, 59, 999));
    expect(range.label, '4 May - 10 May');
  });

  test('counts only negative current-week transactions as spending', () {
    final summary = calculateWeeklyBudget(
      weeklyLimit: 55,
      nowUtc: DateTime.utc(2026, 5, 6, 12),
      transactions: <EdenredTransaction>[
        tx(amount: -12.34, dateUtc: DateTime.utc(2026, 5, 5, 10)),
        tx(amount: 20, dateUtc: DateTime.utc(2026, 5, 5, 11)),
        tx(amount: -3.21, dateUtc: DateTime.utc(2026, 4, 30, 10)),
      ],
    );

    expect(summary.weeklySpend, 12.34);
    expect(summary.remaining, 42.66);
    expect(summary.transactions.length, 2);
  });
}

EdenredTransaction tx({
  required double amount,
  required DateTime dateUtc,
}) {
  return EdenredTransaction(
    id: '',
    dateUtc: dateUtc,
    description: 'test',
    amount: amount,
    businessName: '',
    city: '',
    province: '',
  );
}
