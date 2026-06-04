import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../data/models/token_models.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/edenred_repository.dart';
import '../../../../data/repositories/preferences_repository.dart';
import '../../../../domain/models/product.dart';
import '../../../../domain/models/weekly_budget.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/theme.dart';
import '../../app_shell/app_view_model.dart';

@Preview(
  name: 'History - Spanish portrait',
  group: 'History',
  size: Size(390, 844),
)
Widget historySpanishPortraitPreview() {
  return _historyPreviewApp(
    locale: const Locale('es'),
    controller: _historyPreviewController(
      transactions: _historyPreviewTransactions(),
    ),
  );
}

@Preview(
  name: 'History - English landscape',
  group: 'History',
  size: Size(844, 390),
)
Widget historyEnglishLandscapePreview() {
  return _historyPreviewApp(
    locale: const Locale('en'),
    controller: _historyPreviewController(
      transactions: _historyPreviewTransactions(),
    ),
  );
}

@Preview(name: 'History - Empty', group: 'History', size: Size(390, 844))
Widget historyEmptyPreview() {
  return _historyPreviewApp(
    locale: const Locale('en'),
    controller: _historyPreviewController(transactions: const []),
  );
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.controller, super.key});

  final AppViewModel controller;

  @override
  Widget build(BuildContext context) {
    // summary.transactions is the current-week slice; controller.transactions is the full unfiltered fetch
    final transactions = controller.summary?.transactions ?? [];
    final loc = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return transactions.isEmpty
        ? _EmptyState()
        : SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.refreshDashboard,
              color: EdenredColors.redAlert,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Text(loc.recentSpending, style: tt.headlineLarge),
                  const SizedBox(height: 8),
                  _WeekChip(label: controller.summary!.range.label),
                  const SizedBox(height: 4),
                  Text(
                    loc.showingThisWeekOnly,
                    style: tt.bodySmall?.copyWith(
                      color: EdenredColors.slateLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final t in transactions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TransactionCard(transaction: t),
                    ),
                ],
              ),
            ),
          );
  }
}

// ── Week Chip ─────────────────────────────────────────────────────────────────

class _WeekChip extends StatelessWidget {
  const _WeekChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFFF0EDEF),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: EdenredColors.redAlert,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: EdenredColors.navyDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction Card ──────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final DomainTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode;
    final isTopUp = transaction.amount >= 0;
    final dayLabel = intl.DateFormat(
      'EEE',
      locale,
    ).format(transaction.dateUtc.toLocal());
    final displayName = transaction.businessName.isNotEmpty
        ? transaction.businessName
        : transaction.description;
    final locationText = _transactionLocation(transaction);

    final sign = isTopUp ? '+' : '';
    final amountText = '$sign${transaction.amount.toStringAsFixed(2)} EUR';
    final amountColor = isTopUp
        ? EdenredColors.slateLight
        : EdenredColors.navyDark;

    return Container(
      decoration: const BoxDecoration(
        color: EdenredColors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TransactionIcon(isTopUp: isTopUp),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: tt.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      amountText,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dayLabel,
                      style: tt.bodySmall?.copyWith(
                        color: EdenredColors.slateLight,
                        height: 1.2,
                      ),
                    ),
                    if (!transaction.countsTowardLimit) ...[
                      const SizedBox(width: 6),
                      _NotCountedBadge(),
                    ],
                  ],
                ),
                if (locationText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    locationText,
                    style: tt.bodySmall?.copyWith(
                      color: EdenredColors.slateMuted,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _transactionLocation(DomainTransaction transaction) {
    final parts = <String>[
      transaction.city.trim(),
      transaction.province.trim(),
    ].where((part) => part.isNotEmpty).toList(growable: false);

    return parts.join(', ');
  }
}

class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({required this.isTopUp});

  final bool isTopUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFF0EDEF),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Icon(
        isTopUp ? Icons.account_balance : Icons.restaurant,
        size: 22,
        color: EdenredColors.navyDark,
      ),
    );
  }
}

