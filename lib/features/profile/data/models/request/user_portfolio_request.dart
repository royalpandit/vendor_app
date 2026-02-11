class UserPortfolioRequest {
  final int userId;
  final String key;
  final List<String> imagePath;

  UserPortfolioRequest({
    required this.userId,
    required this.key,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'key': key,
    'image_path': imagePath,
  };
}
