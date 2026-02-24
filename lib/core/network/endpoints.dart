// lib/core/network/endpoints.dart
class Endpoints {
  // Auth
  static const sendOtp = '/api/auth/send-otp';
  static const verifyOtp = '/api/auth/verify-otp';
  
  // Categories & Subcategories
  static const categories = '/api/categories';
  static const subCategories = '/api/sub-categories'; // ?category_id=
  
  // Images
  static const masterImageUpload = '/api/master-image-upload';
  
  // Vendors
  static const createVendors = '/api/vendors';
  static const vendors = '/api/vendors'; // GET list, PUT update
  static const vendorDetails = '/api/vendor-details';
  static const vendorDashboard = '/api/vendor/dashboard';
  
  // Services
  static const serviceAdd = '/api/v1/services/add';
  static const serviceMetaFields = '/api/service-meta-fields';
  static const serviceDetails = '/api/service-details'; // ?id=
  static const serviceList = '/api/service-list';
  static const serviceUpdate = '/api/service-update';
  
  // Venues
  static const venueAdd = '/api/venues';
  static const amenities = '/api/amenity';
  
  // Bookings
  static const bookings = '/api/bookings';
  static const bookingLeads = '/api/vendor/booking-leads';
  static const vendorBookings = '/api/vendor/bookings';
  static const bookingDetails = '/api/details/booking'; // ?booking_id=
  static const updateBookingStatus = '/api/bookings/update-status';
  static const bookingInvoice = '/api/bookings/invoice'; // ?booking_id=
  
  // Portfolio
  static const userPortfolio = '/api/user_portfolio';
  static const userPortfolioGet = '/api/user_portfolio/';
  
  // Notifications
  static const notificationSettings = '/api/notification-settings';
  
  // Messages & Chat
  static const inboxMessages = '/api/user/inbox';
  static const conversationMessages = '/api/conversation/messages'; // ?conversation_id=
  static const sendMessage = '/api/messages/send';
  static const markMessagesRead = '/api/messages/read';
  
  // Chat / conversation actions
  static const deleteConversation = '/api/conversation/delete';
  static const deleteMessage = '/api/message/delete';
  
  // Location
  static const states = '/api/states';
  static const cities = '/api/cities';
  
  // User
  static const deleteUser = '/api/user'; // DELETE /api/user/{id}
  
  // Help & Support
  static const contactSupport = '/api/help/contact-support';
  static const faqs = '/api/help/faqs';
}
