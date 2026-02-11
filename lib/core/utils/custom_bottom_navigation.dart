import 'package:flutter/material.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/features/booking/presentation/screens/booking_screen.dart';
import 'package:vendor_app/features/chat/presentation/screens/inbox_screen.dart';
import 'package:vendor_app/features/home/presentation/screens/home_screen.dart';
import 'package:vendor_app/features/profile/presentation/screens/profile_screen.dart';

class CustomBottomNavigation extends StatefulWidget {
  final int currentIndex; // Accept the current index

  CustomBottomNavigation({
    required this.currentIndex,
  }); // Constructor to accept currentIndex

  @override
  _CustomBottomNavigationState createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  int _selectedIndex = 0; // Track selected index

  // Paths to the default icons
  final List<String> _iconPaths = [
    AppIcons.homeWhiteIcon,
     AppIcons.bookingWhiteIcon,
     AppIcons.inboxWhiteIcon,
     AppIcons.profileWhiteIcon,
   ];

  // Paths to the selected icons
  final List<String> _selectedIconPaths = [
    AppIcons.homeSelectedIcon,
     AppIcons.bookingSelectedIcon,
     AppIcons.inboxSelectedIcon,
     AppIcons.profileSelectedIcon,
   ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(currentIndex: 0)),
        );

        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BookingScreen(currentIndex: 1),
          ),
        );

        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InboxScreen(currentIndex: 2)),
        );

        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(currentIndex: 3),
          ),
        );

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: _selectedIndex,
      // Show selected index
      selectedItemColor: Colors.red,
      // Red color for selected item (customizable)
      unselectedItemColor: Colors.grey,
      // Grey color for unselected items
      type: BottomNavigationBarType.fixed,

      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            _selectedIndex == 0 ? _selectedIconPaths[0] : _iconPaths[0],
            // Switch icons
            width: 24,
            height: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _selectedIndex == 1 ? _selectedIconPaths[1] : _iconPaths[1],
            // Switch icons
            width: 24,
            height: 24,
          ),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _selectedIndex == 2 ? _selectedIconPaths[2] : _iconPaths[2],
            // Switch icons
            width: 24,
            height: 24,
          ),
          label: 'Inbox',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            _selectedIndex == 3 ? _selectedIconPaths[3] : _iconPaths[3],
            // Switch icons
            width: 24,
            height: 24,
          ),
          label: 'Profile',
        ),
      ],
      onTap: _onItemTapped,
    );
  }
}


