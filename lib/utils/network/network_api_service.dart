import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../services/session_manager.dart';
import '../helpers/helpers.dart';
import 'base_api_service.dart';

class NetworkServicesApi implements BaseApiServices {
  late final Dio _dio;

  NetworkServicesApi({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? 'https://your-api-url.com/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Automatically follow redirects
        followRedirects: true,
        maxRedirects: 5,
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _HeadersInterceptor(),
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  // Expose dio instance for direct access if needed
  Dio get dio => _dio;

  // ---------------------------------------------------------------------------
  // BASIC REQUESTS
  // ---------------------------------------------------------------------------

  @override
  Future<dynamic> getApi(
      String url, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }


  @override
  Future<dynamic> postApi(String url, dynamic data) async {
    try {
      final response = await _dio.post(url, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<dynamic> putApi(String url, dynamic data) async {
    try {
      final response = await _dio.put(url, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<dynamic> patchApi(String url, dynamic data) async {
    try {
      final response = await _dio.patch(url, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<dynamic> deleteApi(String url, dynamic data) async {
    try {
      final response = await _dio.delete(url, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // FORM DATA (URL ENCODED)
  // ---------------------------------------------------------------------------

  @override
  Future<dynamic> postFormData(String url, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        url,
        data: FormData.fromMap(data),
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // MULTIPART (FILE UPLOAD)
  // ---------------------------------------------------------------------------

  @override
  Future<dynamic> postMultipart(
      String url,
      Map<String, String> fields,
      List<Uint8List> files,
      List<String> fileNames,
      ) async {
    try {
      final formData = FormData();

      // Add text fields
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value));
      });

      // Add files
      for (int i = 0; i < files.length; i++) {
        final mime = lookupMimeType(fileNames[i]) ?? "application/octet-stream";
        final mimeType = mime.split('/');

        formData.files.add(
          MapEntry(
            'attachments',
            MultipartFile.fromBytes(
              files[i],
              filename: fileNames[i],
              contentType: DioMediaType(mimeType[0], mimeType[1]),
            ),
          ),
        );
      }

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // S3 UPLOAD (DIRECT PUT)
  // ---------------------------------------------------------------------------

  Future<Response> uploadToS3({
    required String uploadUrl,
    required Uint8List bytes,
    String? contentType,
  }) async {
    try {
      // Create a separate Dio instance for S3 uploads (no interceptors)
      final s3Dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ));

      // Different approach for web vs mobile
      final response = await s3Dio.put(
        uploadUrl,
        data: kIsWeb
            ? bytes  // Web: Direct bytes
            : Stream.fromIterable(bytes.map((e) => [e])), // Mobile: Stream
        options: Options(
          headers: {
            'Content-Type': contentType ?? 'application/octet-stream',
            if (!kIsWeb) 'Content-Length': bytes.length.toString(),
          },
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      createLog("[S3] Upload Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('S3 upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      createLog("[S3] Upload Error: ${e.type} - ${e.message}");
      throw _handleDioError(e);
    } catch (e) {
      createLog("[S3] Unexpected Error: $e");
      throw FetchDataException('Failed to upload to S3: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // RESPONSE & ERROR HANDLING
  // ---------------------------------------------------------------------------

  dynamic _handleResponse(Response response) {
    createLog("[API] Response Status: ${response.statusCode}");
    createLog("[API] Response Data: ${response.data}");

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      // CHANGE THIS: Use your status code handler for consistency
      throw _handleStatusCode(response);
    }
  }

  Exception _handleDioError(DioException error) {
    createLog("[API] DioError Type: ${error.type}");
    createLog("[API] DioError Message: ${error.message}");
    createLog("[API] DioError Response: ${error.response?.data}");

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return RequestTimeoutException(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response!);

      case DioExceptionType.cancel:
        return FetchDataException('Request cancelled');

      case DioExceptionType.connectionError:
        if (kIsWeb) {
          return NoInternetException(
            "Network error on web. Check:\n"
                "1. Your internet connection\n"
                "2. CORS configuration on your backend\n"
                "3. Backend URL is correct and accessible",
          );
        }
        return NoInternetException('No internet connection');

      default:
        return FetchDataException(
          error.message ?? 'Unexpected error occurred',
        );
    }
  }

  Exception _handleStatusCode(Response response) {
    final statusCode = response.statusCode;
    final message = response.data?['message'] ?? response.statusMessage;

    switch (statusCode) {
      case 400:
        return BadRequestException(message ?? 'Bad request');
      case 401:
        return UnauthorizedException(message ?? 'Unauthorized access');
      case 403:
        return ForbiddenException(message ?? 'Forbidden');
      case 404:
        return NotFoundException(message ?? 'Resource not found');
      case 409: // <--- ADD THIS CASE
        return ConflictException(message);
      case 500:
      case 502:
      case 503:
        return ServerException(message ?? 'Server error');
      default:
        return FetchDataException(
          message ?? 'Error with status code: $statusCode',
        );
    }
  }
}

// =============================================================================
// INTERCEPTORS
// =============================================================================

/// 1. Headers Interceptor - Adds platform and version info
class _HeadersInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // skips interceptor [for s3 uploads]
    if (options.extra['skipAuthInterceptor'] == true) {
      createLog("[API] Request: ${options.method} ${options.uri}");
      return super.onRequest(options, handler);
    }
    final version = await _getAppVersion();
    final platform = _getPlatformHeader();

    options.headers.addAll({
      'app': 'true',
      'platform': platform,
      'version': version,
    });

    createLog("[API] Request: ${options.method} ${options.uri}");
    createLog("[API] Headers: ${options.headers}");

    super.onRequest(options, handler);
  }

  Future<String> _getAppVersion() async {
    if (kIsWeb) return "web";
    try {
      final info = await PackageInfo.fromPlatform();
      return "${info.version}+${info.buildNumber}";
    } catch (_) {
      return "unknown";
    }
  }

  String _getPlatformHeader() {
    if (kIsWeb) return "Web App";
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return "Android App";
      case TargetPlatform.iOS:
        return "iOS App";
      case TargetPlatform.macOS:
        return "macOS App";
      case TargetPlatform.windows:
        return "Windows App";
      case TargetPlatform.linux:
        return "Linux App";
      default:
        return "Unknown";
    }
  }
}

/// 2. Auth Interceptor - Adds Bearer token and handles token refresh
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // Skip auth for certain requests (like S3 uploads)
    if (options.extra['skipAuthInterceptor'] == true) {
      return super.onRequest(options, handler);
    }

    // Add access token to headers
    final accessToken = SessionManager.instance.getAccessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      createLog("[API] Added Bearer token to request");
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    // Handle 401 - Token expired or invalid
    if (err.response?.statusCode == 401) {
      createLog("[API] 401 Error - Attempting token refresh");

      final refreshToken = SessionManager.instance.getRefreshToken;

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Create new Dio instance for refresh (to avoid interceptor loop)
          final dio = Dio();
          final response = await dio.post(
            '${err.requestOptions.baseUrl}/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'] as String?;
            final newRefreshToken = response.data['refreshToken'] as String?;

            // Update tokens in SessionManager
            await SessionManager.instance.setSession(
              jwtAccessToken: newAccessToken,
              jwtRefreshToken: newRefreshToken ?? refreshToken,
              userId: SessionManager.instance.getUserId,
            );

            createLog("[API] Token refreshed successfully");

            // Retry the original request with new token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await Dio().fetch(opts);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          createLog("[API] Token refresh failed: $e");
          // Clear session and let error propagate
          await SessionManager.instance.clearSession();
        }
      } else {
        createLog("[API] No refresh token available");
        // Clear session if no refresh token
        await SessionManager.instance.clearSession();
      }
    }

    super.onError(err, handler);
  }
}

/// 3. Logging Interceptor - Logs all requests and responses
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {

    createLog('│ REQUEST: ${options.method} ${options.uri}');
    createLog('│ Headers: ${options.headers}');
    if (options.data != null) {
      createLog('│ Body: ${options.data}');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {

    createLog('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    createLog('│ Data: ${response.data}');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {

    createLog('│ ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}');
    createLog('│ Type: ${err.type}');
    createLog('│ Message: ${err.message}');
    if (err.response != null) {
      createLog('│ Status: ${err.response?.statusCode}');
      createLog('│ Data: ${err.response?.data}');
    }

    super.onError(err, handler);
  }
}

/// 4. Error Interceptor - Global error handling
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // You can add global error handling here
    // For example, show a toast for certain errors

    super.onError(err, handler);
  }
}



/// Base exception class for all app exceptions
class AppException implements Exception {
  final String message;
  final String? prefix;
  final int? statusCode;

  AppException({
    required this.message,
    this.prefix,
    this.statusCode,
  });

  @override
  String toString() {
    return '${prefix ?? "Error"}: $message';
  }
}

/// Exception for network connectivity issues
class NoInternetException extends AppException {
  NoInternetException([String? message])
      : super(
    message: message ?? 'No internet connection',
    prefix: 'No Internet',
  );
}

/// Exception for request timeout
class RequestTimeoutException extends AppException {
  RequestTimeoutException([String? message])
      : super(
    message: message ?? 'Request timeout',
    prefix: 'Timeout',
  );
}

/// Exception for bad requests (400)
class BadRequestException extends AppException {
  BadRequestException([String? message])
      : super(
    message: message ?? 'Bad request',
    prefix: 'Bad Request',
    statusCode: 400,
  );
}

/// Exception for unauthorized access (401)
class UnauthorizedException extends AppException {
  UnauthorizedException([String? message])
      : super(
    message: message ?? 'Unauthorized access',
    prefix: 'Unauthorized',
    statusCode: 401,
  );
}
/// Exception for conflict errors (409) - e.g., User already exists
class ConflictException extends AppException {
  ConflictException([String? message])
      : super(
    message: message ?? 'Conflict occurred',
    prefix: 'Conflict',
    statusCode: 409,
  );
}
/// Exception for forbidden access (403)
class ForbiddenException extends AppException {
  ForbiddenException([String? message])
      : super(
    message: message ?? 'Access forbidden',
    prefix: 'Forbidden',
    statusCode: 403,
  );
}

/// Exception for not found (404)
class NotFoundException extends AppException {
  NotFoundException([String? message])
      : super(
    message: message ?? 'Resource not found',
    prefix: 'Not Found',
    statusCode: 404,
  );
}

/// Exception for server errors (500+)
class ServerException extends AppException {
  ServerException([String? message])
      : super(
    message: message ?? 'Internal server error',
    prefix: 'Server Error',
    statusCode: 500,
  );
}

/// Exception for data fetching errors
class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(
    message: message ?? 'Error fetching data',
    prefix: 'Fetch Error',
  );
}

/// Exception for data parsing errors
class InvalidInputException extends AppException {
  InvalidInputException([String? message])
      : super(
    message: message ?? 'Invalid input',
    prefix: 'Invalid Input',
  );
}