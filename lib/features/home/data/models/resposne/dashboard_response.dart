class DashboardResponse {
  final int totalLeads;
  final int totalBooking;
  final int activeBooking;
  final String totalEarning;
  final List<Lead> latestLeads;

  DashboardResponse({
    required this.totalLeads,
    required this.totalBooking,
    required this.activeBooking,
    required this.totalEarning,
    required this.latestLeads,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    var leads = json['latest_leads'] as List? ?? [];
    return DashboardResponse(
      totalLeads: json['total_leads'] ?? 0,
      totalBooking: json['total_booking'] ?? 0,
      activeBooking: json['active_booking'] ?? 0,
      totalEarning: json['total_earning']?.toString() ?? '0.00',
      latestLeads: leads.map((e) => Lead.fromJson(e)).toList(),
    );
  }
}

class Lead {
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

  Lead({
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

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
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

  VendorInfo({
    required this.name,
    required this.image,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
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
