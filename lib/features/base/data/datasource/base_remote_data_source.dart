// lib/core/data/base_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';
import 'package:kalyanboss/utils/helpers/helpers.dart';
import 'package:kalyanboss/utils/network/network_api_service.dart';

/// Base class for all remote data sources
/// Handles all common error handling and response parsing
abstract class BaseRemoteDataSource {
  Future<Either<Result<T>, ApiError>> execute<T>({
    required Future<dynamic> Function() apiCall,
    required T Function(dynamic response) onSuccess,
    String? operationName,
  }) async {
    try {
      final response = await apiCall();

      if (operationName != null) {
        createLog('$operationName Success: $response');
      }

      final result = onSuccess(response);
      return Left(Result.success(result));

    } on AppException catch (e) {
      // Catch our custom exceptions (Conflict, Unauthorized, etc.)
      if (operationName != null) {
        createLog('$operationName Failed: ${e.message}');
      }
      return Right(ApiError(
        message: e.message,
        statusCode: e.statusCode,
      ));

    } on DioException catch (e) {
      // Fallback for DioErrors not caught by the API Service
      final errorMessage = _extractErrorMessage(e);
      if (operationName != null) {
        createLog('$operationName Failed: $errorMessage');
      }
      return Right(ApiError(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      ));

    } catch (e, stackTrace) {
      // Truly unexpected errors (Null pointers, etc.)
      createLog('Unexpected Error: $e');
      createLog('Stack: $stackTrace');

      return Right(ApiError(
        message: operationName != null
            ? 'Failed to $operationName'
            : 'Something went wrong',
      ));
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('message')) return data['message'].toString();
    }
    return 'An unexpected network error occurred';
  }
}