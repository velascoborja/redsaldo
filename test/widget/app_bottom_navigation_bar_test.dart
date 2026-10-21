import 'package:edenred_55_app/src/l10n/app_localizations.dart';
import 'package:edenred_55_app/src/ui/core/app_bottom_navigation_bar.dart';
import 'package:edenred_55_app/src/ui/core/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Android shows a Material 3 navigation bar', (tester) async {
    await tester.pumpWidget(_navigationApp());

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 0);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('Android tabs change pages with one tap', (tester) async {
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
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        index,
      );
    }
    expect(tester.takeException(), isNull);
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

Finder _destination(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Widget _navigationApp({Locale locale = const Locale('en')}) {
  var index = 0;
  return MaterialApp(
    theme: EdenredTheme.light(),
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
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
