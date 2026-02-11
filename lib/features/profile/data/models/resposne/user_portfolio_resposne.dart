class UserPortfolioResposne {
  final int userId;
  final String imagePath;
  final String createdAt;
  final String updatedAt;
  final int id;

  UserPortfolioResposne({
    required this.userId,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  factory UserPortfolioResposne.fromJson(Map<String, dynamic> json) {
    return UserPortfolioResposne(
      userId: json['user_id'],
      imagePath: json['image_path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      id: json['id'],
    );
  }
}
