class BookingInvoiceResponse {
  final int bookingId;
  final String invoiceFile;
  final String invoiceFullUrl;

  BookingInvoiceResponse({
    required this.bookingId,
    required this.invoiceFile,
    required this.invoiceFullUrl,
  });

  factory BookingInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return BookingInvoiceResponse(
      bookingId: json['booking_id'] ?? 0,
      invoiceFile: json['invoice_file'] ?? '',
      invoiceFullUrl: json['invoice_full_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'invoice_file': invoiceFile,
      'invoice_full_url': invoiceFullUrl,
    };
  }
}
