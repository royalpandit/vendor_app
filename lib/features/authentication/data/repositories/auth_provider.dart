// lib/features/auth/presentation/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:vendor_app/core/network/api_result.dart';
import 'package:vendor_app/core/network/base_response.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/core/session/session.dart';
import 'package:vendor_app/features/authentication/data/models/request/vendor_create_request.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/category_model_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/master_image_upload_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/send_otp_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/subcategory_model_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/verify_otp_response.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_repository.dart';
import 'package:vendor_app/features/booking/data/models/resposne/active_booking_model.dart';
import 'package:vendor_app/features/chat/data/model/resposen/conversation_chat_model.dart';
import 'package:vendor_app/features/chat/data/model/resposen/inbox_response.dart';
import 'package:vendor_app/features/home/data/models/request/update_booking_status_request.dart';
import 'package:vendor_app/features/home/data/models/resposne/dashboard_response.dart';
import 'package:vendor_app/features/home/data/models/resposne/new_lead.dart';
import 'package:vendor_app/features/home/data/models/resposne/update_booking_status_response.dart';
import 'package:vendor_app/features/profile/data/models/request/notification_settings_request.dart';
import 'package:vendor_app/features/profile/data/models/request/send_message_request.dart';
import 'package:vendor_app/features/profile/data/models/request/service_add_request.dart';
import 'package:vendor_app/features/profile/data/models/request/user_portfolio_request.dart';
import 'package:vendor_app/features/profile/data/models/request/venue_create_request.dart';
import 'package:vendor_app/features/profile/data/models/resposne/amenity_model_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/booking_invoice_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/cities_data.dart';
import 'package:vendor_app/features/profile/data/models/resposne/contact_support_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/faq_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/get_user_portfolio_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/notification_settings_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/service_add_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/service_details_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/states_data.dart';
import 'package:vendor_app/features/profile/data/models/resposne/user_portfolio_resposne.dart';
import 'package:vendor_app/features/profile/data/models/resposne/vendor_details_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthRepository _repo; // <- final हटाया
  AuthProvider(this._repo);

  // ProxyProvider update() से repo बदलने के लिए
  void updateRepo(AuthRepository repo) {
    _repo = repo;
  }
  String? verifyType;
  bool loading = false;
  String? message;
  String? devOtp; // demo: server sample me OTP aata hai
  bool isLoggedIn = false; // verify ke baad true
  bool success = false;

  double progress = 0.0;
  MasterImageUploadResponse? last;
  List<CategoryModelResponse> categories = [];
  List<NewLead> bookingLeads = [];
  List<ActiveBookingModel> activeBookingsModels = [];
  List<GetUserPortfolioResponse> userPortfolio = [];
  NotificationSettingsResponse? notificationSettings;
  List<InboxResponse> inboxMessages = [];
  List<SubcategoryModelResponse> subcategories = [];
  List<ConversationItem> conversationMessages = [];
  List<AmenityModelResponse> amenities = [];

  DashboardResponse? dashboardData;
  VendorDetails? vendorDetails;
  ServiceAddResponse? createdService;
  VenueCreateResponse? createdVenue;
  List<CityItem> cities = [];
  List<StateItem> states = [];
  
  // New state variables for help & support
  List<ContactSupportResponse> contactSupport = [];
  List<FaqResponse> faqs = [];
  ServiceDetailsResponse? serviceDetails;
  BookingInvoiceResponse? bookingInvoice;

  Future<void> sendOtp(String phone) async {
    loading = true;
    message = null;
    devOtp = null;
    notifyListeners();

    final res = await _repo.sendOtp(phone);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<SendOtpResponse>>():
        message = res.data.message ?? 'OTP sent';
        devOtp = res.data.data?.otp; // sample server response
      case ApiFailure():
        message = res.message;
    }
    notifyListeners();
  }

  Future<bool> verifyOtp({
    required String phone,
    required String token,
    required String role,
  }) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.verifyOtp(phone: phone, token: token, role: role);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<VerifyOtpResponse>>():
        final v = res.data.data; // <-- data object
        final t = v?.token ?? '';
        verifyType = v?.verifyType;
        Session.token = t;
        if (t.isNotEmpty) {
          await TokenStorage.saveTokenAndUserData(
            token: t, // Save the token
            user: v!.user, // Save the user data
          );
          //   await TokenStorage.saveToken(t);      // prefs-only
          isLoggedIn = true;
        } else {
          isLoggedIn = false;
        }
        message = res.data.message ?? 'Login success';
        notifyListeners();
        return isLoggedIn; // <-- MUST return true if token exists

      case ApiFailure():
        message = res.message;
        isLoggedIn = false;
        notifyListeners();
        return false;
    }
  }

  Future<void> fetchCategories() async {
    loading = true;
    message = null;
    notifyListeners();
    final res = await _repo.getCategories();
    loading = false;

    switch (res) {
      case ApiSuccess<BaseResponse<List<CategoryModelResponse>>>():
        categories = res.data.data ?? [];
        message = res.data.message;
      case ApiFailure():
        message = res.message;
    }
    notifyListeners();
  }

  Future<void> fetchSubcategories(int categoryId) async {
    loading = true;
    message = null;
    notifyListeners();
    final res = await _repo.getSubcategories(categoryId);
    loading = false;

    switch (res) {
      case ApiSuccess<BaseResponse<List<SubcategoryModelResponse>>>():
        subcategories = res.data.data ?? [];
        message = res.data.message;
      case ApiFailure():
        message = res.message;
    }
    notifyListeners();
  }

  Future<MasterImageUploadResponse?> upload(
    String filePath,
    String folder,
  ) async {
    loading = true;
    message = null;
    progress = 0;
    last = null;
    notifyListeners();

    final res = await _repo.upload(
      filePath: filePath,
      folder: folder,
      onProgress: (sent, total) {
        if (total > 0) {
          progress = sent / total;
          notifyListeners();
        }
      },
    );

    loading = false;
    switch (res) {
      case ApiSuccess<MasterImageUploadResponse>():
        last = res.data;
        message = res.data.message;
        notifyListeners();
        return res.data;
      case ApiFailure():
        message = res.message;
        notifyListeners();
        return null;
    }
  }

  // AuthProvider (या UploadProvider) में

  Future<bool> create(VendorCreateRequest req) async {
    loading = true;
    message = null;
    success = false;
    notifyListeners();

    final res = await _repo.createVendor(req);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<Object?>>():
        message = res.data.message ?? 'Vendor created successfully';
        success = (res.data.code ?? 200) >= 200 && (res.data.code ?? 200) < 300;
        notifyListeners();
        return success;

      case ApiFailure():
        message = res.message;
        success = false;
        notifyListeners();
        return false;
    }
  }

  Future<void> fetchVendorDashboard(int userId) async {
    loading = true;
    message = null; // Clear any previous messages
    notifyListeners();

    try {
      // Call the API to fetch vendor dashboard data
      final res = await _repo.getVendorDashboard(userId);

      loading = false;

      if (res is ApiSuccess<BaseResponse<DashboardResponse>>) {
        // Handle success response
        if (res.data != null) {
          dashboardData = res.data!.data; // Access the 'data' from the response
          message = res.data!.message ?? 'Dashboard fetched successfully';
        } else {
          message = 'No data available for the dashboard';
        }
      } else if (res is ApiFailure<BaseResponse<DashboardResponse>>) {
        // Handle failure response
        message =
            res.message ??
            'Failed to fetch dashboard data'; // Access the message
      }
    } catch (e) {
      loading = false;
      message = 'Error: ${e.toString()}'; // Capture any error
    }

    notifyListeners();
  }

  Future<void> fetchBookingLeads(int userId) async {
    loading = true;
    message = null;
    notifyListeners();

    try {
      final res = await _repo.getBookingLeads(userId);
      loading = false;
      if (res is ApiSuccess<BaseResponse<List<NewLead>>>) {
        // Handle success response
        if (res.data != null) {
          // Accessing the 'data' from BaseResponse
          bookingLeads =
              res.data!.data!; // Access the list of leads (data) here
          message = bookingLeads.isNotEmpty
              ? 'Booking leads fetched successfully'
              : 'No leads available';
        }
      } else if (res is ApiFailure<BaseResponse<List<NewLead>>>) {
        message = res.message ?? 'Failed to fetch booking leads';
      }
    } catch (e) {
      loading = false;
      message = 'Error: ${e.toString()}';
    }

    notifyListeners();
  }

  // Fetch Active Bookings
  Future<void> fetchActiveBookings(int userId) async {
    loading = true;
    message = null;
    notifyListeners();
    try {
      final res = await _repo.getActiveBookings(userId);
      loading = false;
      if (res is ApiSuccess<BaseResponse<List<ActiveBookingModel>>>) {
        // Handle success response
        if (res.data != null) {
          activeBookingsModels = res.data!.data!;
          ; // Save active bookings
          message =activeBookingsModels.isNotEmpty
              ? 'Active bookings fetched successfully'
              : 'No active bookings available';
        } else {
          message = 'No active bookings available';
        }
      } else if (res is ApiFailure<BaseResponse<List<ActiveBookingModel>>>) {
        message = res.message ?? 'Failed to fetch active bookings';
      }
    } catch (e) {
      loading = false;
      message = 'Error: ${e.toString()}';
    }

    notifyListeners();
  }
  Future<void> uploadUserPortfolio(UserPortfolioRequest request) async {
    loading = true;
    message = null;
    notifyListeners();

    try {
      final res = await _repo.uploadUserPortfolio(request);

      loading = false;
      if (res is ApiSuccess<BaseResponse<UserPortfolioResposne>>) {
        if (res.data != null) {
          message = 'Portfolio updated successfully';
        } else {
          message = 'Failed to update portfolio';
        }
      } else if (res is ApiFailure<BaseResponse<UserPortfolioResposne>>) {
        message = res.message ?? 'Failed to upload portfolio image';
      }
    } catch (e) {
      loading = false;
      message = 'Error: ${e.toString()}';
    }
    notifyListeners();
  }
  Future<void> getUserPortfolio(int userId) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.getUserPortfolio(userId);

    loading = false;
    if (res is ApiSuccess<BaseResponse<List<GetUserPortfolioResponse>>>) {
      if (res.data != null) {
        userPortfolio = res.data!.data!;
        message = 'Portfolio fetched successfully';
      } else {
        message = 'No portfolio images available';
      }
    } else if (res is ApiFailure<BaseResponse<List<GetUserPortfolioResponse>>>) {
      message = res.message ?? 'Failed to fetch portfolio';
    }

    notifyListeners();
  }

  Future<void> updateNotificationSettings(NotificationSettingsRequest request) async {
    loading = true;
    message = null;
    notifyListeners();

    try {
      final res = await _repo.updateNotificationSettings(request);

      loading = false;
      if (res is ApiSuccess<BaseResponse<NotificationSettingsResponse>>) {
        success = true;
        message = res.data!.message ?? 'Notification settings updated successfully.';
      } else if (res is ApiFailure<BaseResponse<NotificationSettingsResponse>>) {
        message = res.message ?? 'Failed to update notification settings';
      }
    } catch (e) {
      loading = false;
      message = 'Error: ${e.toString()}';
    }

    notifyListeners();
  }
  Future<void> fetchNotificationSettings(int userId) async {
    loading = true;
    message = null;
    notifyListeners();

    try {
      final res = await _repo.getNotificationSettings(userId);
      loading = false;

      if (res is ApiSuccess<BaseResponse<NotificationSettingsResponse>>) {
        notificationSettings = res.data.data;
        message = res.data!.message ?? 'Notification settings fetched successfully.';

      //  message = 'Notification settings fetched successfully';
      } else if (res is ApiFailure<BaseResponse<NotificationSettingsResponse>>) {
        message = res.message ?? 'Failed to update notification settings';
      }
    } catch (e) {
      loading = false;
      message = 'Error: $e';
    }

    notifyListeners();
  }

  Future<void> fetchInboxMessages(int userId) async {
    loading = true;
    message = null;
    notifyListeners();

    try {
      final res = await _repo.getInboxMessages(userId);
      loading = false;

      if (res is ApiSuccess<BaseResponse<List<InboxResponse>>>) {
        if (res.data != null) {
          inboxMessages = res.data!.data!;
          ; // Save active bookings
          message =inboxMessages.isNotEmpty
              ? 'Inbox messages fetched successfully'
              : 'Failed to fetch inbox messages';
        } else {
          message = 'Failed to fetch inbox messages';
        }

      } else if (res is ApiFailure<BaseResponse<List<InboxResponse>>>) {
        message = res.message ?? 'Failed to fetch active bookings';
      }
    } catch (e) {
      loading = false;
      message = 'Error: $e';
    }

    notifyListeners();
  }

  Future<void> fetchConversationMessages(int conversationId) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.getConversationMessages(conversationId);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<List<ConversationItem>>>():
        conversationMessages = res.data.data ?? [];
        message = res.data.message ?? 'Conversation fetched successfully';
      case ApiFailure():
        message = res.message ?? 'Failed to fetch conversation messages';
    }
    notifyListeners();
  }




  Future<void> fetchVendorDetails(int vendorId) async {
    loading = true;
    message = null;
    notifyListeners();


    final res = await _repo.getVendorDetails(vendorId);


    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<VendorDetails>>():
        vendorDetails = res.data.data;
        message = res.data.message ?? 'Vendor details fetched successfully';
      case ApiFailure():
        message = res.message ?? 'Failed to fetch vendor details';
    }
    notifyListeners();
  }
  Future<bool> createService(ServiceAddRequest req) async {
    loading = true; message = null; success = false; createdService = null;
    notifyListeners();

    final res = await _repo.addService(req);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<ServiceAddResponse>>():
        createdService = res.data.data;
        message = res.data.message ?? 'Service added successfully';
        success = (res.data.code ?? 200) >= 200 && (res.data.code ?? 200) < 300;
        notifyListeners();
        return success;
      case ApiFailure():
        message = res.message;
        success = false;
        notifyListeners();
        return false;
    }
  }

  Future<bool> createVenue(VenueCreateRequest req) async {
    loading = true; message = null; success = false; createdVenue = null;
    notifyListeners();

    final res = await _repo.addVenue(req);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<VenueCreateResponse>>():
        createdVenue = res.data.data ??
            VenueCreateResponse(
              status: res.data.status,
              code: res.data.code,
              message: res.data.message,
            );
        message = res.data.message ?? 'Venue created successfully';
        success = (res.data.code ?? 200) >= 200 && (res.data.code ?? 200) < 300;
        notifyListeners();
        return success;
      case ApiFailure():
        message = res.message;
        success = false;
        notifyListeners();
        return false;
    }
  }

  Future<void> fetchAmenities() async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.getAmenities();

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<List<AmenityModelResponse>>>():
        amenities = res.data.data ?? [];
        message = res.data.message ?? 'Amenities loaded';
      case ApiFailure():
        amenities = [];
        message = res.message ?? 'Failed to load amenities';
    }
    notifyListeners();
  }

  // ---------- LOAD STATES ----------
  Future<bool> loadStates({bool force = false}) async {
    if (states.isNotEmpty && !force) return true;

    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.fetchStates();

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<StatesData>>():
        states = res.data.data?.states ?? [];
        message = res.data.message;
        notifyListeners();
        return true;

      case ApiFailure():
        states = [];
        message = res.message;
        notifyListeners();
        return false;
    }
  }

  // ---------- LOAD CITIES FOR A STATE ----------
  Future<bool> loadCities(int stateId) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.fetchCities(stateId);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<CitiesData>>():
        cities = res.data.data?.cities ?? [];
        message = res.data.message;
        notifyListeners();
        return true;

      case ApiFailure():
        cities = [];
        message = res.message;
        notifyListeners();
        return false;
    }
  }
  Future<bool> updateBookingStatus({
    required int bookingId,
    required String action, // approve | reject
  }) async {

    loading = true;
    message = null;
    notifyListeners();

    final req = UpdateBookingStatusRequest(
      bookingId: bookingId,
      action: action,
    );

    final res = await _repo.updateBookingStatus(req);

    loading = false;

    switch (res) {
      case ApiSuccess<BaseResponse<UpdateBookingStatusResponse>>():
        message = res.data.message ??
            'Booking status updated successfully';
        notifyListeners();
        return true;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return false;
    }
  }

  // ---------- HELP & SUPPORT ----------
  
  /// Fetch contact support details
  Future<bool> fetchContactSupport() async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.getContactSupport();

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<List<ContactSupportResponse>>>():
        contactSupport = res.data.data ?? [];
        message = res.data.message;
        notifyListeners();
        return true;

      case ApiFailure():
        contactSupport = [];
        message = res.message;
        notifyListeners();
        return false;
    }
  }

  /// Fetch FAQs
  Future<bool> fetchFaqs() async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.getFaqs();

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<List<FaqResponse>>>():
        faqs = res.data.data ?? [];
        message = res.data.message;
        notifyListeners();
        return true;

      case ApiFailure():
        faqs = [];
        message = res.message;
        notifyListeners();
        return false;
    }
  }

  // ---------- SERVICE OPERATIONS ----------
  
  /// Get service details
  Future<bool> fetchServiceDetails(int serviceId) async {
    loading = true;
    message = null;
    serviceDetails = null;
    notifyListeners();

    final res = await _repo.getServiceDetails(serviceId);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<ServiceDetailsResponse>>():
        serviceDetails = res.data.data;
        message = res.data.message;
        notifyListeners();
        return true;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return false;
    }
  }

  /// Get service list
  Future<Map<String, dynamic>?> fetchServiceList({
    String type = 'service',
    int? vendorId,
    int? subcategoryId,
    String? search,
    int perPage = 15,
  }) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.getServiceList(
      type: type,
      vendorId: vendorId,
      subcategoryId: subcategoryId,
      search: search,
      perPage: perPage,
    );

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<Map<String, dynamic>>>():
        message = res.data.message;
        notifyListeners();
        return res.data.data;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return null;
    }
  }

  /// Update service
  Future<bool> updateService(Map<String, dynamic> data) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.updateService(data);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<Map<String, dynamic>>>():
        message = res.data.message ?? 'Service updated successfully';
        notifyListeners();
        return true;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return false;
    }
  }

  // ---------- BOOKING OPERATIONS ----------
  
  /// Get booking details
  Future<Map<String, dynamic>?> fetchBookingDetails(int bookingId) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.getBookingDetails(bookingId);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<Map<String, dynamic>>>():
        message = res.data.message;
        notifyListeners();
        return res.data.data;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return null;
    }
  }

  /// Get booking invoice
  Future<bool> fetchBookingInvoice(int bookingId) async {
    loading = true;
    message = null;
    bookingInvoice = null;
    notifyListeners();

    final res = await _repo.getBookingInvoice(bookingId);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<BookingInvoiceResponse>>():
        bookingInvoice = res.data.data;
        message = res.data.message;
        notifyListeners();
        return true;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return false;
    }
  }

  /// Create bookings from shortlist
  Future<List<Map<String, dynamic>>?> createBookingsFromShortlist(
    int userId,
    List<int> shortlistIds,
  ) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.createBookings(userId, shortlistIds);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<List<Map<String, dynamic>>>>():
        message = res.data.message ?? 'Bookings created successfully';
        notifyListeners();
        return res.data.data;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return null;
    }
  }

  /// Get bookings by user
  Future<List<Map<String, dynamic>>?> fetchBookings(int userId) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.getBookings(userId);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<List<Map<String, dynamic>>>>():
        message = res.data.message;
        notifyListeners();
        return res.data.data;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return null;
    }
  }

  /// Delete booking
  Future<bool> removeBooking(int userId, int bookingId) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.deleteBooking(userId, bookingId);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<Map<String, dynamic>>>():
        message = res.data.message ?? 'Booking deleted successfully';
        notifyListeners();
        return true;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return false;
    }
  }

  // ---------- MESSAGE OPERATIONS ----------
  
  /// Send message
  Future<bool> sendMessage({
    required int senderId,
    required int receiverId,
    required String messageText,
  }) async {
    loading = true;
    message = null;
    notifyListeners();

    final req = SendMessageRequest(
      senderId: senderId,
      receiverId: receiverId,
      message: messageText,
    );

    final res = await _repo.sendMessage(req);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<Object?>>():
        message = res.data.message ?? 'Message sent successfully';
        notifyListeners();
        return true;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return false;
    }
  }

  // ---------- VENDOR OPERATIONS ----------
  
  /// Get all vendors
  Future<Map<String, dynamic>?> fetchVendors({int perPage = 10}) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.getVendors(perPage: perPage);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<Map<String, dynamic>>>():
        message = res.data.message;
        notifyListeners();
        return res.data.data;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return null;
    }
  }

  /// Update vendor
  Future<bool> updateVendorData(int vendorId, Map<String, dynamic> data) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.updateVendor(vendorId, data);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<Map<String, dynamic>>>():
        message = res.data.message ?? 'Vendor updated successfully';
        notifyListeners();
        return true;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return false;
    }
  }

  /// Delete user
  Future<bool> removeUser(int userId) async {
    loading = true;
    message = null;
    notifyListeners();

    final res = await _repo.deleteUser(userId);

    loading = false;
    switch (res) {
      case ApiSuccess<BaseResponse<Object?>>():
        message = res.data.message ?? 'User deleted successfully';
        notifyListeners();
        return true;

      case ApiFailure():
        message = res.message;
        notifyListeners();
        return false;
    }
  }

}
