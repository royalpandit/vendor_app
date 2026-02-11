// lib/core/network/endpoints.dart
class Endpoints {
  static const sendOtp = '/api/auth/send-otp';
  static const verifyOtp = '/api/auth/verify-otp';
  static const categories = '/api/categories';
  static const subCategories = '/api/sub-categories'; // ?category_id=
  static const masterImageUpload = '/api/master-image-upload';
  static const createVendors = '/api/vendors';
  static const vendorDashboard = '/api/vendor/dashboard';
  static const bookingLeads = '/api/vendor/booking-leads';
  static const vendorBookings = '/api/vendor/bookings';
  static const userPortfolio = '/api/user_portfolio';
  static const userPortfolioGet = '/api/user_portfolio/';
  static const String notificationSettings = '/api/notification-settings';
  static const String inboxMessages = '/api/user/inbox';
  static const String conversationMessages = '/api/conversation/messages'; // ?conversation_id=
  static const String vendorDetails = '/api/vendor-details';
  static const String serviceAdd = '/api/v1/services/add';
  static const String venueAdd   = '/api/venues';
  static const String amenities = '/api/amenity';
  static const states          = '/api/states';
  static const cities          = '/api/cities';
  static const updateBookingStatus = '/api/bookings/update-status';

}
