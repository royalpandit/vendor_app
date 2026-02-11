class NewLead {
  final int id;
  final int userId;
  final int vendorId;
  final String serviceName;
  final String eventType;
  final String eventDate;
  final int guestCount;
  final String budget;
  final String status;
  final String address;
  final VendorInfo vendorInfo;
  final User user;

  NewLead({
    required this.id,
    required this.userId,
    required this.vendorId,
    required this.serviceName,
    required this.eventType,
    required this.eventDate,
    required this.guestCount,
    required this.budget,
    required this.status,
    required this.address,
    required this.vendorInfo,
    required this.user,
  });

  factory NewLead.fromJson(Map<String, dynamic> json) {
    return NewLead(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      eventType: json['event_type'] ?? '',
      eventDate: json['event_date'] ?? '',
      guestCount: json['guest_count'] ?? 0,
      budget: json['budget']?.toString() ?? '0.00',
      status: json['status'] ?? '',
      address: json['address'] ?? '',
      vendorInfo: VendorInfo.fromJson(json['vendor_info']),
      user: User.fromJson(json['user']),
    );
  }
}

// Vendor Info Model
class VendorInfo {
  final int id;
  final String name;
  final String image;
  final String email;

  VendorInfo({
    required this.id,
    required this.name,
    required this.image,
    required this.email,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

// User Model
class User {
  final int id;
  final String name;
  final String? email;
  final String phone;
  final String image;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
    );
  }
}