class UpdateBookingStatusResponse {
  final int bookingId;
  final String status;

  UpdateBookingStatusResponse({
    required this.bookingId,
    required this.status,
  });

  factory UpdateBookingStatusResponse.fromJson(
      Map<String, dynamic> json) {
    return UpdateBookingStatusResponse(
      bookingId: json['booking_id'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}
