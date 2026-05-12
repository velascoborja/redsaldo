import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme.dart';
import '../../app_shell/app_view_model.dart';
import '../../../../domain/models/product.dart';

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
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = products[index];
                final isSelected = product.idTicket == selectedId;
                return _ProductCard(
                  product: product,
                  isSelected: isSelected,
                  selectedLabel: loc.selectedBadge,
                  inactiveLabel: loc.inactiveBadge,
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
                  onPressed: controller.logout,
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isSelected,
    required this.selectedLabel,
    required this.inactiveLabel,
    this.onTap,
  });

  final Product product;
  final bool isSelected;
  final String selectedLabel;
  final String inactiveLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final inactive = !product.active;

    return Opacity(
      opacity: inactive ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected ? EdenredColors.lightSlate : EdenredColors.white,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            border: Border.all(
              color: isSelected
                  ? EdenredColors.redAlert
                  : EdenredColors.borderGray,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: EdenredColors.grayLight,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: EdenredColors.slateMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.label,
                      style: tt.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.status.isNotEmpty)
                      Text(
                        product.status,
                        style: tt.bodySmall?.copyWith(
                          color: EdenredColors.slateMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isSelected || inactive)
                _Badge(
                  label: isSelected ? selectedLabel : inactiveLabel,
                  selected: isSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? EdenredColors.redAlert : EdenredColors.grayLight,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: selected ? EdenredColors.white : EdenredColors.slateMuted,
        ),
      ),
    );
  }
}
