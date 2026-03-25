import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/betting/data/datasource/betting_remote_data_source.dart';
import 'package:kalyanboss/features/betting/domain/repository/betting_repository.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class BettingRepositoryImpl extends BettingRepository {
  final BettingRemoteDataSource bettingRemoteDataSource;

  BettingRepositoryImpl({required this.bettingRemoteDataSource});

  Future<Either<Result<String>, ApiError>> createBet(List<Map<String, dynamic>>data,) async {
    return await bettingRemoteDataSource.createBet(data); 
  }
}