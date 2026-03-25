import 'package:dartz/dartz.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

abstract class BettingRepository {
  Future<Either<Result<String>, ApiError>> createBet(List<Map<String, dynamic>> data,);
}