// lib/features/auth/data/auth_repository.dart

import 'package:vendor_app/core/network/api_exceptions.dart';
import 'package:vendor_app/core/network/api_result.dart';
import 'package:vendor_app/core/network/base_response.dart';
import 'package:vendor_app/core/network/token_storage.dart';
import 'package:vendor_app/features/authentication/data/models/request/send_otp_request.dart';
import 'package:vendor_app/features/authentication/data/models/request/vendor_create_request.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/category_model_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/master_image_upload_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/send_otp_response.dart';
import 'package:vendor_app/features/authentication/data/models/request/verify_otp_request.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/subcategory_model_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/verify_otp_response.dart';
import 'package:vendor_app/features/authentication/data/repositories/auth_api.dart';
import 'package:vendor_app/features/booking/data/models/resposne/active_booking_model.dart';
import 'package:vendor_app/features/chat/data/model/resposen/conversation_chat_model.dart';
import 'package:vendor_app/features/chat/data/model/resposen/inbox_response.dart';
import 'package:vendor_app/features/home/data/models/resposne/dashboard_response.dart';
import 'package:vendor_app/features/home/data/models/resposne/new_lead.dart';
import 'package:vendor_app/features/profile/data/models/request/notification_settings_request.dart';
import 'package:vendor_app/features/profile/data/models/request/service_add_request.dart';
import 'package:vendor_app/features/profile/data/models/request/user_portfolio_request.dart';
import 'package:vendor_app/features/profile/data/models/request/venue_create_request.dart';
import 'package:vendor_app/features/profile/data/models/resposne/amenity_model_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/cities_data.dart';
import 'package:vendor_app/features/profile/data/models/resposne/get_user_portfolio_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/notification_settings_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/service_add_response.dart';
import 'package:vendor_app/features/profile/data/models/resposne/states_data.dart';
import 'package:vendor_app/features/profile/data/models/resposne/user_portfolio_resposne.dart';
import 'package:vendor_app/features/profile/data/models/resposne/vendor_details_model.dart';

class AuthRepository {
  final AuthApi api;
  AuthRepository(this.api);

  Future<ApiResult<BaseResponse<SendOtpResponse>>> sendOtp(String phone) async {
    try {
      final res = await api.sendOtp(SendOtpRequest(phone: phone));
      return ApiSuccess(res);
    } catch (e) {
      if (e is ApiException) return ApiFailure(e.message, statusCode: e.statusCode);
      return ApiFailure(e.toString());
    }
  }
  Future<ApiResult<BaseResponse<VerifyOtpResponse>>> verifyOtp({
    required String phone,
    required String token,
    required String role,
  }) async {
    try {
      // API call to verify OTP
      final res = await api.verifyOtp(VerifyOtpRequest(phone: phone, token: token, role: role));

      // Extract token and check if it's not null or empty
      final tk = res.data?.token;

      if (tk != null && tk.isNotEmpty) {
        // Save token and user data to SharedPreferences
        final user = res.data?.user;
        if (user != null) {
          // Save token and user data in SharedPreferences
          await TokenStorage.saveTokenAndUserData(
            token: tk,  // Save the token
            user: user, // Save the user data (id, name, email, etc.)
          );
        }
      }

      return ApiSuccess(res);
    } catch (e) {
      // Handle API exception or other errors
      if (e is ApiException) {
        return ApiFailure(e.message, statusCode: e.statusCode);
      }
      return ApiFailure(e.toString());
    }
  }



