import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/app_controller.dart';
import 'money.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final summary = controller.summary;
    final selectedProduct = controller.selectedProduct;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: <Widget>[
          IconButton(
            onPressed: controller.refreshDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: localizations.refreshTooltip,
          ),
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
            tooltip: localizations.logoutTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                selectedProduct?.label ?? localizations.selectedProductFallback,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _MetricTile(
                label: localizations.availableBalance,
                value: formatEuros(controller.balance?.amount ?? 0),
              ),
              _MetricTile(
                label: localizations.weeklyLimit,
                value: formatEuros(controller.weeklyLimit),
              ),
              _MetricTile(
                label: localizations.spentThisWeek,
                value: formatEuros(summary?.weeklySpend ?? 0),
              ),
              _MetricTile(
                label: localizations.remainingThisWeek,
                value: formatEuros(
                  summary?.remaining ?? controller.weeklyLimit,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => _editWeeklyLimit(context),
                child: Text(localizations.editWeeklyLimit),
              ),
              TextButton(
                onPressed: controller.changeProduct,
                child: Text(localizations.changeSelectedProduct),
              ),
              const SizedBox(height: 16),
              Text(
                summary?.range.label ?? '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final transaction in summary?.transactions ?? const [])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    transaction.businessName.isNotEmpty
                        ? transaction.businessName
                        : transaction.description,
                  ),
                  subtitle: Text(transaction.description),
                  trailing: Text(formatEuros(transaction.amount)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editWeeklyLimit(BuildContext context) async {
    final textController = TextEditingController(
      text: controller.weeklyLimit.toStringAsFixed(2),
    );
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(localizations.weeklyLimit),
          content: TextField(
            controller: textController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(suffixText: 'EUR'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(double.tryParse(textController.text.replaceAll(',', '.'))),
              child: Text(localizations.saveAction),
            ),
          ],
        );
      },
    );

    if (value != null) {
      await controller.saveWeeklyLimit(value);
    }
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
