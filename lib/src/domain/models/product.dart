class Product {
  const Product({
    required this.idTicket,
    required this.label,
    required this.active,
    required this.status,
  });

  final int idTicket;
  final String label;
  final bool active;
  final String status;
}

class Balance {
  const Balance({required this.amount});

  final double amount;
}

class DomainTransaction {
  const DomainTransaction({
    required this.id,
    required this.dateUtc,
    required this.description,
    required this.amount,
    required this.businessName,
    required this.city,
    required this.province,
  });

  final String id;
  final DateTime dateUtc;
  final String description;
  final double amount;
  final String businessName;
  final String city;
  final String province;
}

class SelectedProduct {
  const SelectedProduct({
    required this.idTicket,
    required this.label,
    required this.active,
    required this.status,
  });

  final int idTicket;
  final String label;
  final bool active;
  final String? status;
}
