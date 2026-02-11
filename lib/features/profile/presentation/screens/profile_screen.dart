import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/router/route_paths.dart';
import 'package:vendor_app/core/utils/app_colors.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/core/utils/custom_bottom_navigation.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/profile/data/models/request/user_portfolio_request.dart';
import 'package:vendor_app/features/profile/data/models/resposne/vendor_details_model.dart';
import 'package:vendor_app/features/profile/presentation/screens/help_support_screen.dart';
import 'package:vendor_app/features/profile/presentation/screens/manage_notification_screen.dart';
import 'package:vendor_app/features/profile/presentation/screens/manage_service_details.dart';
class ProfileScreen extends StatefulWidget {
  final int currentIndex;
  ProfileScreen({required this.currentIndex});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String currentTab = 'Portfolio';
  List<String> portfolioImages = []; // To hold the fetched portfolio images
  VendorDetails? vendor;
  @override
  void initState() {
    super.initState();
    _fetchUserPortfolio();
    _fetchVendorDetails();// Fetch portfolio images when screen is loaded
  }
  Future<void> _fetchVendorDetailss() async {
    try {
      final user = await TokenStorage.getUserData();
      if (user == null) {
        _showMsg('User not found');
        return;
      }

      final vendorId = user.id ?? 0; // अगर vendorId अलग हो तो यहां सही id दें

      await context.read<AuthProvider>().fetchVendorDetails(vendorId);

      final fetched = context.read<AuthProvider>().vendorDetails;
      vendor = fetched;
      setState(() {}); // UI refresh (header में नाम/कैटेगरी दिखाने के लिए)

      // LOG: पूरी object + एक-एक फ़ील्ड
      if (fetched == null) {
        debugPrint('VendorDetails: null');
        return;
      }

      // पूरा JSON जैसा print (readable)
      final map = {
        'name': fetched.name,
        'phone': fetched.phone,
        'email': fetched.email,
        'adhar_number': fetched.adharNumber,
        'business_name': fetched.businessName,
        'business_category': fetched.businessCategory,
        'experience_in_business': fetched.experienceInBusiness,
        'price_range': fetched.priceRange,
        'service_coverage': fetched.serviceCoverage,
        'business_address': fetched.businessAddress,
        'business_description': fetched.businessDescription,
        'benefits': fetched.benefits,
        'business_photo': fetched.businessPhoto,
        'adhar_photo': fetched.adharPhoto,
        'certificate_photo': fetched.certificatePhoto,
        'status': fetched.status,
        'latitude': fetched.latitude,
        'longitude': fetched.longitude,
        'serviceCoverageList': fetched.serviceCoverageList,
        'lat(double)': fetched.lat,
        'lng(double)': fetched.lng,
      };
      debugPrint('VendorDetails (map): ${const JsonEncoder.withIndent("  ").convert(map)}');

      // एक-एक फ़ील्ड अलग से भी (ज़रूरत पड़े तो)
      debugPrint('name: ${fetched.name}');
      debugPrint('phone: ${fetched.phone}');
      debugPrint('email: ${fetched.email}');
      debugPrint('adhar_number: ${fetched.adharNumber}');
      debugPrint('business_name: ${fetched.businessName}');
      debugPrint('business_category: ${fetched.businessCategory}');
      debugPrint('experience_in_business: ${fetched.experienceInBusiness}');
      debugPrint('price_range: ${fetched.priceRange}');
      debugPrint('service_coverage(raw): ${fetched.serviceCoverage}');
      debugPrint('serviceCoverageList: ${fetched.serviceCoverageList}');
      debugPrint('business_address: ${fetched.businessAddress}');
      debugPrint('business_description: ${fetched.businessDescription}');
      debugPrint('benefits: ${fetched.benefits}');
      debugPrint('business_photo: ${fetched.businessPhoto}');
      debugPrint('adhar_photo: ${fetched.adharPhoto}');
      debugPrint('certificate_photo: ${fetched.certificatePhoto}');
      debugPrint('status: ${fetched.status}');
      debugPrint('latitude(raw): ${fetched.latitude} | lat(double): ${fetched.lat}');
      debugPrint('longitude(raw): ${fetched.longitude} | lng(double): ${fetched.lng}');
    } catch (e) {
      debugPrint('fetchVendorDetails error: $e');
      _showMsg('Failed to fetch vendor details');
    }
  }
  Future<void> _fetchVendorDetails() async {
    try {
      final user = await TokenStorage.getUserData();
      if (user == null) {
        _showMsg('User not found');
        return;
      }

      final vendorId = user.id ?? 0; // अगर vendorId अलग हो तो यहां सही id दें

      await context.read<AuthProvider>().fetchVendorDetails(vendorId);

      final fetched = context.read<AuthProvider>().vendorDetails;
      vendor = fetched;
      setState(() {}); // UI refresh (header में नाम/कैटेगरी दिखाने के लिए)

      // LOG: पूरी object + एक-एक फ़ील्ड
      if (fetched == null) {
        debugPrint('VendorDetails: null');
        return;
      }

      // ✅ business_category को proper object की तरह print करें
      final businessCategoryJson = fetched.businessCategory?.toJson();

      // पूरा JSON जैसा print (readable)
      final map = {
        'name': fetched.name,
        'phone': fetched.phone,
        'email': fetched.email,
        'adhar_number': fetched.adharNumber,
        'business_name': fetched.businessName,

        // 👇 NEW: object रूप में
        'business_category': businessCategoryJson, // {category_id, name}

        // 👇 convenience भी साथ में (debug के लिए)
        'business_category_id': fetched.categoryId,
        'business_category_name': fetched.categoryName,

        'experience_in_business': fetched.experienceInBusiness,
        'price_range': fetched.priceRange,
        'service_coverage': fetched.serviceCoverage,
        'business_address': fetched.businessAddress,
        'business_description': fetched.businessDescription,
        'benefits': fetched.benefits,
        'business_photo': fetched.businessPhoto,
        'adhar_photo': fetched.adharPhoto,
        'certificate_photo': fetched.certificatePhoto,
        'status': fetched.status,
        'latitude': fetched.latitude,
        'longitude': fetched.longitude,
        'serviceCoverageList': fetched.serviceCoverageList,
        'lat(double)': fetched.lat,
        'lng(double)': fetched.lng,
      };
      debugPrint('VendorDetails (map): ${const JsonEncoder.withIndent("  ").convert(map)}');

      // एक-एक फ़ील्ड अलग से भी (ज़रूरत पड़े तो)
      debugPrint('name: ${fetched.name}');
      debugPrint('phone: ${fetched.phone}');
      debugPrint('email: ${fetched.email}');
      debugPrint('adhar_number: ${fetched.adharNumber}');
      debugPrint('business_name: ${fetched.businessName}');

      // 👇 NEW: category को readable तरीके से
      debugPrint('business_category.id: ${fetched.categoryId}');
      debugPrint('business_category.name: ${fetched.categoryName}');
      debugPrint('business_category(raw json): ${jsonEncode(businessCategoryJson)}');

      debugPrint('experience_in_business: ${fetched.experienceInBusiness}');
      debugPrint('price_range: ${fetched.priceRange}');
      debugPrint('service_coverage(raw): ${fetched.serviceCoverage}');
      debugPrint('serviceCoverageList: ${fetched.serviceCoverageList}');
      debugPrint('business_address: ${fetched.businessAddress}');
      debugPrint('business_description: ${fetched.businessDescription}');
      debugPrint('benefits: ${fetched.benefits}');
      debugPrint('business_photo: ${fetched.businessPhoto}');
      debugPrint('adhar_photo: ${fetched.adharPhoto}');
      debugPrint('certificate_photo: ${fetched.certificatePhoto}');
      debugPrint('status: ${fetched.status}');
      debugPrint('latitude(raw): ${fetched.latitude} | lat(double): ${fetched.lat}');
      debugPrint('longitude(raw): ${fetched.longitude} | lng(double): ${fetched.lng}');
    } catch (e) {
      debugPrint('fetchVendorDetails error: $e');
      _showMsg('Failed to fetch vendor details');
    }
  }

