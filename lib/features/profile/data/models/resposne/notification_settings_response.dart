

class NotificationSettingsResponse {
  final int id;
  final int userId;
  final int pushNotification;
  final int newLeadsRequest;
  final int bookingStatusUpdate;
  final int message;
  final int paymentUpdates;

  NotificationSettingsResponse({
    required this.id,
    required this.userId,
    required this.pushNotification,
    required this.newLeadsRequest,
    required this.bookingStatusUpdate,
    required this.message,
    required this.paymentUpdates,
  });

  factory NotificationSettingsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsResponse(
      id: json['id'],
      userId: json['user_id'],
      pushNotification: json['push_notification'],
      newLeadsRequest: json['new_leads_request'],
      bookingStatusUpdate: json['booking_status_update'],
      message: json['message'],
      paymentUpdates: json['payment_updates'],
    );
  }
}
