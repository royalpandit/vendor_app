// lib/features/catalog/data/models/category_model.dart
class CategoryModelResponse {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? thumbnail;
  final String? description;
  final bool status;  // API में boolean/1 आता है; यहाँ bool रख रहे हैं
  final int? position;
  final String? createdAt;
  final String? updatedAt;
  final String? thumbnailUrl;

  CategoryModelResponse({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.thumbnail,
    this.description,
    required this.status,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.thumbnailUrl,
  });

  factory CategoryModelResponse.fromJson(Map<String, dynamic> json) {
    return CategoryModelResponse(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      description: json['description']?.toString(),
      status: json['status'] is bool
          ? json['status'] as bool
          : ((json['status'] as num?)?.toInt() ?? 0) == 1,
      position: (json['position'] as num?)?.toInt(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'icon': icon,
    'thumbnail': thumbnail,
    'description': description,
    'status': status,
    'position': position,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'thumbnail_url': thumbnailUrl,
  };
}
