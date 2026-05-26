import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme.dart';
import '../../app_shell/app_view_model.dart';
import '../../products/widgets/product_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.controller, super.key});

  final AppViewModel controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final products = controller.products;
    final selectedId = controller.selectedProduct?.idTicket;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.chooseCardTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.chooseCardSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: EdenredColors.slateMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = products[index];
                final isSelected = product.idTicket == selectedId;
                final String statusLabel;
                switch (product.status) {
                  case 'A':
                    statusLabel = loc.cardStatusActive;
                  case 'E':
                    statusLabel = loc.cardStatusIssued;
                  default:
                    statusLabel = product.status;
                }

                return ProductCard(
                  product: product,
                  isSelected: isSelected,
                  selectedLabel: loc.selectedBadge,
                  inactiveLabel: loc.inactiveBadge,
                  ticketLabel: loc.ticketLabel(product.idTicket),
                  statusLabel: statusLabel,
                  onTap: product.active
                      ? () => controller.selectProduct(product)
                      : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Center(
              child: SizedBox(
                width: 200,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showLogoutConfirmationDialog(context);
                    if (confirm && context.mounted) {
                      await controller.logout();
                    }
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: EdenredColors.navyDark,
                  ),
                  label: Text(
                    loc.logoutButton,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: EdenredColors.navyDark,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: EdenredColors.lightSlate,
                    side: const BorderSide(color: EdenredColors.borderGray),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
