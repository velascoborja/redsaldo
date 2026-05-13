import 'package:edenred_55_app/src/domain/models/product.dart';
import 'package:edenred_55_app/src/ui/features/products/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

const _active = Product(idTicket: 42, label: 'Meal Card', active: true, status: 'OK');
const _inactive = Product(idTicket: 7, label: 'Old Card', active: false, status: '');

void main() {
  testWidgets('shows label and ticket label', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _active,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 42',
        onTap: () {},
      ),
    ));
    expect(find.text('Meal Card'), findsOneWidget);
    expect(find.text('Ticket 42'), findsOneWidget);
  });

  testWidgets('shows status when non-empty', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _active,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 42',
        onTap: () {},
      ),
    ));
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('hides status when empty', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _inactive,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 7',
        onTap: null,
      ),
    ));
    expect(find.text(''), findsNothing);
  });

  testWidgets('shows SELECTED badge when isSelected', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _active,
        isSelected: true,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 42',
        onTap: () {},
      ),
    ));
    expect(find.text('SEL'), findsOneWidget);
    expect(find.text('OFF'), findsNothing);
  });

  testWidgets('shows INACTIVE badge when product is not active', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _inactive,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 7',
        onTap: null,
      ),
    ));
    expect(find.text('OFF'), findsOneWidget);
    expect(find.text('SEL'), findsNothing);
  });

  testWidgets('shows no badge for active unselected product', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _active,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 42',
        onTap: () {},
      ),
    ));
    expect(find.text('SEL'), findsNothing);
    expect(find.text('OFF'), findsNothing);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _active,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 42',
        onTap: () => tapped = true,
      ),
    ));
    await tester.tap(find.byType(ProductCard));
    expect(tapped, isTrue);
  });

  testWidgets('does not dim selected product even if inactive', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _inactive,
        isSelected: true,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 7',
        onTap: null,
      ),
    ));
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1.0);
  });
}
