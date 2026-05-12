import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme.dart';
import '../../app_shell/app_view_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.controller, super.key});

  final AppViewModel controller;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  AppViewModel get _c => widget.controller;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final summary = _c.summary;
    final balance = _c.balance;

    final remaining = summary?.remaining ?? 0.0;
    final limit = summary?.weeklyLimit ?? _c.weeklyLimit;
    final spent = summary?.weeklySpend ?? 0.0;
    final progress = limit > 0 ? (remaining / limit).clamp(0.0, 1.0) : 0.0;
    final productLabel = _c.selectedProduct?.label ?? localizations.appTitle;

    return Scaffold(
      backgroundColor: EdenredColors.grayLight,
      appBar: AppBar(
        backgroundColor: EdenredColors.white,
        foregroundColor: EdenredColors.navyDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _c.changeProduct,
          icon: const Icon(Icons.account_balance_wallet_outlined),
          tooltip: localizations.changeSelectedProduct,
        ),
        title: Text(
          productLabel,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EdenredColors.navyDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _c.logout,
            icon: const Icon(Icons.logout),
            tooltip: localizations.logoutTooltip,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0x0D000000)),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _c.refreshDashboard,
          color: EdenredColors.redAlert,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _HeroBalanceCard(
                remainingLabel: localizations.remainingThisWeek,
                remaining: remaining,
                spent: spent,
                limit: limit,
                progress: progress,
                rangeLabel: summary?.range.label ?? '',
              ),
              const SizedBox(height: 16),
              _CardBalanceBanner(
                balance: balance?.amount ?? 0.0,
                onChangeCard: _c.changeProduct,
              ),
              const SizedBox(height: 8),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _EditLimitCard(
                        onTap: () => _editWeeklyLimit(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _LastUpdatedCard(lastRefreshed: _c.lastRefreshed),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Future<void> _editWeeklyLimit(BuildContext context) async {
    final textController = TextEditingController(
      text: _c.weeklyLimit.toStringAsFixed(2),
    );
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        final loc = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(loc.weeklyLimit),
          content: TextField(
            controller: textController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(suffixText: 'EUR'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                double.tryParse(textController.text.replaceAll(',', '.')),
              ),
              child: Text(loc.saveAction),
            ),
          ],
        );
      },
    );
    if (value != null) {
      await _c.saveWeeklyLimit(value);
    }
  }
}

// ── Hero Balance Card ─────────────────────────────────────────────────────────

class _HeroBalanceCard extends StatelessWidget {
  const _HeroBalanceCard({
    required this.remainingLabel,
    required this.remaining,
    required this.spent,
    required this.limit,
    required this.progress,
    required this.rangeLabel,
  });

  final String remainingLabel;
  final double remaining;
  final double spent;
  final double limit;
  final double progress;
  final String rangeLabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: EdenredColors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 40,
            offset: Offset(5, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            remainingLabel,
            style: tt.bodyMedium?.copyWith(color: EdenredColors.slateMuted),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 192,
            height: 192,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(192, 192),
                  painter: _ProgressRingPainter(progress),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(remaining.toStringAsFixed(2), style: tt.displayLarge),
                      Text(
                        'EUR',
                        style: tt.bodyMedium?.copyWith(
                          color: EdenredColors.slateMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${spent.toStringAsFixed(2)} EUR spent of ${limit.toStringAsFixed(2)} EUR limit',
            style: tt.bodyMedium?.copyWith(color: EdenredColors.slateMuted),
            textAlign: TextAlign.center,
          ),
          if (rangeLabel.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: EdenredColors.grayLight,
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: Text(rangeLabel, style: tt.labelMedium),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 12.0;
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      Paint()
        ..color = EdenredColors.grayLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = EdenredColors.redAlert
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) => old.progress != progress;
}

// ── Card Balance Banner ───────────────────────────────────────────────────────

class _CardBalanceBanner extends StatelessWidget {
  const _CardBalanceBanner({
    required this.balance,
    required this.onChangeCard,
  });

  final double balance;
  final VoidCallback onChangeCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: EdenredColors.redAlert,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 40,
            offset: Offset(5, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CARD BALANCE',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${balance.toStringAsFixed(2)} EUR',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onChangeCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: EdenredColors.redAlert,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: const StadiumBorder(),
              textStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Change Card'),
          ),
        ],
      ),
    );
  }
}

// ── Action Tiles ──────────────────────────────────────────────────────────────

class _EditLimitCard extends StatelessWidget {
  const _EditLimitCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: EdenredColors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 40,
              offset: Offset(5, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tune, color: EdenredColors.navyDark, size: 24),
            const SizedBox(height: 4),
            Text('Edit Limit', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _LastUpdatedCard extends StatelessWidget {
  const _LastUpdatedCard({required this.lastRefreshed});

  final DateTime? lastRefreshed;

  @override
  Widget build(BuildContext context) {
    final timeLabel = lastRefreshed != null
        ? 'Today, ${intl.DateFormat('h:mm a').format(lastRefreshed!)}'
        : '—';

    return Container(
      decoration: const BoxDecoration(
        color: EdenredColors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 40,
            offset: Offset(5, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sync, color: EdenredColors.slateMuted, size: 16),
              const SizedBox(width: 4),
              Text(
                'Last updated',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: EdenredColors.slateMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            timeLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Bottom Navigation Bar ─────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: EdenredColors.navyDark,
      unselectedItemColor: EdenredColors.slateMuted,
      selectedLabelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
