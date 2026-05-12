import 'package:flutter/material.dart';

import '../state/app_controller.dart';

class ProductPickerScreen extends StatelessWidget {
  const ProductPickerScreen({
    required this.controller,
    super.key,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose product'),
        actions: <Widget>[
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: controller.products.isEmpty
            ? const Center(child: Text('No Edenred products were returned.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return ListTile(
                    title: Text(product.label),
                    subtitle: Text('Ticket ${product.idTicket}${product.status.isEmpty ? '' : ' · ${product.status}'}'),
                    trailing: const Icon(Icons.chevron_right),
                    enabled: product.active,
                    onTap: product.active ? () => controller.selectProduct(product) : null,
                  );
                },
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemCount: controller.products.length,
              ),
      ),
    );
  }
}
