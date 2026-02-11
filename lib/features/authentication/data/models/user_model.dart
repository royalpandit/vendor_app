/* class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'roles': roles,
  };
}*/
class UserModel {
  final int? id; // Nullable to allow for missing values
  final String name;
  final String? email;  // Nullable because email can be null
  final String phone;
  final List<String> roles;

  UserModel({
    this.id,  // Nullable id
    required this.name,
    this.email, // Nullable email
    required this.phone,
    required this.roles,
  });

  // Factory method to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] != null ? (json['id'] as num).toInt() : null; // Default to null if id is missing
    return UserModel(
      id: id, // Set the nullable id
      name: json['name']?.toString() ?? '', // Default to empty string if null
      email: json['email']?.toString(), // Nullable email
      phone: json['phone']?.toString() ?? '', // Default to empty string if null
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((e) => e.toString()) // Ensure roles are parsed as strings
          .toList(),
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() => {
    'id': id, // Nullable id
    'name': name,
    'email': email,
    'phone': phone,
    'roles': roles,
  };
}

