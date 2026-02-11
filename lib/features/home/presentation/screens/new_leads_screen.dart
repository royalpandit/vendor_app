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
                _buildActionButton('Decline Order', Colors.red, 'assets/icons/decline_icon.png'),
                SizedBox(width: 8),
                _buildActionButton('Accept Order', Colors.green, 'assets/icons/accept_icon.png'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Action Button Widget (Decline or Accept)
  Widget _buildActionButton(String label, Color color, String iconPath) {
    return TextButton.icon(
      onPressed: () {
        // Action to be performed on button click
      },
      icon: Image.asset(
        iconPath, // Custom icon for each button
        width: 20,
        height: 20,
      ),
      label: Text(
        label,
        style: TextStyle(color: color), // Set the label color based on the button color
      ),
    );
  }
}

/*
class NewLeadsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              child: ListView(
                children: [
                  _buildLeadCard(
                    name: 'Priya S.',
                    email: 'priyaswami99@gmail.com',
                    budget: '₹75,000',
                    date: '15/09/2025',
                    location: 'Gurgaon, Gurgaon',
                  ),
                  _buildLeadCard(
                    name: 'Rahul Kumar',
                    email: 'rahulkumar88@yahoo.com',
                    budget: '₹50,000',
                    date: '20/10/2025',
                    location: 'Noida, Uttar Pradesh',
                  ),
                  _buildLeadCard(
                    name: 'Sita Rani',
                    email: 'sitarani@gmail.com',
                    budget: '₹100,000',
                    date: '05/11/2025',
                    location: 'Delhi, Delhi',
                  ),
                  _buildLeadCard(
                    name: 'Amit Prakash',
                    email: 'amitprakash@hotmail.com',
                    budget: '₹120,000',
                    date: '12/11/2025',
                    location: 'Delhi, Delhi',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lead Card Widget
  Widget _buildLeadCard({
    required String name,
    required String email,
    required String budget,
    required String date,
    required String location,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
                _buildActionButton('Decline Order', Colors.red, 'assets/icons/decline_icon.png'),
                SizedBox(width: 8),
                _buildActionButton('Accept Order', Colors.green, 'assets/icons/accept_icon.png'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Action Button Widget (Decline or Accept)
  Widget _buildActionButton(String label, Color color, String iconPath) {
    return TextButton.icon(
      onPressed: () {
        // Action to be performed on button click
      },
      icon: Image.asset(
        iconPath, // Custom icon for each button
        width: 20,
        height: 20,
      ),
      label: Text(
        label,
        style: TextStyle(color: color), // Set the label color based on the button color
      ),
    );
  }
}
*/
