


class ActiveBookingModel {
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

  ActiveBookingModel({
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

  factory ActiveBookingModel.fromJson(Map<String, dynamic> json) {
    return ActiveBookingModel(
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

class VendorInfo {
  final String name;
  final String image;
  final String email;

  VendorInfo({
    required this.name,
    required this.image,
    required this.email,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class User {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String image;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      image: json['image'] ?? '',
    );
  }
}
