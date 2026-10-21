import 'package:edenred_55_app/src/l10n/app_localizations.dart';
import 'package:edenred_55_app/src/ui/core/app_bottom_navigation_bar.dart';
import 'package:edenred_55_app/src/ui/core/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Android shows a floating toolbar with labeled destinations', (
    tester,
  ) async {
    await tester.pumpWidget(_navigationApp());

    expect(find.byType(NavigationBar), findsNothing);
    expect(_destination('Home'), findsOneWidget);
    expect(_destination('History'), findsOneWidget);
    expect(_destination('Settings'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('Android tabs change pages with one tap', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_navigationApp());
    expect(find.text('Page 0'), findsOneWidget);

    for (final (label, index) in [
      ('History', 1),
      ('Settings', 2),
      ('Home', 0),
    ]) {
      await tester.tap(_destination(label));
      await tester.pumpAndSettle();
      expect(find.text('Page $index'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        matchesSemantics(
          label: label,
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      for (final other in [
        'Home',
        'History',
        'Settings',
      ].where((value) => value != label)) {
        expect(
          tester
              .getSemantics(find.bySemanticsLabel(other))
              .flagsCollection
              .isSelected
              .toBoolOrNull(),
          isFalse,
        );
      }
    }
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets(
    'Spanish navigation fits a narrow screen above the system inset',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(bottom: 24);
      tester.view.viewPadding = const FakeViewPadding(bottom: 24);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_navigationApp(locale: const Locale('es')));
      await tester.tap(_destination('Configuración'));
      await tester.pumpAndSettle();

      expect(find.text('Page 2'), findsOneWidget);
      expect(
        tester.getBottomLeft(_destination('Configuración')).dy,
        lessThan(640 - 24),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('toolbar grows for enlarged Spanish text on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_navigationApp(locale: const Locale('es')));
    final originalHeight = tester
        .getSize(find.byType(AppBottomNavigationBar))
        .height;
    await tester.pumpWidget(
      _navigationApp(locale: const Locale('es'), textScale: 2),
    );

    expect(
      tester.getSize(find.byType(AppBottomNavigationBar)).height,
      greaterThan(originalHeight),
    );
    for (final label in ['Inicio', 'Historial', 'Configuración']) {
      final target = find.ancestor(
        of: _destination(label),
        matching: find.byType(InkWell),
      );
      expect(tester.getSize(target).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
      await tester.tap(_destination(label));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('floating surface is centered and clears the system inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 24);
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_navigationApp());

    final surface = find.descendant(
      of: find.byType(AppBottomNavigationBar),
      matching: find.byType(Material),
    );
    final rect = tester.getRect(surface);
    expect(rect.width, 320);
    expect(rect.center.dx, 400);
    expect(rect.bottom, 640 - 24 - 12);
  });

  testWidgets('screen readers can activate an Android destination', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_navigationApp());

    final node = tester.getSemantics(
      find.bySemanticsLabel(RegExp('^Settings')),
    );
    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pumpAndSettle();

    expect(find.text('Page 2'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('other platforms retain working Material navigation', (
    tester,
  ) async {
    await tester.pumpWidget(_navigationApp());
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(_destination('History'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('iOS without Liquid Glass retains working Cupertino tabs', (
    tester,
  ) async {
    await tester.pumpWidget(_navigationApp());
    expect(find.byType(CupertinoTabBar), findsOneWidget);
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('Page 1'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}

Finder _destination(String label) => find.descendant(
  of: find.byType(AppBottomNavigationBar),
  matching: find.text(label),
);

Widget _navigationApp({
  Locale locale = const Locale('en'),
  double textScale = 1,
}) {
  var index = 0;
  return MaterialApp(
    theme: EdenredTheme.light(),
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: StatefulBuilder(
      builder: (context, setState) => Scaffold(
        extendBody: true,
        body: Center(child: Text('Page $index')),
        bottomNavigationBar: AppBottomNavigationBar(
          selectedIndex: index,
          onSelected: (value) => setState(() => index = value),
        ),
      ),
    ),
  );
}
