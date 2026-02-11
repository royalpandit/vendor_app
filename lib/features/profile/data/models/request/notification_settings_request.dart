class NotificationSettingsRequest {
  final int userId;
  final int? pushNotification;
  final int? newLeadsRequest;
  final int? bookingStatusUpdate;
  final int? message;
  final int? paymentUpdates;

  NotificationSettingsRequest({
    required this.userId,
    this.pushNotification,
    this.newLeadsRequest,
    this.bookingStatusUpdate,
    this.message,
    this.paymentUpdates,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'push_notification': pushNotification,
      'new_leads_request': newLeadsRequest,
      'booking_status_update': bookingStatusUpdate,
      'message': message,
      'payment_updates': paymentUpdates,
    };
  }
}
