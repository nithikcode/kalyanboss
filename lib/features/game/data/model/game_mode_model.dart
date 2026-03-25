import 'package:kalyanboss/utils/helpers/customJsonParser.dart';

class GameModeResponseModel {
  final String? status;
  final String? message;
  final List<GameModeModel>? data;

  GameModeResponseModel({this.status, this.message, this.data});

  factory GameModeResponseModel.fromJson(Map<String, dynamic> json) {
    return GameModeResponseModel(
      status: json.parse<String>('status'),
      message: json.parse<String>('message'),
      data: json.parseListOf<GameModeModel>(
        'data',
            (e) => GameModeModel.fromJson(e as Map<String, dynamic>),
      ),
    );
  }
}

class GameModeModel {
  final String? id;
  final String? name;
  final String? category;
  final String? image;
  final int? index;
  final bool? status;

  GameModeModel({
    this.id,
    this.name,
    this.category,
    this.image,
    this.index,
    this.status,
  });

  factory GameModeModel.fromJson(Map<String, dynamic> json) {
    return GameModeModel(
      id: json.parse<String>('_id'), // Maps API _id to id
      name: json.parse<String>('name'),
      category: json.parse<String>('category'),
      image: json.parse<String>('image'),
      index: json.parse<int>('index'),
      status: json.parse<bool>('status'),
    );
  }
}