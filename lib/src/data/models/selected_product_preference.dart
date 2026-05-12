class SelectedProductPreference {
  const SelectedProductPreference({
    required this.idTicket,
    required this.label,
    required this.active,
    required this.status,
  });

  final int idTicket;
  final String label;
  final bool active;
  final String? status;

  factory SelectedProductPreference.fromJson(Map<String, Object?> json) {
    return SelectedProductPreference(
      idTicket: (json['idTicket'] as num).toInt(),
      label: json['label'] as String,
      active: json['active'] as bool? ?? true,
      status: json['status'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'idTicket': idTicket,
      'label': label,
      'active': active,
      'status': status,
    };
  }
}
