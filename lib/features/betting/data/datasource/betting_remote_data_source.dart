import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/base/data/datasource/base_remote_data_source.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';
import 'package:kalyanboss/utils/network/network_api_service.dart';

class BettingRemoteDataSource extends BaseRemoteDataSource {
  final NetworkServicesApi _api;

  BettingRemoteDataSource({NetworkServicesApi? api})
      : _api = api ?? NetworkServicesApi();

  /// createBet -
  Future<Either<Result<String>, ApiError>> createBet(List<Map<String, dynamic>> data,) async {
    return execute<String>(
      apiCall: () => _api.postApi('/app/bet/create', data),
      onSuccess: (response) {
        // Parse user from response
        final data = response['message'];
        return data;
      },
      operationName: 'createBet',
    );
  }
}