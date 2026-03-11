import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'service_details_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    final user = await TokenStorage.getUserData();
    final prov = context.read<AuthProvider>();
    // Try fetching both 'service' and 'venue' types and normalize responses.
    final combined = <dynamic>[];

    Future<List<dynamic>> _extractList(Map<String, dynamic>? data) async {
      if (data == null) return [];
      // Common shapes:
      // 1) { 'services': { 'data': [...] } }
      // 2) { 'services': [...] }
      // 3) { 'data': [...] }
      // 4) { 'venues': { 'data': [...] } }
      if (data['services'] is Map) {
        return List<dynamic>.from((data['services']['data'] as List? ?? []));
      }
      if (data['services'] is List) {
        return List<dynamic>.from(data['services'] as List);
      }
      if (data['venues'] is Map) {
        return List<dynamic>.from((data['venues']['data'] as List? ?? []));
      }
      if (data['venues'] is List) {
        return List<dynamic>.from(data['venues'] as List);
      }
      if (data['data'] is List) {
        return List<dynamic>.from(data['data'] as List);
      }
      // Fallback: scan for first List value and return it
      for (final v in data.values) {
        if (v is List) return List<dynamic>.from(v);
        if (v is Map && v['data'] is List) return List<dynamic>.from(v['data'] as List);
      }
      return [];
    }

    try {
      final svc = await prov.fetchServiceList(type: 'service', vendorId: user?.id, perPage: 50);
      final list1 = await _extractList(svc);
      combined.addAll(list1);

      final ven = await prov.fetchServiceList(type: 'venue', vendorId: user?.id, perPage: 50);
      final list2 = await _extractList(ven);
      combined.addAll(list2);
    } catch (e) {
      // ignore and continue with whatever we have
    }

    final list = combined;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _toggleServiceVisibility(int serviceId) async {
    final prov = context.read<AuthProvider>();
    final item = _items.firstWhere((i) => i['id'] == serviceId, orElse: () => null);
    
    if (item == null) return;

    // Determine current status
    final isVisible = item['status'] == 1 || item['status'] == true;
    final newStatus = isVisible ? 'hide' : 'show';

    // Call API
    final ok = await prov.updateServiceStatus(serviceId, newStatus);
    
    if (mounted) {
      if (ok) {
        // Update UI
        setState(() {
          final index = _items.indexWhere((i) => i['id'] == serviceId);
          if (index != -1) {
            _items[index]['status'] = newStatus == 'show' ? 1 : 0;
          }
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service ${newStatus == 'show' ? 'shown' : 'hidden'} successfully')),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(prov.message ?? 'Failed to update status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'My Services',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Onest',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox, size: 64, color: Color(0xFFCCCCCC)),
                      const SizedBox(height: 16),
                      const Text(
                        'No services found',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Onest',
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _items.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemBuilder: (context, index) {
                    final item = _items[index] as Map<String, dynamic>;
                    final title = item['name'] ?? item['title'] ?? 'Service';
                    final subtitle = item['city'] ?? item['description'] ?? '';
                    final image = item['primary_image_url'] ?? item['profile_image'];
                    final id = item['id'] is int ? item['id'] as int : int.tryParse('${item['id']}') ?? 0;
                    
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailsScreen(serviceId: id))),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFFE0E0E0),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadows: [
                            BoxShadow(
                              color: const Color(0xFF000000).withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Builder(builder: (context) {
                                if (image == null || image.contains('default-service.jpg')) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.image, size: 32, color: Color(0xFFCCCCCC)),
                                  );
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    image,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => Container(
                                      color: const Color(0xFFF5F5F5),
                                      child: const Icon(Icons.image, size: 32, color: Color(0xFFCCCCCC)),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1a1a1a),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // GestureDetector(
                                //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailsScreen(serviceId: id))),
                                //   child: Container(
                                //     padding: const EdgeInsets.all(6),
                                //     decoration: BoxDecoration(
                                //       color: const Color(0xFFF5F5F5),
                                //       borderRadius: BorderRadius.circular(6),
                                //     ),
                                //     child: Image.asset(
                                //       'assets/icons/edit_icon.png',
                                //       width: 20,
                                //       height: 20,
                                //       color: const Color(0xFFFF4678),
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _toggleServiceVisibility(id),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      (item['status'] == 1 || item['status'] == true) ? Icons.visibility : Icons.visibility_off,
                                      size: 20,
                                      color: (item['status'] == 1 || item['status'] == true) ? const Color(0xFFFF4678) : const Color(0xFF999999),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
