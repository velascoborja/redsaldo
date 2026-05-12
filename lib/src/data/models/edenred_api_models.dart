const int _dotNetUnixEpochMilliseconds = 62135596800000;
const int _dotNetUnixEpochTicks = 621355968000000000;
const int _ticksPerMillisecond = 10000;
final DateTime _unixEpochUtc = DateTime.fromMillisecondsSinceEpoch(
  0,
  isUtc: true,
);

class EdenredProduct {
  const EdenredProduct({
    required this.idTicket,
    required this.label,
    required this.active,
    required this.status,
  });

  final int idTicket;
  final String label;
  final bool active;
  final String status;

  factory EdenredProduct.fromJson(Map<String, dynamic> json) {
    final idTicket = _requiredInt(json['idTicket'], 'idTicket');
    final productType = json['productType'];
    final productTypeJson = productType is Map<String, dynamic>
        ? productType
        : const <String, dynamic>{};

    return EdenredProduct(
      idTicket: idTicket,
      label:
          _optionalTrimmedString(productTypeJson['ProductTypeDescription']) ??
          _optionalTrimmedString(productTypeJson['description']) ??
          'Edenred product $idTicket',
      active: _parseBool(json['active']),
      status:
          _optionalTrimmedString(json['estado']) ??
          _optionalTrimmedString(json['status']) ??
          '',
    );
  }
}

class EdenredBalance {
  const EdenredBalance({required this.amount});

  final double amount;

  factory EdenredBalance.fromJson(Map<String, dynamic> json) {
    return EdenredBalance(
      amount: _parseDouble(json['balance'] ?? json['saldo']),
    );
  }
}

class EdenredTransaction {
  const EdenredTransaction({
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

  factory EdenredTransaction.fromJson(Map<String, dynamic> json) {
    return EdenredTransaction(
      id: _optionalTrimmedString(json['idTransaccion'] ?? json['id']) ?? '',
      dateUtc: parseEdenredDate(
        json['date'] ?? json['fecha'] ?? json['transactionDate'],
      ),
      description: _optionalTrimmedString(json['description']) ?? '',
      amount: _parseDouble(json['amount'] ?? json['importe']),
      businessName:
          _optionalTrimmedString(json['businessName']) ??
          _optionalTrimmedString(json['bussinessName']) ??
          '',
      city: _optionalTrimmedString(json['city']) ?? '',
      province: _optionalTrimmedString(json['province']) ?? '',
    );
  }
}

DateTime parseEdenredDate(Object? value) {
  if (value is num) {
    return _dateFromMilliseconds(value.toInt());
  }

  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return _unixEpochUtc;
    }

    final numeric = num.tryParse(trimmed);
    if (numeric != null) {
      return _dateFromMilliseconds(numeric.toInt());
    }

    return DateTime.tryParse(trimmed)?.toUtc() ?? _unixEpochUtc;
  }

  return _unixEpochUtc;
}

DateTime _dateFromMilliseconds(int value) {
  final unixMilliseconds = value >= _dotNetUnixEpochTicks
      ? (value - _dotNetUnixEpochTicks) ~/ _ticksPerMillisecond
      : value >= _dotNetUnixEpochMilliseconds
      ? value - _dotNetUnixEpochMilliseconds
      : value;

  return DateTime.fromMillisecondsSinceEpoch(unixMilliseconds, isUtc: true);
}

int _requiredInt(Object? value, String fieldName) {
  final parsed = _parseInt(value);
  if (parsed == null) {
    throw EdenredModelException('Edenred field $fieldName is required.');
  }

  return parsed;
}

int? _parseInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }

  return null;
}

String? _optionalTrimmedString(Object? value) {
  if (value == null) {
    return null;
  }

  final trimmed = value.toString().trim();
  return trimmed.isEmpty ? null : trimmed;
}

double _parseDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
  }

  return 0;
}

bool _parseBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 's';
  }

  return false;
}

class EdenredModelException implements Exception {
  const EdenredModelException(this.message);

  final String message;

  @override
  String toString() => 'EdenredModelException: $message';
}
