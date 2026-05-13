import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../domain/models/product.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/theme.dart';
import '../../app_shell/app_view_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.controller, super.key});

  final AppViewModel controller;

  @override
  Widget build(BuildContext context) {
    // summary.transactions is the current-week slice; controller.transactions is the full unfiltered fetch
    final transactions = controller.summary?.transactions ?? [];

    return transactions.isEmpty
        ? _EmptyState()
        : SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.refreshDashboard,
              color: EdenredColors.redAlert,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Text(
                    AppLocalizations.of(context).recentSpending,
                    style: Theme.of(context).textTheme.headlineLarge,
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

// ── Transaction Card ──────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final DomainTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isTopUp = transaction.amount >= 0;
    final dayLabel = intl.DateFormat('EEE').format(transaction.dateUtc.toLocal());
    final displayName = transaction.businessName.isNotEmpty
        ? transaction.businessName
        : transaction.description;

    final sign = isTopUp ? '+' : '';
    final amountText = '$sign${transaction.amount.toStringAsFixed(2)} EUR';
    final amountColor = isTopUp ? EdenredColors.slateLight : EdenredColors.navyDark;

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
        children: [
          _TransactionIcon(isTopUp: isTopUp),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: tt.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                    if (isTopUp) ...[
                      const SizedBox(width: 6),
                      _NotCountedBadge(),
                    ],
                  ],
                ),
              ],
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
    );
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
