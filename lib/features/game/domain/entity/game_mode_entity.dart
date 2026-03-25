import 'package:equatable/equatable.dart';
import 'package:kalyanboss/features/game/data/model/game_mode_model.dart';

// Top-Level Response Entity
class GameModeResponseEntity extends Equatable {
  final String status;
  final String message;
  final List<GameModeEntity> data;

  const GameModeResponseEntity({
    required this.status,
    required this.message,
    required this.data,
  });

  @override
  List<Object?> get props => [status, message, data];
}

// Individual Game Mode Entity
class GameModeEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String image;
  final int index;
  final bool status;

  const GameModeEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.index,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, category, image, index, status];
}

extension GameModeResponseMapper on GameModeResponseModel {
  GameModeResponseEntity toEntity() {
    return GameModeResponseEntity(
      status: status ?? 'error',
      message: message ?? '',
      // Recursively converts the internal list of Models to Entities
      data: data?.map((model) => model.toEntity()).toList() ?? [],
    );
  }
}

extension GameModeMapper on GameModeModel {
  GameModeEntity toEntity() {
    return GameModeEntity(
      id: id ?? '',
      name: name ?? 'N/A',
      category: category ?? 'General',
      image: image ?? '',
      index: index ?? 0,
      status: status ?? false,
    );
  }
}