class AiApiException implements Exception {
  const AiApiException(this.message, {this.statusCode, this.responseBody});

  final String message;
  final int? statusCode;
  final String? responseBody;

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }
    return '[$statusCode] $message';
  }
}
