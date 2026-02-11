class GetUserPortfolioResponse {
  final int id;
  final String imagePath;
  final String fullUrl;
  final String createdAt;

  GetUserPortfolioResponse({
    required this.id,
    required this.imagePath,
    required this.fullUrl,
    required this.createdAt,
  });

  factory GetUserPortfolioResponse.fromJson(Map<String, dynamic> json) {
    return GetUserPortfolioResponse(
      id: json['id'] ?? 0,
      imagePath: json['image_path']?.toString() ?? '',
      fullUrl: json['full_url']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'full_url': fullUrl,
      'created_at': createdAt,
    };
  }
}
