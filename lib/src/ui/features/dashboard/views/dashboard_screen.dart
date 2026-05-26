import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme.dart';
import '../../app_shell/app_view_model.dart';
import '../../history/views/history_screen.dart';
import '../../settings/views/settings_screen.dart';

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

    return Scaffold(
      backgroundColor: EdenredColors.grayLight,
      appBar: AppBar(
        backgroundColor: EdenredColors.white,
        foregroundColor: EdenredColors.navyDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          switch (_selectedIndex) {
            1 => localizations.historyTitle,
            2 => localizations.settingsTitle,
            _ => localizations.homeTitle,
          },
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EdenredColors.navyDark,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0x0D000000)),
        ),
      ),
      body: ListenableBuilder(
        listenable: _c,
        builder: (context, _) => IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeBody(
              controller: _c,
              onEditLimit: () => _editWeeklyLimit(context),
              onChangeCard: () => setState(() => _selectedIndex = 2),
            ),
            HistoryScreen(controller: _c),
            SettingsScreen(controller: _c),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Future<void> _editWeeklyLimit(BuildContext context) async {
    final value = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SetLimitBottomSheet(initialValue: _c.weeklyLimit),
    );
    if (value != null) {
      await _c.saveWeeklyLimit(value);
    }
  }
}

// ── Home Body ─────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.controller,
    required this.onEditLimit,
    required this.onChangeCard,
  });

  final AppViewModel controller;
  final VoidCallback onEditLimit;
  final VoidCallback onChangeCard;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final summary = controller.summary;
    final balance = controller.balance;

    final remaining = summary?.remaining ?? 0.0;
    final limit = summary?.weeklyLimit ?? controller.weeklyLimit;
    final spent = summary?.weeklySpend ?? 0.0;
    final progress = limit > 0 ? (remaining / limit).clamp(0.0, 1.0) : 0.0;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.refreshDashboard,
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
              onChangeCard: onChangeCard,
            ),
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _EditLimitCard(onTap: onEditLimit),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LastUpdatedCard(
                      lastRefreshed: controller.lastRefreshed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    final loc = AppLocalizations.of(context);
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
                      const SizedBox(height: 16),
                      Text(
                        remaining.toStringAsFixed(2),
                        style: tt.displayLarge?.copyWith(height: 1.0),
                      ),
                      Text(
                        'EUR',
                        style: tt.bodyMedium?.copyWith(
                          color: EdenredColors.slateMuted,
                          height: 1.0,
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
            loc.spentOfLimitText(spent.toStringAsFixed(2), limit.toStringAsFixed(2)),
            style: tt.bodyMedium?.copyWith(color: EdenredColors.slateMuted),
            textAlign: TextAlign.center,
          ),
          if (rangeLabel.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    final loc = AppLocalizations.of(context);
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
            child: const Icon(
              Icons.credit_card,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.cardBalance,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: const StadiumBorder(),
              textStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(loc.changeCardAction),
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
    final loc = AppLocalizations.of(context);
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
            Text(
              loc.editLimitAction,
              style: Theme.of(context).textTheme.labelMedium,
            ),
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
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final timeLabel = lastRefreshed != null
        ? loc.lastUpdatedToday(intl.DateFormat('jm', locale).format(lastRefreshed!))
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
              const Icon(
                Icons.sync,
                color: EdenredColors.slateMuted,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                loc.lastUpdatedLabel,
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
    final loc = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: EdenredColors.redAlert,
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
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: loc.navHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined),
          activeIcon: const Icon(Icons.receipt_long),
          label: loc.historyTitle,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: loc.settingsTitle,
        ),
      ],
    );
  }
}

// ── Set Limit Bottom Sheet ────────────────────────────────────────────────────

class _SetLimitBottomSheet extends StatefulWidget {
  const _SetLimitBottomSheet({required this.initialValue});

  final double initialValue;

  @override
  State<_SetLimitBottomSheet> createState() => _SetLimitBottomSheetState();
}

class _SetLimitBottomSheetState extends State<_SetLimitBottomSheet> {
  late final TextEditingController _controller;

  static const _presets = [55.0, 60.0, 75.0];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue.toStringAsFixed(2),
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isPresetSelected(double preset) {
    final current = double.tryParse(
      _controller.text.replaceAll(',', '.'),
    );
    return current != null && (current - preset).abs() < 0.001;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: EdenredColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 6,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFC6C6CD),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.editWeeklyLimit,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: EdenredColors.navyDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: EdenredColors.slateMuted,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _LimitInput(controller: _controller),
            const SizedBox(height: 8),
            Text(
              loc.suggestedLimitText,
              style: tt.bodySmall?.copyWith(color: EdenredColors.slateMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _presets
                  .map(
                    (v) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _PresetChip(
                        label: '${v.toStringAsFixed(0)} €',
                        selected: _isPresetSelected(v),
                        onTap: () => setState(() {
                          _controller.text = v.toStringAsFixed(2);
                        }),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: EdenredColors.redAlert,
                  foregroundColor: EdenredColors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(
                  double.tryParse(
                    _controller.text.replaceAll(',', '.'),
                  ),
                ),
                icon: const Icon(Icons.check, size: 20),
                label: Text(loc.saveAction),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: EdenredColors.navyDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.cancelAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LimitInput extends StatelessWidget {
  const _LimitInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 140,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            autofocus: true,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              color: EdenredColors.navyDark,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: EdenredColors.redAlert,
                  width: 2,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: EdenredColors.redAlert,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '€',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: EdenredColors.navyDark,
          ),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? EdenredColors.redAlert : EdenredColors.white,
          border: Border.all(
            color: selected ? EdenredColors.redAlert : EdenredColors.navyDark,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? EdenredColors.white : EdenredColors.navyDark,
          ),
        ),
      ),
    );
  }
}
