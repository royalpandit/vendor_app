import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prov = context.read<AuthProvider>();
    final user = await TokenStorage.getUserData();
    final vendorId = user?.id;
    await prov.fetchServiceDetails(widget.serviceId, vendorId: vendorId);
    setState(() => _loading = false);
  }

  Widget _infoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Onest',
                    fontSize: 13,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontFamily: 'Onest',
                    fontSize: 14,
                    color: Color(0xFF1a1a1a),
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Onest',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a1a))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AuthProvider>();
    final svc = prov.serviceDetails;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/icons/arrow-left.png',
              width: 24,
              height: 24,
              color: const Color(0xFF666666),
            ),
          ),
        ),
        title: Text(
          svc?.isVenue == true ? 'Venue Details' : 'Service Details',
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Onest',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
        centerTitle: false,
        // actions: [
        //   GestureDetector(
        //     onTap: () => _toggleServiceStatus(),
        //     child: Padding(
        //       padding: const EdgeInsets.all(12.0),
        //       child: Image.asset(
        //         'assets/icons/edit_icon.png',
        //         width: 24,
        //         height: 24,
        //         color: svc?.status == true
        //             ? const Color(0xFFFF4678)
        //             : const Color(0xFF999999),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : svc == null
              ? Center(child: Text(prov.message ?? 'Not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primary image or gallery
                      if (svc.primaryImageUrl != null && svc.primaryImageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            svc.primaryImageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.image, size: 48, color: Color(0xFFCCCCCC)),
                            ),
                          ),
                        )
                      else if (svc.images.isNotEmpty)
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: svc.images.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final url = svc.images[i].imageUrl;
                              if (url.isEmpty || url.contains('default-service.jpg')) {
                                return Container(
                                  height: 180,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.image, size: 48, color: Color(0xFFCCCCCC)),
                                );
                              }
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  url,
                                  width: 300,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, st) => Container(
                                    width: 300,
                                    color: const Color(0xFFF5F5F5),
                                    child: const Icon(Icons.image, size: 48, color: Color(0xFFCCCCCC)),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                              child: Icon(Icons.image, size: 64, color: Color(0xFFCCCCCC))),
                        ),
                      const SizedBox(height: 16),

                      // Name
                      Text(svc.name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1a1a1a))),
                      const SizedBox(height: 4),

                      // Verify & Type badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: svc.verify == 1
                                  ? const Color(0xFF14A38B).withOpacity(0.1)
                                  : const Color(0xFFFF4678).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              svc.verify == 1 ? 'Verified' : 'Unverified',
                              style: TextStyle(
                                fontFamily: 'Onest',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: svc.verify == 1
                                    ? const Color(0xFF14A38B)
                                    : const Color(0xFFFF4678),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4678).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              svc.type.isNotEmpty ? svc.type[0].toUpperCase() + svc.type.substring(1) : 'Service',
                              style: const TextStyle(
                                fontFamily: 'Onest',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF4678),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Description
                      if (svc.description != null && svc.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(svc.description!,
                            style: const TextStyle(
                                fontFamily: 'Onest',
                                fontSize: 14,
                                color: Color(0xFF666666),
                                height: 1.5)),
                      ],

                      // Divider
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Color(0xFFE0E0E0), height: 1),
                      ),

                      // Basic Info Section
                      _sectionTitle('Basic Info'),
                      _infoRow('Name', svc.name),
                      _infoRow('Base Price', '₹${svc.basePrice.toStringAsFixed(2)}'),
                      _infoRow('Price Type', svc.priceType.isNotEmpty ? svc.priceType : null),
                      _infoRow('City', svc.city),
                      _infoRow('State', svc.state),
                      _infoRow('Pincode', svc.pincode),
                      _infoRow('Latitude', svc.latitude),
                      _infoRow('Longitude', svc.longitude),

                      // Address Section
                      if (svc.address != null && svc.address!.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0xFFE0E0E0), height: 1),
                        ),
                        _sectionTitle('Address'),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Text(svc.address!,
                              style: const TextStyle(
                                  fontFamily: 'Onest',
                                  fontSize: 14,
                                  color: Color(0xFF1a1a1a),
                                  height: 1.5)),
                        ),
                      ],

                      // Venue Details Section
                      if (svc.isVenue) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0xFFE0E0E0), height: 1),
                        ),
                        _sectionTitle('Venue Details'),
                        _infoRow('Min Booking', svc.minBooking?.toString()),
                        _infoRow('Max Capacity', svc.maxCapacity?.toString()),
                        _infoRow('Extra Guest Price',
                            svc.extraGuestPrice != null
                                ? '₹${svc.extraGuestPrice!.toStringAsFixed(2)}'
                                : null),
                      ],

                      // Amenities Section
                      if (svc.amenities.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0xFFE0E0E0), height: 1),
                        ),
                        _sectionTitle('Amenities'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: svc.amenities.map((a) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: Color(0xFF14A38B)),
                                const SizedBox(width: 6),
                                Text(a.name,
                                    style: const TextStyle(
                                        fontFamily: 'Onest',
                                        fontSize: 13,
                                        color: Color(0xFF1a1a1a))),
                              ],
                            ),
                          )).toList(),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
