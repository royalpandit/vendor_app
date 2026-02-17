class ContactSupportResponse {
  final String type;
  final String key;
  final String value;

  ContactSupportResponse({
    required this.type,
    required this.key,
    required this.value,
  });

  factory ContactSupportResponse.fromJson(Map<String, dynamic> json) {
    return ContactSupportResponse(
      type: json['type'] ?? '',
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'key': key,
      'value': value,
    };
  }
}
