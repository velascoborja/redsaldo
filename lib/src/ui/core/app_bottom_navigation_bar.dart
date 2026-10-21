import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_liquid_glass/native_liquid_glass.dart' as native;

import '../../l10n/app_localizations.dart';
import 'theme.dart';

/// Uses the system Liquid Glass bar on iOS 26+, a Cupertino tab bar on older
/// iOS versions, a floating toolbar on Android and a Material 3 navigation bar
/// elsewhere.
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  }) : assert(selectedIndex >= 0 && selectedIndex < 3);

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final destinations = [
      (
        label: loc.navHome,
        icon: CupertinoIcons.house,
        symbol: 'house',
        material: Icons.home_outlined,
        materialSelected: Icons.home,
      ),
      (
        label: loc.historyTitle,
        icon: CupertinoIcons.doc_text,
        symbol: 'doc.text',
        material: Icons.receipt_long_outlined,
        materialSelected: Icons.receipt_long,
      ),
      (
        label: loc.settingsTitle,
        icon: CupertinoIcons.gear,
        symbol: 'gearshape',
        material: Icons.settings_outlined,
        materialSelected: Icons.settings,
      ),
    ];

    if (native.NativeLiquidGlassUtils.supportsLiquidGlass) {
      return SafeArea(
        top: false,
        bottom: false,
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: native.LiquidGlassTabBar(
          currentIndex: selectedIndex,
          onTabSelected: onSelected,
          height: 64,
          iconSize: 18,
          selectedItemColor: EdenredColors.redAlert,
          items: [
            for (final destination in destinations)
              native.LiquidGlassTabItem(
                label: destination.label,
                icon: native.NativeLiquidGlassIcon.sfSymbol(destination.symbol),
              ),
          ],
        ),
      );
    }

    // Older iOS versions keep their familiar system-style tab bar.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoTabBar(
        currentIndex: selectedIndex,
        onTap: onSelected,
        iconSize: 22,
        activeColor: EdenredColors.redAlert,
        items: [
          for (final destination in destinations)
            BottomNavigationBarItem(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      );
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Material(
                color: EdenredColors.white,
                elevation: 3,
                shadowColor: Colors.black26,
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (index, destination) in destinations.indexed)
                          Expanded(
                            child: _ToolbarDestination(
                              label: destination.label,
                              icon: selectedIndex == index
                                  ? destination.materialSelected
                                  : destination.material,
                              selected: selectedIndex == index,
                              onTap: () => onSelected(index),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Other platforms retain their Material 3 navigation bar.
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: [
        for (final destination in destinations)
          NavigationDestination(
            icon: Icon(destination.material),
            selectedIcon: Icon(destination.materialSelected),
            label: destination.label,
          ),
      ],
    );
  }
}

class _ToolbarDestination extends StatelessWidget {
  const _ToolbarDestination({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? EdenredColors.redAlert : EdenredColors.slateMuted;

    return Semantics(
      label: label,
      button: true,
      selected: selected,
      onTap: onTap,
      excludeSemantics: true,
      child: Ink(
        decoration: ShapeDecoration(
          color: selected
              ? EdenredColors.redAlert.withValues(alpha: 0.10)
              : Colors.transparent,
          shape: const StadiumBorder(),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          excludeFromSemantics: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24, color: color),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
