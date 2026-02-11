class UpdateBookingStatusRequest {
  final int bookingId;
  final String action; // approve | reject

  UpdateBookingStatusRequest({
    required this.bookingId,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      "booking_id": bookingId,
      "action": action,
    };
  }
}
