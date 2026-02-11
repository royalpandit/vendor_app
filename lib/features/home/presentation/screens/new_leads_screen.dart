import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';


class NewLeadsScreen extends StatefulWidget {
  @override
  _NewLeadsScreenState createState() => _NewLeadsScreenState();
}

class _NewLeadsScreenState extends State<NewLeadsScreen> {
  @override
  void initState() {
    super.initState();
    fetchNewLeads();

  }
  Future<void> fetchNewLeads() async {
    // Fetch user data from SharedPreferences

    final userData = await TokenStorage.getUserData();

    final userId = userData?.id ?? 0;
    final authProvider = context.read<AuthProvider>(); // Access auth provider

    // Fetch the booking leads if they are not already fetched
    if (authProvider.bookingLeads.isEmpty) {
      authProvider.fetchBookingLeads(userId);
    }
  }


  @override
  Widget build(BuildContext context) {
    // Using Consumer to listen to changes in AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('New Leads'),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search for leads',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // "Today" section heading
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                // Lead List
                Expanded(
                  child: authProvider.loading
                      ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
                      : authProvider.bookingLeads.isEmpty
                      ? Center(child: Text('No leads available.'))
                      : ListView.builder(
                    itemCount: authProvider.bookingLeads.length,
                    itemBuilder: (context, index) {
                      final lead = authProvider.bookingLeads[index];
                      return _buildLeadCard(
                        bookingId: lead.id,
                        name: lead.user.name,
                        email: lead.user.email ?? 'No email',
                        budget: lead.budget,
                        date: lead.eventDate,
                        location: lead.address,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Lead Card Widget
  Widget _buildLeadCard({
    required int bookingId,
    required String name,
    required String email,
    required String budget,
    required String date,
    required String location,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: AppColors.lightGrey,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name, Email, and Budget Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Budget',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  budget,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Date and Location Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            // Decline and Accept Order buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  bookingId: bookingId,
                  label: 'Decline Order',
                  color: Colors.red,
                  iconPath: 'assets/icons/decline_icon.png',
                  action: "reject",
                ),
                SizedBox(width: 8),
                _buildActionButton(
                  bookingId: bookingId,
                  label: 'Accept Order',
                  color: Colors.green,
                  iconPath: 'assets/icons/accept_icon.png',
                  action: "approve",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Action Button Widget (Decline or Accept)
  Widget _buildActionButton({
    required int bookingId,
    required String label,
    required Color color,
    required String iconPath,
    required String action, // approve | reject
  }) {
    return TextButton.icon(
      onPressed: () async {
        final provider = context.read<AuthProvider>();

        final success = await provider.updateBookingStatus(
          bookingId: bookingId,
          action: action,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.message ?? 'Updated')),
          );

          // 🔄 Refresh Leads List
          final user = await TokenStorage.getUserData();
          final userId = user?.id ?? 0;
          provider.fetchBookingLeads(userId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.message ?? 'Failed')),
          );
        }
      },
      icon: Image.asset(iconPath, width: 20, height: 20),
      label: Text(label, style: TextStyle(color: color)),
    );
  }
}


