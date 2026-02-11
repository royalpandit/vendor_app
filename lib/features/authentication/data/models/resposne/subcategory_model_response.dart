// lib/features/catalog/data/models/subcategory_model.dart
class SubcategoryModelResponse {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String? icon;
  final String? thumbnail;
  final String? description;
  final bool status; // API में 1/0 आता है
  final int? position;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? thumbnailUrl;

  SubcategoryModelResponse({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.icon,
    this.thumbnail,
    this.description,
    required this.status,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.thumbnailUrl,
  });

  factory SubcategoryModelResponse.fromJson(Map<String, dynamic> json) {
    return SubcategoryModelResponse(
      id: (json['id'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      description: json['description']?.toString(),
      status: ((json['status'] as num?)?.toInt() ?? 0) == 1,
      position: (json['position'] as num?)?.toInt(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'name': name,
    'slug': slug,
    'icon': icon,
    'thumbnail': thumbnail,
    'description': description,
    'status': status ? 1 : 0,
    'position': position,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
    'thumbnail_url': thumbnailUrl,
  };
}
