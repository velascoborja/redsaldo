import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import 'money.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.controller,
    super.key,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final summary = controller.summary;
    final selectedProduct = controller.selectedProduct;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edenred 55'),
        actions: <Widget>[
          IconButton(
            onPressed: controller.refreshDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(selectedProduct?.label ?? 'Selected product', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _MetricTile(label: 'Available balance', value: formatEuros(controller.balance?.amount ?? 0)),
              _MetricTile(label: 'Weekly limit', value: formatEuros(controller.weeklyLimit)),
              _MetricTile(label: 'Spent this week', value: formatEuros(summary?.weeklySpend ?? 0)),
              _MetricTile(label: 'Remaining this week', value: formatEuros(summary?.remaining ?? controller.weeklyLimit)),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => _editWeeklyLimit(context),
                child: const Text('Edit weekly limit'),
              ),
              TextButton(
                onPressed: controller.changeProduct,
                child: const Text('Change selected product'),
              ),
              const SizedBox(height: 16),
              Text(summary?.range.label ?? '', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final transaction in summary?.transactions ?? const [])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(transaction.businessName.isNotEmpty ? transaction.businessName : transaction.description),
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
    final textController = TextEditingController(text: controller.weeklyLimit.toStringAsFixed(2));
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekly limit'),
        content: TextField(
          controller: textController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: 'EUR'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(double.tryParse(textController.text.replaceAll(',', '.'))),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (value != null) {
      await controller.saveWeeklyLimit(value);
    }
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

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
