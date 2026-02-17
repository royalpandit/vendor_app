class FaqResponse {
  final int id;
  final String type;
  final String title;
  final String description;

  FaqResponse({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    return FaqResponse(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
    };
  }
}
