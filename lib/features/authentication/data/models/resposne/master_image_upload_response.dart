 class MasterImageUploadResponse {
  final bool success;
  final String message;
  final String path;
  final String url;

  MasterImageUploadResponse({
    required this.success,
    required this.message,
    required this.path,
    required this.url,
  });

  /// backend sometimes returns duplicated host in `url`
   String get safeUrl {
    final dup = RegExp(r'^(https?://[^/]+)\1');
    if (dup.hasMatch(url)) {
      // remove the duplicated host
      final m = dup.firstMatch(url)!;
      final host = m.group(1)!;
      return url.replaceFirst('$host$host', host);
    }
    // another safer fallback:
    final doublePrefix = 'https://sevenoath.shofus.comhttps://';
    if (url.startsWith(doublePrefix)) {
      return url.replaceFirst('https://sevenoath.shofus.comhttps://', 'https://');
    }
    return url;
  }

  factory MasterImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return MasterImageUploadResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'path': path,
    'url': url,
  };
}
