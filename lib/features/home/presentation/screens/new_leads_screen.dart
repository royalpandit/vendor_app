import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
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
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom AppBar
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 8,
                          offset: Offset(0, 6),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 24,
                              height: 24,
                              child: Image.asset(
                                'assets/icons/arrow-left.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Title
                          Text(
                            'New Leads',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w300,
                              height: 1.33,
                              letterSpacing: -0.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF7F7F7),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: const Color(0x4CDBE2EA),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Image.asset(
                                    'assets/icons/Icon.png',
                                    width: 18,
                                    height: 18,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search for leads',
                                      hintStyle: TextStyle(
                                        color: const Color(0x4737383C),
                                        fontSize: 16,
                                        fontFamily: 'Onest',
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                        letterSpacing: 0.09,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // "Today" section heading
                          Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                              letterSpacing: 0.09,
                            ),
                          ),
                          SizedBox(height: 8),
                          
                          // Lead List
                          Expanded(
                            child: authProvider.loading
                                ? Center(child: CircularProgressIndicator())
                                : authProvider.bookingLeads.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No leads available.',
                                          style: TextStyle(fontFamily: 'Onest'),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: authProvider.bookingLeads.length,
                                        itemBuilder: (context, index) {
                                          final lead = authProvider.bookingLeads[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _buildLeadCard(
                                              bookingId: lead.id,
                                              name: lead.user.name,
                                              email: lead.user.email ?? 'No email',
                                              budget: lead.budget,
                                              date: lead.eventDate,
                                              location: lead.address,
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0xFFF4F4F4),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 146,
                      child: Text(
                        name,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w500,
                          height: 1.33,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      width: 146,
                      child: Text(
                        email,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.30),
                          fontSize: 12,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                          height: 1.17,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.60),
                        fontSize: 10,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w400,
                        height: 1.80,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      budget,
                      style: TextStyle(
                        color: const Color(0xFF171719),
                        fontSize: 16,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Date and Location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/calendar.png',
                    width: 18,
                    height: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: const Color(0xFF171719),
                      fontSize: 12,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/icons/location.png',
                    width: 18,
                    height: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(
                      color: const Color(0xFF171719),
                      fontSize: 12,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildActionButton(
                bookingId: bookingId,
                label: 'Decline Order',
                color: const Color(0xFFFF7171),
                iconPath: 'assets/icons/close-circle.png',
                action: "reject",
                filled: false,
              ),
              SizedBox(width: 16),
              _buildActionButton(
                bookingId: bookingId,
                label: 'Accept Order',
                color: const Color(0xFF14A38B),
                iconPath: 'assets/icons/tick-circle.png',
                action: "approve",
                filled: false,
              ),
            ],
          ),
        ],
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
    required bool filled,
  }) {
    return GestureDetector(
      onTap: () async {
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
      child: Container(
        width: 170,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: filled ? color : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: filled
                ? BorderSide.none
                : BorderSide(
                    width: 0,
                    color: Colors.transparent,
                  ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 24, height: 24),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w500,
                height: 1.50,
                letterSpacing: 0.09,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


