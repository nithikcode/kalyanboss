// lib/core/data/base_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';
import 'package:kalyanboss/utils/helpers/helpers.dart';

/// Base class for all remote data sources
/// Handles all common error handling and response parsing
abstract class BaseRemoteDataSource {

  /// Execute API call with automatic error handling
  /// Returns Either<Result<T>, ApiError>
  Future<Either<Result<T>, ApiError>> execute<T>({
    required Future<dynamic> Function() apiCall,
    required T Function(dynamic response) onSuccess,
    String? operationName,
  }) async {
    try {
      // Execute the API call
      final response = await apiCall();

      // Log response
      if (operationName != null) {
        createLog('$operationName Success: $response');
      }

      // Parse and return success
      final result = onSuccess(response);
      return Left(Result.success(result));

    } on DioException catch (e) {
      // Handle Dio errors
      final errorMessage = _extractErrorMessage(e);

      if (operationName != null) {
        createLog('$operationName Failed: $errorMessage');
      }

      return Right(ApiError(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      ));

    } catch (e, stackTrace) {
      // Handle unknown errors
      createLog('Unknown Error: $e');
      createLog('Stack: $stackTrace');

      return Right(ApiError(
        message: operationName != null
            ? 'Failed to $operationName'
            : 'Something went wrong',
      ));
    }
  }

  /// Extract error message from DioException
  String _extractErrorMessage(DioException e) {
    // Try to get message from response
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
    }

    // Return default based on error type
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) return 'Authentication failed';
        if (status == 403) return 'Access denied';
        if (status == 404) return 'Resource not found';
        if (status != null && status >= 500) return 'Server error';
        return 'Request failed';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      default:
        return e.message ?? 'An error occurred';
    }
  }
}