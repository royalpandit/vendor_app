// lib/core/network/api_exceptions.dart
// lib/core/network/api_exceptions.dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors; // ← new

  ApiException(this.message, {this.statusCode, this.fieldErrors});

  /// पहला साफ़ human message निकालने में काम आता है
  String firstFieldErrorOrMessage() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final firstList = fieldErrors!.values.first;
      if (firstList.isNotEmpty) return firstList.first;
    }
    return message;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
