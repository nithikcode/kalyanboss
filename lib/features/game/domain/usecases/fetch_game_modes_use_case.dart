import 'package:dartz/dartz.dart';
import 'package:kalyanboss/features/game/data/repository/game_screen_repository_impl.dart';
import 'package:kalyanboss/features/game/domain/entity/game_mode_entity.dart';
import 'package:kalyanboss/utils/api/api_error.dart';
import 'package:kalyanboss/utils/api/api_result.dart';

class FetchGameModesUseCase {
  final GameScreenRepositoryImpl gameScreenRepository;

  FetchGameModesUseCase({required this.gameScreenRepository});

  Future<Either<Result<GameModeResponseEntity>,ApiError>>call(Map<String,dynamic> data)async {
    return await gameScreenRepository.fetchGameModes(data);
  }
}