  Future<ApiResult<BaseResponse<List<CategoryModelResponse>>>> getCategories() async {
    try {
      final res = await api.getCategories();
      return ApiSuccess(res);
    } on ApiException catch (e) {
      return ApiFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<BaseResponse<List<SubcategoryModelResponse>>>> getSubcategories(int categoryId) async {
    try {
      final res = await api.getSubcategories(categoryId);
      return ApiSuccess(res);
    } on ApiException catch (e) {
      return ApiFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
// lib/features/auth/data/auth_repository.dart
  Future<ApiResult<MasterImageUploadResponse>> upload({
    required String filePath,
    required String folder,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final resp = await api.masterImageUpload(
        filePath: filePath,
        folder: folder,
        onSendProgress: onProgress,
      );
      return ApiSuccess(resp); // resp = MasterImageUploadResponse
    } on ApiException catch (e) {
      return ApiFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }


  Future<ApiResult<BaseResponse<Object?>>> createVendor(VendorCreateRequest req) async {
    try {
      final res = await api.createVendor(req);
      return ApiSuccess(res);
    } on ApiException catch (e) {
      return ApiFailure(e.firstFieldErrorOrMessage(), statusCode: e.statusCode);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
  Future<ApiResult<BaseResponse<DashboardResponse>>> getVendorDashboard(int userId) async {
    try {
      final res = await api.getVendorDashboard(userId);  // API call for vendor dashboard
      return ApiSuccess(res);
    } catch (e) {
      if (e is ApiException) return ApiFailure(e.message, statusCode: e.statusCode);
      return ApiFailure(e.toString());
    }
  }


  // Fetch new leads from the API
  Future<ApiResult<BaseResponse<List<NewLead>>>> getBookingLeads(int userId) async {
    try {
      final res = await api.getBookingLeads(userId);  // API call to fetch booking leads
      return ApiSuccess(res);
    } catch (e) {
      if (e is ApiException) {
        return ApiFailure(e.message, statusCode: e.statusCode);
      }
      return ApiFailure(e.toString());
    }
  }
  // Fetch Active Bookings
  Future<ApiResult<BaseResponse<List<ActiveBookingModel>>>> getActiveBookings(int userId) async {
    try {
      final res = await api.getActiveBookings(userId);  // Call to the API to fetch active bookings
      return ApiSuccess(res);
    } catch (e) {
      if (e is ApiException) {
        return ApiFailure(e.message, statusCode: e.statusCode);
      }
      return ApiFailure(e.toString());
    }
  }
  Future<ApiResult<BaseResponse<UserPortfolioResposne>>> uploadUserPortfolio(UserPortfolioRequest request) async {
    try {
      final res = await api.uploadUserPortfolio(request);
      return ApiSuccess(res);
    } catch (e) {
      if (e is ApiException) {
        return ApiFailure(e.message, statusCode: e.statusCode);
      }
      return ApiFailure(e.toString());
    }
  }
  Future<ApiResult<BaseResponse<List<GetUserPortfolioResponse>>>> getUserPortfolio(int userId) async {
    try {
      final res = await api.getUserPortfolio(userId);
      return ApiSuccess(res);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<BaseResponse<NotificationSettingsResponse>>> updateNotificationSettings(NotificationSettingsRequest request) async {
    try {
      final res = await api.updateNotificationSettings(request);
      return ApiSuccess(res);
    } catch (e) {
      if (e is ApiException) {
        return ApiFailure(e.message, statusCode: e.statusCode);
      }
      return ApiFailure(e.toString());
    }
  }
  // Fetch Notification Settings
  Future<ApiResult<BaseResponse<NotificationSettingsResponse>>> getNotificationSettings(int userId) async {
    try {
      final res = await api.getNotificationSettings(userId);
      return ApiSuccess(res);
    } catch (e) {
      if (e is ApiException) {
        return ApiFailure(e.message, statusCode: e.statusCode);
      }
      return ApiFailure(e.toString());
    }
  }
  Future<ApiResult<BaseResponse<List<InboxResponse>>>> getInboxMessages(int userId) async {
    try {
      final res = await api.getInboxMessages(userId);
      return ApiSuccess(res);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
  Future<ApiResult<BaseResponse<List<ConversationItem>>>> getConversationMessages(
      int conversationId) async {
    try {
      final res = await api.getConversationMessages(conversationId);
      return ApiSuccess(res);
    } catch (e) {
      if (e is ApiException) {
        return ApiFailure(e.message, statusCode: e.statusCode);
      }
      return ApiFailure(e.toString());
    }
  }
  Future<ApiResult<BaseResponse<VendorDetails>>> getVendorDetails(int vendorId) async {
    try {
      final res = await api.getVendorDetails(vendorId);
      return ApiSuccess(res);
    } on ApiException catch (e) {
      return ApiFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<BaseResponse<ServiceAddResponse>>> addService(ServiceAddRequest req) async {
    try {
      final res = await api.addService(req);
      return ApiSuccess(res);
    } on ApiException catch (e) {
      return ApiFailure(e.firstFieldErrorOrMessage(), statusCode: e.statusCode);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<BaseResponse<VenueCreateResponse>>> addVenue(VenueCreateRequest req) async {
    try {
      final res = await api.addVenue(req);
      return ApiSuccess(res);
    } on ApiException catch (e) {
      return ApiFailure(e.firstFieldErrorOrMessage(), statusCode: e.statusCode);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
  Future<ApiResult<BaseResponse<List<AmenityModelResponse>>>> getAmenities() async {
    try {
      final res = await api.getAmenities();
      return ApiSuccess(res);
    } on ApiException catch (e) {
      return ApiFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
  //  States
  Future<ApiResult<BaseResponse<StatesData>>> fetchStates() async {
    try {
      final res = await api.fetchStates();
      return ApiSuccess(res);
    } catch (e) {
      if (e is ApiException) {
        return ApiFailure(e.message, statusCode: e.statusCode);
      }
      return ApiFailure(e.toString());
    }
  }

  //  Cities
  Future<ApiResult<BaseResponse<CitiesData>>> fetchCities(int stateId) async {
    try {
      final res = await api.fetchCities(stateId);
      return ApiSuccess(res);
    } catch (e) {
      if (e is ApiException) {
        return ApiFailure(e.message, statusCode: e.statusCode);
      }
      return ApiFailure(e.toString());
    }
  }
}
