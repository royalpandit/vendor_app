class DashboardResponse {
  final String? vendorName; // Added vendor name
  final int totalLeads;
  final int totalBooking;
  final int activeBooking;
  final String totalEarning;
  final List<Lead> latestLeads;
  final List<ServiceSummary> services; // optional services summary
  final double visibilityRatio; // computed as (totalBooking / totalLeads) * 100

  DashboardResponse({
    this.vendorName,
    required this.totalLeads,
    required this.totalBooking,
    required this.activeBooking,
    required this.totalEarning,
    required this.latestLeads,
    this.services = const [],
    required this.visibilityRatio,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    var leads = json['latest_leads'] as List? ?? [];
    var servicesJson = json['services'] as List? ?? [];

    final totalLeads = (json['total_leads'] ?? 0) as int;
    final totalBooking = (json['total_booking'] ?? 0) as int;

    final computedVisibility = (totalLeads > 0)
        ? (totalBooking / totalLeads) * 100.0
        : 0.0;

    return DashboardResponse(
      vendorName: json['vendor_name'] ?? json['name'], // Support both field names
      totalLeads: totalLeads,
      totalBooking: totalBooking,
      activeBooking: json['active_booking'] ?? 0,
      totalEarning: json['total_earning']?.toString() ?? '0.00',
      latestLeads: leads.map((e) => Lead.fromJson(e)).toList(),
      services: servicesJson
          .map((e) => ServiceSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      visibilityRatio: json['visibility_ratio'] != null
          ? (double.tryParse(json['visibility_ratio'].toString()) ?? computedVisibility)
          : computedVisibility,
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

class ServiceSummary {
  final int id;
  final String name;
  final num basePrice;

  ServiceSummary({required this.id, required this.name, required this.basePrice});

  factory ServiceSummary.fromJson(Map<String, dynamic> json) {
    return ServiceSummary(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      basePrice: json['base_price'] ?? 0,
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
