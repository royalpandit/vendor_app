class AmenityModelResponse {
  final int id;
  final String name;
  final String? icon;
  final String? type;        // "facility" | "policy" | "other"
  final bool status;
  final String? createdAt;
  final String? updatedAt;

  AmenityModelResponse({
    required this.id,
    required this.name,
    this.icon,
    this.type,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AmenityModelResponse.fromJson(Map<String, dynamic> json) {
    return AmenityModelResponse(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      name: (json['name'] ?? '').toString(),
      icon: json['icon']?.toString(),
      type: json['type']?.toString(),
      status: (json['status'] == true) || (json['status'] == 1) || (json['status'] == '1'),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'type': type,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