class _NotCountedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: EdenredColors.slateLight),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(
        AppLocalizations.of(context).notCounted,
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: EdenredColors.slateLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EDEF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 36,
                  color: EdenredColors.slateLight,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                loc.noTransactionsTitle,
                style: tt.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.noTransactionsBody,
                style: tt.bodySmall?.copyWith(color: EdenredColors.slateLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

Widget _historyPreviewApp({
  required Locale locale,
  required AppViewModel controller,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: EdenredTheme.light(),
    home: Scaffold(
      backgroundColor: EdenredColors.grayLight,
      appBar: AppBar(
        backgroundColor: EdenredColors.white,
        foregroundColor: EdenredColors.navyDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Historial'),
        centerTitle: true,
      ),
      body: HistoryScreen(controller: controller),
    ),
  );
}

AppViewModel _historyPreviewController({
  required List<DomainTransaction> transactions,
}) {
  final controller = AppViewModel(
    auth: _HistoryPreviewAuth(),
    edenred: _HistoryPreviewEdenred(),
    preferences: _HistoryPreviewPreferences(),
  );
  controller.status = AppStatus.ready;
  controller.summary = WeeklyBudgetSummary(
    weeklyLimit: 55,
    weeklySpend: 55.6,
    remaining: 0,
    range: WeekRange(
      startUtc: DateTime.utc(2026, 6),
      endUtc: DateTime.utc(2026, 6, 7, 23, 59, 59, 999),
      label: '1 Jun - 7 Jun',
    ),
    transactions: transactions,
  );

  return controller;
}

List<DomainTransaction> _historyPreviewTransactions() {
  return <DomainTransaction>[
    DomainTransaction(
      id: 'tx-preview-1',
      dateUtc: DateTime.utc(2026, 6, 3, 12, 30),
      description: 'Restaurant',
      amount: -24,
      businessName: 'ABARZUA - C. CRISTO',
      city: '37, VILLANUEVA DE,28691,ESP,ESP',
      province: '',
      countsTowardLimit: true,
    ),
    DomainTransaction(
      id: 'tx-preview-2',
      dateUtc: DateTime.utc(2026, 6, 2, 19, 15),
      description: 'Restaurant',
      amount: -31,
      businessName: 'TILT AMUSEMENTS - C. REAL',
      city: '12, VILLANUEVA DE,28691,ESP,ESP',
      province: '',
      countsTowardLimit: true,
    ),
    DomainTransaction(
      id: 'tx-preview-3',
      dateUtc: DateTime.utc(2026, 6),
      description: 'Liquidación pendiente',
      amount: -0.60,
      businessName: 'Liquidación pendiente',
      city: '',
      province: '',
      countsTowardLimit: false,
    ),
    DomainTransaction(
      id: 'tx-preview-4',
      dateUtc: DateTime.utc(2026, 6),
      description: 'RECARGA',
      amount: 242,
      businessName: 'RECARGA',
      city: '',
      province: '',
      countsTowardLimit: false,
    ),
  ];
}

class _HistoryPreviewAuth implements AuthRepository {
  @override
  Future<TokenSession> exchangeCode({
    required String code,
    required String verifier,
  }) async {
    return TokenSession(
      accessToken: 'preview',
      expiresAtUtc: DateTime.utc(2027),
    );
  }

  @override
  Future<String> getValidAccessToken() async => 'preview';

  @override
  Future<TokenSession?> loadSession() async => null;

  @override
  Future<void> logout() async {}
}

class _HistoryPreviewEdenred implements EdenredRepository {
  @override
  Future<Balance> fetchBalance({
    required String accessToken,
    required int idTicket,
  }) async {
    return const Balance(amount: 242);
  }

  @override
  Future<List<Product>> fetchProducts({required String accessToken}) async {
    return const <Product>[];
  }

  @override
  Future<List<DomainTransaction>> fetchTransactions({
    required String accessToken,
    required int idTicket,
  }) async {
    return const <DomainTransaction>[];
  }
}

class _HistoryPreviewPreferences implements PreferencesRepository {
  @override
  SelectedProduct? get selectedProduct => const SelectedProduct(
    idTicket: 1,
    label: 'Ticket Restaurant',
    active: true,
    status: '',
  );

  @override
  double get weeklyLimit => 55;

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> clearSelectedProduct() async {}

  @override
  Future<void> saveSelectedProduct(SelectedProduct product) async {}

  @override
  Future<void> saveWeeklyLimit(double value) async {}
}