  // Fetch user portfolio images from the API
  Future<void> _fetchUserPortfolio() async {
    final user = await TokenStorage.getUserData();
    if (user == null) {
      _showMsg('User not found');
      return;
    }

     final int userId = user?.id ?? 0;
    // Fetch portfolio using the user ID
    await context.read<AuthProvider>().getUserPortfolio(userId);

    final response = context.read<AuthProvider>().userPortfolio;
    if (response != null && response.isNotEmpty) {
      setState(() {
        portfolioImages = response.map((image) => image.fullUrl).toList();
      });
    } else {
      setState(() {
        portfolioImages = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(260.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.lightPinkColor, Colors.white],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Image Inside a Rounded Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/banner_image.png',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Culinary Delights and Co.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Catering',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        icon: Image.asset(
                          AppIcons.editIcon,
                          width: 24,
                          height: 24,
                        ),
                        onPressed: () {
                          // Action for edit button
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentTab = 'Portfolio';
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'Portfolio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentTab == 'Portfolio'
                                    ? Colors.pink
                                    : Colors.grey,
                              ),
                            ),
                            if (currentTab == 'Portfolio')
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                height: 2,
                                width: 60,
                                color: Colors.pink,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentTab = 'Settings';
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentTab == 'Settings'
                                    ? Colors.pink
                                    : Colors.grey,
                              ),
                            ),
                            if (currentTab == 'Settings')
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                height: 2,
                                width: 60,
                                color: Colors.pink,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: currentTab == 'Portfolio'
              ? _buildPortfolioSection()
              : _buildSettingsSection(),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: 3),
    );
  }

  // Portfolio Section
  Widget _buildPortfolioSection() {
    return Column(
      children: [
        if (portfolioImages.isEmpty)
          _buildEmptyPortfolioSection(),
        if (portfolioImages.isNotEmpty)
          _buildPortfolioImagesSection(),
      ],
    );
  }

  // Display "Upload Media" button if no images are found
  Widget _buildEmptyPortfolioSection() {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'Nothing in your portfolio right now',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: Text(
            'Get up and build your portfolio, this will boost up your profile',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _pickAndUpload(
              folder: 'user_portfolio',
              onUploaded: (path) {
                setState(() {
                  portfolioImages.add(path); // Add uploaded image to the portfolio
                });
                _uploadUserPortfolio(path); // Upload the portfolio image path
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
          ),
          child: Text(
            'Upload Media',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Display the portfolio images after upload
  Widget _buildPortfolioImagesSection() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          itemCount: portfolioImages.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(portfolioImages[index]),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          },
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _pickAndUpload(
              folder: 'user_portfolio',
              onUploaded: (path) {
                setState(() {
                  portfolioImages.add(path);
                });
                _uploadUserPortfolio(path);
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
          ),
          child: Text(
            'Upload Another Media',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Method to pick and upload image
  Future<void> _pickAndUpload({
    required String folder,
    required void Function(String serverPath) onUploaded,
  }) async
  {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null) return;

      final resp = await context.read<AuthProvider>().upload(
        picked.path,
        folder,
      );
      if (resp == null || !resp.success || resp.path.trim().isEmpty) {
        _showMsg(context.read<AuthProvider>().message ?? 'Upload failed');
        return;
      }

      setState(() {
        onUploaded(resp.path);
      });
      _showMsg(resp.message);
    } catch (e) {
      _showMsg('Upload error: $e');
    }
  }

  // Upload User Portfolio
  Future<void> _uploadUserPortfolio(String imagePath) async {
    final user = await TokenStorage.getUserData();
    if (user == null) {
      _showMsg('User not found');
      return;
    }

    final request = UserPortfolioRequest(
       userId: user?.id ?? 0,
      key: 'user_portfolio',
      imagePath: [imagePath],
    );

    await context.read<AuthProvider>().uploadUserPortfolio(request);
  }

  // Show message helper function
  void _showMsg(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  // Settings Section
  Widget _buildSettingsSection() {
    return Column(
      children: [
      _buildSettingsOption(
      iconPath: AppIcons.manageServiceIcon,
      title: 'Manage Service Details',
      description: 'Edit or add any service related information.',
      onTap: () {
        final businessCategoryName = vendor?.businessCategory?.name ?? '';
        final subCategoryId = vendor?.businessCategory?.id ?? 0;
        final subId = subCategoryId != 0 ? subCategoryId : 0;

        // final businessCategory = vendor?.businessCategory ?? ''; // ← VendorDetails से
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageServiceDetailsScreen(
              type: businessCategoryName, // ← पास कर दिया
              subCategoryId: subId,
            ),
          ),
        );
      },
    ),
        _buildSettingsOption(
          iconPath: AppIcons.notificationIcon, // Your custom icon path
          title: 'Manage Notifications',
          description: 'Manage how you receive updates and reminders.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageNotificationScreen(),
              ),
            );
          },
        ),
        _buildSettingsOption(
          iconPath: AppIcons.helpIcon, // Your custom icon path
          title: 'Help and Support',
          description: 'Get all your queries solved with various modes of help.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HelpAndSupportScreen(),
              ),
            );
          },
        ),
        _buildSettingsOption(
          iconPath: AppIcons.logoutIcon, // Your custom icon path
          title: 'Logout',
          description: 'Logout from your account whenever needed.',
          onTap: () async {
            // Clear the token and user data on logout
            await TokenStorage.clear();

            // Redirect to the phone verification screen or login screen
            Navigator.pushReplacementNamed(context, RoutePaths.phoneVerify);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsOption({
    required String iconPath, // Custom icon path as String
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: AppColors.lightGrey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Custom icon inside a circle
              Image.asset(
                iconPath, // Use your custom icon here
                width: 34, // Adjust width
                height: 34, // Adjust height
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );}

}


