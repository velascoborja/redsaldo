import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../app_shell/app_view_model.dart';
import '../widgets/product_card.dart';

class ProductPickerScreen extends StatelessWidget {
  const ProductPickerScreen({required this.controller, super.key});

  final AppViewModel controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.chooseProduct),
        actions: <Widget>[
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
            tooltip: loc.logoutTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: controller.products.isEmpty
            ? Center(child: Text(loc.noProducts))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                itemCount: controller.products.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return ProductCard(
                    product: product,
                    isSelected: false,
                    selectedLabel: loc.selectedBadge,
                    inactiveLabel: loc.inactiveBadge,
                    ticketLabel: loc.ticketLabel(product.idTicket),
                    onTap: product.active
                        ? () => controller.selectProduct(product)
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
