import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/profile/data/models/resposne/service_meta_field_response.dart';
import 'package:vendor_app/core/utils/app_message.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool _loading = true;

  // form controllers
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  List<ServiceMetaFieldResponse> _metaFields = [];
  final Map<String, dynamic> _metaValues = {};

  @override
  void initState() {
    super.initState();
    // defer to after first frame to avoid notifications during build
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prov = context.read<AuthProvider>();
    await prov.fetchServiceDetails(widget.serviceId);
    final svc = prov.serviceDetails;
    if (svc != null) {
      _nameCtrl.text = svc.name;
      _descCtrl.text = svc.description ?? '';
      _priceCtrl.text = svc.basePrice.toString();
      _locationCtrl.text = svc.location;
      _cityCtrl.text = svc.city ?? '';
      _stateCtrl.text = svc.state ?? '';
      _latCtrl.text = svc.latitude ?? '';
      _lngCtrl.text = svc.longitude ?? '';

      // populate meta
      if (svc.meta != null) {
        _metaFields = svc.meta!.entries
            .map((e) => ServiceMetaFieldResponse(
                  id: 0,
                  fieldKey: e.key,
                  label: e.key,
                  type: e.value is bool ? 'toggle' :
                        (e.value is List ? 'multi_select' : 'text'),
                  options: e.value is List ? List<String>.from(e.value) : null,
                  isRequired: false,
                  isFilterable: false,
                ))
            .toList();
        for (var entry in _metaFields) {
          _metaValues[entry.fieldKey] = svc.meta![entry.fieldKey];
        }
      }
    }
    setState(() => _loading = false);
  }


  Future<void> _save() async {
    final prov = context.read<AuthProvider>();
    final svc = prov.serviceDetails;
    final map = <String, dynamic>{
      'id': widget.serviceId,
      'vendor_id': svc?.vendor?.id,
      'sub_category_id': svc?.subcategory?.id,
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'base_price': _priceCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'latitude': _latCtrl.text.trim(),
      'longitude': _lngCtrl.text.trim(),
      'meta': _metaValues.isNotEmpty ? _metaValues : null,
    };

    final ok = await prov.updateService(map);
    if (!mounted) return;
    AppMessage.show(context, prov.message ?? (ok ? 'Updated' : 'Failed'));
    if (ok) {
      // reload details
      _load();
    }
  }

  Future<List<String>?> _showMultiSelectDialog(ServiceMetaFieldResponse f) async {
    final opts = f.options ?? [];
    final idKey = f.fieldKey;
    final current = List<String>.from(_metaValues[idKey] ?? []);
    final selected = <String>{...current};

    return showDialog<List<String>>(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Select ${f.label}'),
        content: StatefulBuilder(builder: (context, set) {
          return SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: opts.map((o) {
                final isSel = selected.contains(o);
                return CheckboxListTile(
                  value: isSel,
                  title: Text(o),
                  onChanged: (v) => set(() => v == true ? selected.add(o) : selected.remove(o)),
                );
              }).toList(),
            ),
          );
        }),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, selected.toList()), child: const Text('OK')),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AuthProvider>();
    final svc = prov.serviceDetails;

    return Scaffold(
      appBar: AppBar(title: const Text('Service Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : svc == null
              ? Center(child: Text(prov.message ?? 'Not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(svc.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      // image carousel or placeholder
                      if (svc.images.isNotEmpty)
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: svc.images.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final url = svc.images[i].imageUrl;
                              if (url.contains('default-service.jpg')) {
                                return const Icon(Icons.broken_image,
                                    size: 64, color: Colors.grey);
                              }
                              return Image.network(
                                url,
                                width: 300,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) => const Icon(
                                    Icons.broken_image,
                                    size: 64,
                                    color: Colors.grey),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                              child: Icon(Icons.image, size: 64, color: Colors.grey)),
                        ),
                      const SizedBox(height: 16),

                      // editable fields
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      TextField(
                        controller: _priceCtrl,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _locationCtrl,
                        decoration: const InputDecoration(labelText: 'Location'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cityCtrl,
                              decoration: const InputDecoration(labelText: 'City'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _stateCtrl,
                              decoration: const InputDecoration(labelText: 'State'),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _latCtrl,
                              decoration: const InputDecoration(labelText: 'Latitude'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _lngCtrl,
                              decoration: const InputDecoration(labelText: 'Longitude'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_metaFields.isNotEmpty) ...[
                        const Text('Additional Details',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ..._metaFields.map((f) {
                          final key = f.fieldKey;
                          switch (f.type) {
                            case 'toggle':
                              return SwitchListTile(
                                title: Text(f.label),
                                value: (_metaValues[key] as bool?) ?? false,
                                onChanged: (v) =>
                                    setState(() => _metaValues[key] = v),
                              );
                            case 'multi_select':
                              final sel = List<String>.from(_metaValues[key] ?? []);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.label),
                                  Wrap(
                                      spacing: 8,
                                      children: sel
                                          .map((s) => Chip(label: Text(s)))
                                          .toList()),
                                  OutlinedButton(
                                      onPressed: () async {
                                        final res =
                                            await _showMultiSelectDialog(f);
                                        if (res != null) setState(() => _metaValues[key] = res);
                                      },
                                      child: const Text('Select')),
                                ],
                              );
                            default:
                              return TextField(
                                controller: TextEditingController(
                                    text: _metaValues[key]?.toString()),
                                decoration: InputDecoration(labelText: f.label),
                                onChanged: (v) => _metaValues[key] = v,
                              );
                          }
                        }),
                        const SizedBox(height: 16),
                      ],

                      ElevatedButton(
                        onPressed: _save,
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
