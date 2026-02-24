import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/router/route_paths.dart';
import 'package:vendor_app/core/utils/app_icons.dart';
import 'package:vendor_app/core/utils/custom_bottom_navigation.dart';
import 'package:vendor_app/core/utils/app_message.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_provider.dart';
import 'package:vendor_app/features/profile/data/models/request/user_portfolio_request.dart';
import 'package:vendor_app/features/profile/data/models/resposne/vendor_details_model.dart';
import 'package:vendor_app/features/profile/presentation/screens/edit_vendor_profile_screen.dart';
import 'package:vendor_app/features/profile/presentation/screens/help_support_screen.dart';
import 'package:vendor_app/features/profile/presentation/screens/manage_notification_screen.dart';
import 'package:vendor_app/features/profile/presentation/screens/manage_service_details.dart';
import 'package:vendor_app/features/profile/presentation/screens/service_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int currentIndex;
  const ProfileScreen({required this.currentIndex, Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String currentTab = 'Portfolio';
  List<String> portfolioImages = [];
  VendorDetails? vendor;

  @override
  void initState() {
    super.initState();
    _fetchUserPortfolio();
    _fetchVendorDetails();
  }

  Future<void> _fetchVendorDetails() async {
    try {
      final user = await TokenStorage.getUserData();
      if (user == null) {
        _showMsg('User not found');
        return;
      }
      final vendorId = user.id ?? 0;
      final prov = context.read<AuthProvider>();
      // If provider already has vendor details, reuse them to avoid reloading
      if (prov.vendorDetails != null) {
        vendor = prov.vendorDetails;
        setState(() {});
        return;
      }

      await prov.fetchVendorDetails(vendorId);
      vendor = prov.vendorDetails;
      setState(() {});
      if (vendor == null) return;
    } catch (e) {
      _showMsg('Failed to fetch vendor details');
    }
  }

  Future<void> _fetchUserPortfolio() async {
    final user = await TokenStorage.getUserData();
    if (user == null) {
      _showMsg('User not found');
      return;
    }
    final int userId = user.id ?? 0;
    final prov = context.read<AuthProvider>();
    if (prov.userPortfolio.isNotEmpty) {
      final response = prov.userPortfolio;
      setState(() {
        portfolioImages = response.map((p) => p.fullUrl).toList();
      });
      return;
    }

    await prov.getUserPortfolio(userId);
    final response = prov.userPortfolio;
    setState(() {
      portfolioImages = response.map((p) => p.fullUrl).toList();
    });
  }

  Future<void> _pickAndUpload({
    required String folder,
    required void Function(String serverPath) onUploaded,
  }) async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (picked == null) return;
      final resp = await context.read<AuthProvider>().upload(picked.path, folder);
      if (resp == null || !resp.success || resp.path.trim().isEmpty) {
        _showMsg(context.read<AuthProvider>().message ?? 'Upload failed');
        return;
      }
      onUploaded(resp.path);
      _showMsg(resp.message);
    } catch (e) {
      _showMsg('Upload error: $e');
    }
  }

  Future<void> _uploadUserPortfolio(String imagePath) async {
    final user = await TokenStorage.getUserData();
    if (user == null) {
      _showMsg('User not found');
      return;
    }
    final request = UserPortfolioRequest(
      userId: user.id ?? 0,
      key: 'user_portfolio',
      imagePath: [imagePath],
    );
    await context.read<AuthProvider>().uploadUserPortfolio(request);
  }

  void _showMsg(String message) {
    if (!mounted) return;
    // ignore: unawaited_futures
    AppMessage.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    // Ensure status bar icons are dark (black)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(385.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 12, right: 12, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner image (bigger)
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      clipBehavior: Clip.antiAlias,
                      child: vendor?.businessPhoto != null && vendor!.businessPhoto!.isNotEmpty
                          ? Image.network(
                              vendor!.businessPhoto!.startsWith('http')
                                  ? vendor!.businessPhoto!
                                  : 'https://sevenoath.shofus.com/storage/${vendor!.businessPhoto}',
                              height: 230,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/banner_image.png',
                                  height: 230,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/banner_image.png',
                              height: 230,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendor?.businessName ?? 'Your Business Name',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vendor?.categoryName ?? 'Category',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Image.asset(AppIcons.editIcon, width: 20, height: 20),
                          onPressed: () async {
                            if (vendor == null) {
                              _showMsg('Please wait, loading vendor details...');
                              return;
                            }
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditVendorProfileScreen(
                                  vendorDetails: vendor!,
                                ),
                              ),
                            );
                            // Refresh vendor details if update was successful
                            if (result == true) {
                              await _fetchVendorDetails();
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Tabs row with only bottom dividing lines (no boxed background) - centered
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTab('Portfolio'),
                        const SizedBox(width: 24),
                        _buildTab('Settings'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: currentTab == 'Portfolio' ? _buildPortfolioSection() : _buildSettingsSection(),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavigation(currentIndex: widget.currentIndex),
      ),
    );
  }

  Widget _buildTab(String title) {
    final selected = currentTab == title;
    return GestureDetector(
      onTap: () => setState(() => currentTab = title),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Onest',
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFFFF4678) : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 70,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFF4678) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // Portfolio Section
  Widget _buildPortfolioSection() {
    return Column(
      children: [
        if (portfolioImages.isEmpty) _buildEmptyPortfolioSection() else _buildPortfolioImagesSection(),
      ],
    );
  }

  Widget _buildEmptyPortfolioSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          // Empty state GIF
          Image.asset(
            AppIcons.emptyGif,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          const Text(
            'Nothing in your portfolio right now',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Onest',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Get up and build your portfolio, this will boost up your profile',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // Upload button
          GestureDetector(
            onTap: () {
              _pickAndUpload(
                folder: 'user_portfolio',
                onUploaded: (path) async {
                  setState(() => portfolioImages.add(path));
                  await _uploadUserPortfolio(path);
                },
              );
            },
            child: Container(
              width: double.infinity,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: ShapeDecoration(
                color: const Color(0xFFFF4678),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'Upload Media',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioImagesSection() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: portfolioImages.length + 1, // +1 for the add button
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            // Last item is the "add more" button
            if (index == portfolioImages.length) {
              return GestureDetector(
                onTap: () {
                  _pickAndUpload(
                    folder: 'user_portfolio',
                    onUploaded: (path) async {
                      setState(() => portfolioImages.add(path));
                      await _uploadUserPortfolio(path);
                    },
                  );
                },
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(8),
                  dashPattern: const [8, 4],
                  color: const Color(0xFFFF4678),
                  strokeWidth: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Image.asset(
                        AppIcons.galleryExportIcon,
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                ),
              );
            }
            
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(portfolioImages[index]),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        ),
      ],
    );
  }

  // Settings Section (no boxed background - only bottom borders)
  Widget _buildSettingsSection() {
    final items = <_SettingsItem>[
      // Temporarily hiding services tab; will re-enable later
      // _SettingsItem(
      //   iconData: CupertinoIcons.list_bullet,
      //   iconBgColor: const Color(0xFF4CAF50),
      //   title: 'My Services',
      //   description: 'View and manage your services list',
      //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen())),
      // ),
      _SettingsItem(
        iconPath: AppIcons.briefcaseIcon,
        iconBgColor: const Color(0xFF00AEFF),
        title: 'Manage Service Details',
        description: 'Edit or add any service related information that you want your clients to know',
        onTap: () {
          final businessCategoryName = vendor?.categoryName ?? '';
          final subCategoryId = vendor?.categoryId ?? 0;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageServiceDetailsScreen(type: businessCategoryName, subCategoryId: subCategoryId),
            ),
          );
        },
      ),
      _SettingsItem(
        iconPath: AppIcons.notificationNewIcon,
        iconBgColor: const Color(0xFFAE00FF),
        title: 'Manage Notifications',
        description: 'Manage how you receive updates and reminders, by individually toggling settings',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageNotificationScreen())),
      ),
      _SettingsItem(
        iconPath: AppIcons.lifeBuoyIcon,
        iconBgColor: const Color(0xFF14A38B),
        title: 'Help and Support',
        description: 'Get all your queries solved by our various modes of help and support system',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpAndSupportScreen())),
      ),
      _SettingsItem(
        iconPath: AppIcons.logoutNewIcon,
        iconBgColor: const Color(0xFFFF7171),
        title: 'Logout',
        description: 'Logout from your account, and login whenever needed',
        onTap: () async {
          await TokenStorage.clear();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, RoutePaths.phoneVerify);
        },
        isLast: true,
      ),
    ];

    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFF9F9F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((it) {
            return InkWell(
              onTap: it.onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16, right: 8, bottom: 16),
                decoration: it.isLast
                    ? null
                    : const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Color(0x1470737C),
                          ),
                        ),
                      ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: ShapeDecoration(
                        color: it.iconBgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: it.iconData != null
                            ? Icon(it.iconData, size: 24, color: Colors.white)
                            : Image.asset(
                                it.iconPath ?? '',
                                width: 24,
                                height: 24,
                              ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.title,
                            style: const TextStyle(
                              color: Color(0xFF171719),
                              fontSize: 16,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w500,
                              height: 1.47,
                              letterSpacing: 0.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            it.description,
                            style: const TextStyle(
                              color: Color(0x9B37383C),
                              fontSize: 12,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w400,
                              height: 1.17,
                              letterSpacing: 0.17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SettingsItem {
  // if iconData is supplied we ignore iconPath and show a native Icon
  final IconData? iconData;
  final String? iconPath;
  final Color iconBgColor;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool isLast;
  
  _SettingsItem({
    this.iconData,
    this.iconPath,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.onTap,
    this.isLast = false,
  });
}