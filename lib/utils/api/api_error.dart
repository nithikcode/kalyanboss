class ApiError implements Exception {
  final int? statusCode;
  final String message;
  final List<dynamic> errors;
  final StackTrace? stackTrace;

  ApiError({
    this.statusCode,
    this.message = "Something went wrong",
    this.errors = const [],
    this.stackTrace,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String? ?? "Something went wrong",
      errors: json['errors'] as List<dynamic>? ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'statusCode': statusCode,
    'message': message,
    'errors': errors,
  };

  @override
  String toString() {
    return "ApiError: $message (Status Code: $statusCode)";
  }
}