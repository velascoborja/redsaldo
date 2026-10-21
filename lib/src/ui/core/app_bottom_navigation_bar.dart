import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_liquid_glass/native_liquid_glass.dart' as native;

import '../../l10n/app_localizations.dart';
import 'theme.dart';

/// Uses the system Liquid Glass bar on iOS 26+, a Cupertino tab bar on older
/// iOS versions and a Material 3 navigation bar elsewhere.
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

    // Android and other platforms use the native Material 3 navigation bar,
    // styled through `NavigationBarThemeData` in the app theme.
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
