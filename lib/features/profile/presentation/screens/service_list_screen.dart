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
    final data = await prov.fetchServiceList(vendorId: user?.id, perPage: 50);
    final servicesObj = data?['services'] as Map<String, dynamic>?;
    final list = servicesObj != null ? (servicesObj['data'] as List? ?? []) : [];
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Services')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No services found'))
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _items[index] as Map<String, dynamic>;
                    final title = item['name'] ?? item['title'] ?? 'Service';
                    final subtitle = item['city'] ?? item['description'] ?? '';
                    final image = item['primary_image_url'] ?? item['profile_image'];
                    return ListTile(
                      leading: SizedBox(
                        width: 56,
                        height: 56,
                        child: Builder(builder: (context) {
                          if (image == null || image.contains('default-service.jpg')) {
                            return const Icon(Icons.broken_image, size: 24, color: Colors.grey);
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              image,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                            ),
                          );
                        }),
                      ),
                      title: Text(title),
                      subtitle: Text(subtitle),
                      onTap: () {
                        final id = item['id'] is int ? item['id'] as int : int.tryParse('${item['id']}') ?? 0;
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailsScreen(serviceId: id)));
                      },
                    );
                  },
                ),
    );
  }
}
