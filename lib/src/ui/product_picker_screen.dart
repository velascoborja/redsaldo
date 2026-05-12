import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/app_controller.dart';

class ProductPickerScreen extends StatelessWidget {
  const ProductPickerScreen({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.chooseProduct),
        actions: <Widget>[
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
            tooltip: localizations.logoutTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: controller.products.isEmpty
            ? Center(child: Text(localizations.noProducts))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  final subtitle = product.status.isEmpty
                      ? localizations.ticketLabel(product.idTicket)
                      : localizations.ticketLabelWithStatus(
                          product.idTicket,
                          product.status,
                        );
                  return ListTile(
                    title: Text(product.label),
                    subtitle: Text(subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    enabled: product.active,
                    onTap: product.active
                        ? () => controller.selectProduct(product)
                        : null,
                  );
                },
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemCount: controller.products.length,
              ),
      ),
    );
  }
}
