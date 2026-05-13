import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/models/product.dart';
import '../../../core/theme.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.isSelected,
    required this.selectedLabel,
    required this.inactiveLabel,
    required this.ticketLabel,
    this.onTap,
    super.key,
  });

  final Product product;
  final bool isSelected;
  final String selectedLabel;
  final String inactiveLabel;
  final String ticketLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final inactive = !product.active;

    return Opacity(
      opacity: inactive && !isSelected ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? EdenredColors.lightSlate : EdenredColors.white,
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
                    Text(
                      ticketLabel,
                      style: tt.bodySmall?.copyWith(
                        color: EdenredColors.slateMuted,
                      ),
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
              if (isSelected || inactive) ...[
                const SizedBox(width: 16),
                _Badge(
                  label: isSelected ? selectedLabel : inactiveLabel,
                  selected: isSelected,
                ),
              ],
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
