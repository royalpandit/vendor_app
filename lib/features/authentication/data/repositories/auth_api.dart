// lib/features/auth/data/auth_api.dart
import 'package:dio/dio.dart';
import 'package:vendor_app/core/network/api_exceptions.dart';
import 'package:vendor_app/core/network/base_response.dart';
import 'package:vendor_app/core/network/endpoints.dart';
import 'package:vendor_app/core/session/session.dart';
import 'package:vendor_app/features/authentication/data/models/request/send_otp_request.dart';
import 'package:vendor_app/features/authentication/data/models/request/vendor_create_request.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/category_model_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/master_image_upload_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/send_otp_response.dart';
import 'package:vendor_app/features/authentication/data/models/request/verify_otp_request.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/subcategory_model_response.dart';
import 'package:vendor_app/features/authentication/data/models/resposne/verify_otp_response.dart';
import 'package:path/path.dart' as p;
import 'package:vendor_app/features/booking/data/models/resposne/active_booking_model.dart';
import 'package:vendor_app/features/chat/data/model/request/mark_messages_read_request.dart';
import 'package:vendor_app/features/chat/data/model/request/conversation_delete_request.dart';
import 'package:vendor_app/features/chat/data/model/request/message_delete_request.dart';
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
import 'package:vendor_app/features/profile/data/models/resposne/service_meta_field_response.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<BaseResponse<SendOtpResponse>> sendOtp(SendOtpRequest req) async {
    final res = await _dio.post(Endpoints.sendOtp, data: req.toJson());
    final decoded = res.data; // Map<String, dynamic>

    return BaseResponse.fromJson(decoded, (json) {
      // json यहाँ "data" (या root-submap) होगा
      return SendOtpResponse.fromJson(json as Map<String, dynamic>);
    });
  }

  Future<BaseResponse<VerifyOtpResponse>> verifyOtp(VerifyOtpRequest req) async {
    final res = await _dio.post(Endpoints.verifyOtp, data: req.toJson());
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      return VerifyOtpResponse.fromJson(json as Map<String, dynamic>);
    });
  }


  Future<BaseResponse<List<CategoryModelResponse>>> getCategories() async {
    final res = await _dio.get(Endpoints.categories);
    final decoded = res.data;

    // response.data shape: { categories: [...] }
    return BaseResponse.fromJson(decoded, (json) {
      final list = (json as Map)['categories'] as List;
      return list
          .map((e) => CategoryModelResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // GET /api/sub-categories?category_id=2
  Future<BaseResponse<List<SubcategoryModelResponse>>> getSubcategories(int categoryId) async {
    final res = await _dio.get(
      Endpoints.subCategories,
      queryParameters: {'category_id': categoryId},
    );
    final decoded = res.data;

    // response.data shape: { subcategories: [...] }
    return BaseResponse.fromJson(decoded, (json) {
      final list = (json as Map)['subcategories'] as List;
      return list
          .map((e) => SubcategoryModelResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
  // lib/features/auth/data/auth_api.dart
  Future<MasterImageUploadResponse> masterImageUpload({
    required String filePath,
    required String folder,
    ProgressCallback? onSendProgress,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: p.basename(filePath)),
      'folder': folder,
    });

    final res = await _dio.post(
      Endpoints.masterImageUpload,
      data: form,
      onSendProgress: onSendProgress,
      options: Options(contentType: 'multipart/form-data'),
    );

    // ← यह API 'success, message, path, url' top-level keys देती है
    final map = (res.data as Map).cast<String, dynamic>();
    return MasterImageUploadResponse.fromJson(map);
  }

  Future<BaseResponse<Object?>> createVendor(VendorCreateRequest req) async {
    final res = await _dio.post(Endpoints.createVendors, data: req.toJson());
    final decoded = res.data; // {status, code, message}
    // data key नहीं है → BaseResponse data = null
    return BaseResponse.fromJson(decoded, (json) => json);
  }


  ///Vendor Dashboard
  Future<BaseResponse<DashboardResponse>> getVendorDashboard(int userId) async {
    try {
      // Debug: Log the current token being used
      final currentToken = Session.token;
      if (currentToken == null || currentToken.isEmpty) {
        throw ApiException(
          'No authentication token found. Please login again.',
          statusCode: 401,
        );
      }

      final response = await _dio.get(
        Endpoints.vendorDashboard, // Using the endpoint from Endpoints class
        queryParameters: {'user_id': userId}, // Sending user_id as query parameter
      );

      final decoded = response.data; // The entire response
      return BaseResponse.fromJson(decoded, (json) {
        return DashboardResponse.fromJson(json as Map<String, dynamic>);
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw ApiException(
          'Access denied. Please ensure you are logged in as a vendor.',
          statusCode: 403,
        );
      } else if (e.response?.statusCode == 401) {
        // Don't clear Session.token — it may still be valid; let the
        // persistent storage keep the user logged in across restarts.
        throw ApiException(
          'Session expired. Please login again.',
          statusCode: 401,
        );
      }
      throw ApiException(
        'Failed to fetch vendor dashboard: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ApiException('Failed to fetch vendor dashboard: $e');
    }
  }

  // Get Booking Leads
  Future<BaseResponse<List<NewLead>>> getBookingLeads(int userId) async {
    try {
      final response = await _dio.get(
        Endpoints.bookingLeads, // Using the endpoint from Endpoints class
        queryParameters: {'user_id': userId}, // Sending user_id as query parameter
      );

      final decoded = response.data; // The entire response
      return BaseResponse.fromJson(decoded, (json) {
        var dataList = json as List;
        return dataList.map((e) => NewLead.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      throw ApiException('Failed to fetch booking leads: $e');
    }
  }

  // Fetch Active Bookings
  Future<BaseResponse<List<ActiveBookingModel>>> getActiveBookings(int userId) async {
    try {
      final response = await _dio.get(
        Endpoints.vendorBookings,  // Endpoint to fetch active bookings
        queryParameters: {'user_id': userId}, // Send user_id as query parameter
      );

      final decoded = response.data; // Decode response
      return BaseResponse.fromJson(decoded, (json) {
        // Ensure the response data is parsed as a list of ActiveBookingModel
        var bookings = json as List;
        return bookings.map((e) => ActiveBookingModel.fromJson(e as Map<String, dynamic>)).toList();

       });
    } on DioError catch (dioErr) {
      // treat 404 as empty list rather than error
      if (dioErr.response?.statusCode == 404) {
        return BaseResponse<List<ActiveBookingModel>>(
          status: 'success',
          code: 404,
          message: 'No bookings',
          data: [],
        );
      }
      throw ApiException('Failed to fetch active bookings: $dioErr');
    } catch (e) {
      throw ApiException('Failed to fetch active bookings: $e');
    }
  }
  Future<BaseResponse<UserPortfolioResposne>> uploadUserPortfolio(UserPortfolioRequest request) async {
    try {
      final response = await _dio.post(
        Endpoints.userPortfolio,
        data: request.toJson(),
      );

      final decoded = response.data; // Decode the response
      return BaseResponse.fromJson(decoded, (json) {
        return UserPortfolioResposne.fromJson(json as Map<String, dynamic>);
      });
    } catch (e) {
      throw ApiException('Failed to upload portfolio image: $e');
    }
  }

  Future<BaseResponse<List<GetUserPortfolioResponse>>> getUserPortfolio(int userId) async {
    try {
      final response = await _dio.get(
        '${Endpoints.userPortfolioGet}$userId',  // Updated to use the endpoint
      );
      final decoded = response.data;  // The entire response

      return BaseResponse.fromJson(decoded, (json) {
        // Parsing the data into the list of UserPortfolioResponse objects

        var list = json as List;
        return list.map((e) => GetUserPortfolioResponse.fromJson(e as Map<String, dynamic>)).toList();

      });
    } catch (e) {
      throw ApiException('Failed to fetch user portfolio: $e');
    }
  }
  Future<BaseResponse<NotificationSettingsResponse>> updateNotificationSettings(NotificationSettingsRequest request) async {
    try {
      final res = await _dio.post(
        Endpoints.notificationSettings,
        data: request.toJson(),
      );

      final decoded = res.data; // Map<String, dynamic>

      return BaseResponse.fromJson(decoded, (json) {
        return NotificationSettingsResponse.fromJson(json as Map<String, dynamic>);
      });
    } catch (e) {
      throw ApiException('Failed to update notification settings: $e');
    }
  }
  // GET Notification Settings
  Future<BaseResponse<NotificationSettingsResponse>> getNotificationSettings(int userId) async {
    try {
      final response = await _dio.get(
        '${Endpoints.notificationSettings}?user_id=$userId', // Assuming your endpoint is like this
      );

      final decoded = response.data; // The entire response
      return BaseResponse.fromJson(decoded, (json) {
        return NotificationSettingsResponse.fromJson(json as Map<String, dynamic>);
      });
    } catch (e) {
      throw ApiException('Failed to fetch notification settings: $e');
    }
  }


  // GET Inbox Messages
  Future<BaseResponse<List<InboxResponse>>> getInboxMessages(int userId) async {
    try {
      final response = await _dio.get(
        '${Endpoints.inboxMessages}?user_id=$userId',  // Endpoint for inbox messages
      );

      final decoded = response.data;  // The entire response
      return BaseResponse.fromJson(decoded, (json) {
        var inbox = json as List;
        return inbox.map((e) => InboxResponse.fromJson(e as Map<String, dynamic>)).toList();

       });
    } catch (e) {
      throw ApiException('Failed to fetch inbox messages: $e');
    }
  }
  Future<BaseResponse<List<ChatMessage>>> getConversationMessages(
      int conversationId) async {

    final res = await _dio.get(
      Endpoints.conversationMessages,
      queryParameters: {'conversation_id': conversationId},
    );

    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      final list = json as List;
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // Future<BaseResponse<List<ConversationItem>>> getConversationMessages(
  //     int conversationId) async {
  //   final res = await _dio.get(
  //     Endpoints.conversationMessages,
  //     queryParameters: {'conversation_id': conversationId},
  //   );
  //
  //   final decoded = res.data; // full map: {status, code, message, data: [...]}
  //   return BaseResponse.fromJson(decoded, (json) {
  //     final list = (json as List);
  //     return list.map((e) {
  //       final msg = e as Map<String, dynamic>;
  //       // Convert plain message object to ConversationItem structure
  //       return ConversationItem(
  //         id: conversationId,
  //         lastMessage: ChatMessage.fromJson(msg),
  //         sender: ChatUser.fromJson(msg['sender'] as Map<String, dynamic>),
  //         receiver: ChatUser.fromJson(msg['receiver'] as Map<String, dynamic>),
  //       );
  //     }).toList();
  //   });
  // }


  Future<BaseResponse<VendorDetails>> getVendorDetails(int vendorId) async {
    final res = await _dio.get('${Endpoints.vendorDetails}/$vendorId');
    final decoded = res.data; // {satus/status, code, data: {...}}
    return BaseResponse.fromJson(decoded, (json) {
      return VendorDetails.fromJson(json as Map<String, dynamic>);
    });
  }
  Future<BaseResponse<ServiceAddResponse>> addService(ServiceAddRequest req) async {
    final res = await _dio.post(Endpoints.serviceAdd, data: req.toJson());
    final decoded = res.data; // {status, code, message, data:{...}}
    return BaseResponse.fromJson(decoded, (json) {
      return ServiceAddResponse.fromJson(json as Map<String, dynamic>);
    });
  }

  // GET /api/service-meta-fields/{subcategory_id}
  Future<BaseResponse<List<ServiceMetaFieldResponse>>> getServiceMetaFields(int subcategoryId) async {
    final res = await _dio.get('${Endpoints.serviceMetaFields}/$subcategoryId');
    final decoded = res.data; // {status, code, data: [ ... ]}

    return BaseResponse.fromJson(decoded, (json) {
      final list = json as List? ?? [];
      return list
          .map((e) => ServiceMetaFieldResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // ✅ Venue Add
  Future<BaseResponse<VenueCreateResponse>> addVenue(VenueCreateRequest req) async {
    final res = await _dio.post(Endpoints.venueAdd, data: req.toJson());
    final decoded = res.data; // {status, code, message}
    return BaseResponse.fromJson(decoded, (json) {
      // server sample में data नहीं है — message top-level
      return VenueCreateResponse.fromJson(decoded as Map<String, dynamic>);
    });
  }

  /// GET /api/amenity
  Future<BaseResponse<List<AmenityModelResponse>>> getAmenities() async {
    final res = await _dio.get(Endpoints.amenities);
    final decoded = res.data; // {status, code, message, data: { amenities: [...] }}

    return BaseResponse.fromJson(decoded, (json) {
      // json yaha inner "data" hoga => { amenities: [...] }
      final list = (json as Map)['amenities'] as List? ?? const [];
      return list
          .map((e) => AmenityModelResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }



  //  GET /api/states
  Future<BaseResponse<StatesData>> fetchStates() async {
    final res = await _dio.get(Endpoints.states);
    final decoded = res.data;
    return BaseResponse<StatesData>.fromJson(decoded, (raw) {
      // raw == List
      return StatesData.fromJson(raw);
    });
  }

  //  GET /api/cities?state_id=XXXX
  Future<BaseResponse<CitiesData>> fetchCities(int stateId) async {
    final res = await _dio.get(
      Endpoints.cities,
      queryParameters: {'state_id': stateId},
    );
    final decoded = res.data;
    return BaseResponse<CitiesData>.fromJson(decoded, (raw) {
      // raw == List
      return CitiesData.fromJson(raw);
    });
  }

  Future<BaseResponse<UpdateBookingStatusResponse>>
  updateBookingStatus(UpdateBookingStatusRequest req) async {

    final res = await _dio.post(
      Endpoints.updateBookingStatus,
      data: req.toJson(),
    );

    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      return UpdateBookingStatusResponse.fromJson(
          json as Map<String, dynamic>);
    });
  }

  /// GET /api/help/contact-support
  Future<BaseResponse<List<ContactSupportResponse>>> getContactSupport() async {
    final res = await _dio.get(Endpoints.contactSupport);
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      final list = (json as List);
      return list
          .map((e) => ContactSupportResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// GET /api/help/faqs
  Future<BaseResponse<List<FaqResponse>>> getFaqs() async {
    final res = await _dio.get(Endpoints.faqs);
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      final list = (json as List);
      return list
          .map((e) => FaqResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// GET /api/service-details?id={service_id}
  Future<BaseResponse<ServiceDetailsResponse>> getServiceDetails(int serviceId) async {
    final res = await _dio.get(
      Endpoints.serviceDetails,
      queryParameters: {'id': serviceId},
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      // json contains 'service' key
      final serviceData = (json as Map)['service'] as Map<String, dynamic>;
      return ServiceDetailsResponse.fromJson(serviceData);
    });
  }

  /// GET /api/service-list
  Future<BaseResponse<Map<String, dynamic>>> getServiceList({
    String type = 'service',
    int? vendorId,
    int? subcategoryId,
    String? search,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'type': type,
      'per_page': perPage,
    };
    
    if (vendorId != null) queryParams['vendor_id'] = vendorId;
    if (subcategoryId != null) queryParams['subcategory_id'] = subcategoryId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final res = await _dio.get(
      Endpoints.serviceList,
      queryParameters: queryParams,
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      return json as Map<String, dynamic>;
    });
  }

  /// POST /api/service-update
  Future<BaseResponse<Map<String, dynamic>>> updateService(Map<String, dynamic> data) async {
    final res = await _dio.post(
      Endpoints.serviceUpdate,
      data: data,
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      return json as Map<String, dynamic>;
    });
  }

  /// GET /api/details/booking?booking_id={booking_id}
  Future<BaseResponse<Map<String, dynamic>>> getBookingDetails(int bookingId) async {
    final res = await _dio.get(
      Endpoints.bookingDetails,
      queryParameters: {'booking_id': bookingId},
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      return json as Map<String, dynamic>;
    });
  }

  /// GET /api/bookings/invoice?booking_id={booking_id}
  Future<BaseResponse<BookingInvoiceResponse>> getBookingInvoice(int bookingId) async {
    final res = await _dio.get(
      Endpoints.bookingInvoice,
      queryParameters: {'booking_id': bookingId},
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      return BookingInvoiceResponse.fromJson(json as Map<String, dynamic>);
    });
  }

  /// POST /api/messages/send
  Future<BaseResponse<Object?>> sendMessage(SendMessageRequest req) async {
    final res = await _dio.post(
      Endpoints.sendMessage,
      data: req.toJson(),
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) => json);
  }

  /// POST /api/messages/read
  Future<BaseResponse<Object?>> markMessagesRead(MarkMessagesReadRequest req) async {
    final res = await _dio.post(
      Endpoints.markMessagesRead,
      data: req.toJson(),
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) => json);
  }

  /// POST /api/conversation/delete
  Future<BaseResponse<Object?>> deleteConversation(ConversationDeleteRequest req) async {
    final res = await _dio.post(
      Endpoints.deleteConversation,
      data: req.toJson(),
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) => json);
  }

  /// POST /api/message/delete
  Future<BaseResponse<Object?>> deleteMessage(MessageDeleteRequest req) async {
    final res = await _dio.post(
      Endpoints.deleteMessage,
      data: req.toJson(),
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) => json);
  }

  /// GET /api/vendors (list all vendors)
  Future<BaseResponse<Map<String, dynamic>>> getVendors({int perPage = 10}) async {
    final res = await _dio.get(
      Endpoints.vendors,
      queryParameters: {'per_page': perPage},
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      return json as Map<String, dynamic>;
    });
  }

  /// PUT /api/vendors/{id}
  Future<BaseResponse<Map<String, dynamic>>> updateVendor(
    int vendorId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.put(
      '${Endpoints.vendors}/$vendorId',
      data: data,
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      return json as Map<String, dynamic>;
    });
  }

  /// DELETE /api/user/{id}
  Future<BaseResponse<Object?>> deleteUser(int userId) async {
    final res = await _dio.delete('${Endpoints.deleteUser}/$userId');
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) => json);
  }

  /// POST /api/bookings
  Future<BaseResponse<List<Map<String, dynamic>>>> createBookings(
    int userId,
    List<int> shortlistIds,
  ) async {
    final res = await _dio.post(
      Endpoints.bookings,
      data: {
        'user_id': userId,
        'shortlist_ids': shortlistIds,
      },
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      final list = (json as List);
      return list.map((e) => e as Map<String, dynamic>).toList();
    });
  }

  /// GET /api/bookings?user_id={user_id}
  Future<BaseResponse<List<Map<String, dynamic>>>> getBookings(int userId) async {
    final res = await _dio.get(
      Endpoints.bookings,
      queryParameters: {'user_id': userId},
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      final list = (json as List);
      return list.map((e) => e as Map<String, dynamic>).toList();
    });
  }

  /// DELETE /api/bookings
  Future<BaseResponse<Map<String, dynamic>>> deleteBooking(
    int userId,
    int bookingId,
  ) async {
    final res = await _dio.delete(
      Endpoints.bookings,
      data: {
        'user_id': userId,
        'booking_id': bookingId,
      },
    );
    final decoded = res.data;

    return BaseResponse.fromJson(decoded, (json) {
      return json as Map<String, dynamic>;
    });
  }

}
