import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/utils/app_theme.dart';
import 'package:vendor_app/core/utils/responsive_util.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';

/// Show booking details in a modal bottom sheet.
Future<void> showBookingDetailsBottomSheet(BuildContext context, int bookingId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BookingDetailsBottomSheet(bookingId: bookingId),
  );
}

class BookingDetailsBottomSheet extends StatefulWidget {
  final int bookingId;
  const BookingDetailsBottomSheet({Key? key, required this.bookingId}) : super(key: key);

  @override
  State<BookingDetailsBottomSheet> createState() => _BookingDetailsBottomSheetState();
}

class _BookingDetailsBottomSheetState extends State<BookingDetailsBottomSheet> {
  Map<String, dynamic>? _details;
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    final auth = context.read<AuthProvider>();
    final res = await auth.fetchBookingDetails(widget.bookingId);

    if (!mounted) return;

    // Fetch customer details if user_id is available
    if (res != null && res['user_id'] != null) {
      await auth.fetchUserDetails(res['user_id'] as int);
    }

    setState(() {
      _details = res;
      _message = auth.message;
      _loading = false;
    });
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.gray))),
          Expanded(child: Text(value ?? '-', style: AppTheme.bodyRegular)),
        ],
      ),
    );
  }

  String _getCustomerDisplayName() {
    // Try to get from fetched userDetails first
    if (context.watch<AuthProvider>().userDetails != null) {
      final userDetails = context.watch<AuthProvider>().userDetails!;
      return userDetails['name'] ?? '-';
    }
    // Fallback to booking details user info
    if (_details != null && _details!['user'] is Map) {
      final user = _details!['user'] as Map;
      return user['name']?.toString() ?? '-';
    }
    return '-';
  }

  String _getCustomerEmail() {
    // Try to get from fetched userDetails first
    if (context.watch<AuthProvider>().userDetails != null) {
      final userDetails = context.watch<AuthProvider>().userDetails!;
      return userDetails['email'] ?? '-';
    }
    // Fallback to booking details user info
    if (_details != null && _details!['user'] is Map) {
      final user = _details!['user'] as Map;
      return user['email']?.toString() ?? '-';
    }
    return '-';
  }

  String _getCustomerPhone() {
    // Try to get from fetched userDetails first
    if (context.watch<AuthProvider>().userDetails != null) {
      final userDetails = context.watch<AuthProvider>().userDetails!;
      return userDetails['phone'] ?? '-';
    }
    // Fallback to booking details user info
    if (_details != null && _details!['user'] is Map) {
      final user = _details!['user'] as Map;
      return user['phone']?.toString() ?? '-';
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUtil.constrainedWidth(context, maxWidth: 760);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          controller: controller,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Booking Details', style: AppTheme.heading3),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_loading) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 12),
                    if (_message != null) Center(child: Text(_message!)),
                  ] else if (_details == null) ...[
                    Center(child: Text(_message ?? 'No details available')),
                  ] else ...[
                    // Customer Details Section
                    Text('Customer Details', style: AppTheme.heading4.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _row('Name', _getCustomerDisplayName()),
                    _row('Email', _getCustomerEmail()),
                    _row('Phone', _getCustomerPhone()),
                    const SizedBox(height: 12),

                    // Booking Details Section
                    Text('Booking Information', style: AppTheme.heading4.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _row('Booking ID', _details!['id']?.toString()),
                    _row('Service', _details!['service_name']?.toString()),
                    _row('Event Type', _details!['event_type']?.toString()),
                    _row('Event Date', _details!['event_date']?.toString()),
                    _row('Guest Count', _details!['guest_count']?.toString()),
                    _row('Budget', _details!['budget']?.toString()),
                    _row('Status', _details!['status']?.toString()),
                    _row('Address', _details!['address']?.toString()),
                    const SizedBox(height: 8),
                    if (_details!['services'] is List) ...[
                      Text('Services', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      ...(_details!['services'] as List).map((s) {
                        final map = s is Map ? Map<String, dynamic>.from(s) : <String, dynamic>{'name': s.toString()};
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(child: Text(map['name']?.toString() ?? '-')),
                              Text(map['price']?.toString() ?? ''),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 8),
                    _row('Address', _details!['address']?.toString() ?? _details!['venue_address']?.toString()),
                    _row('Amount', _details!['amount']?.toString() ?? _details!['total_amount']?.toString()),
                    const SizedBox(height: 12),
                    if (_details!['notes'] != null) _row('Notes', _details!['notes']?.toString()),
                    const SizedBox(height: 20),

                    // Check Details Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4678),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Check Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1a1a1a),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
