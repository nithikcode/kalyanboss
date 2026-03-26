import 'package:kalyanboss/utils/helpers/customJsonParser.dart';

class BetResponseModel {
  final String status;
  final BetDataModel? data;

  BetResponseModel({required this.status, this.data});

  factory BetResponseModel.fromJson(Map<String, dynamic> json) {
    return BetResponseModel(
      // Using generic parse<T> with fallback
      status: json.parse<String>('status') ?? '',
      // Using parseNested for the internal object
      data: json.parseNested<BetDataModel>('data', (v) => BetDataModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data?.toJson(),
  };
}

class BetDataModel {
  final int total;
  final List<BetItemModel> betList;

  BetDataModel({required this.total, required this.betList});

  factory BetDataModel.fromJson(Map<String, dynamic> json) {
    return BetDataModel(
      total: json.parse<int>('total') ?? 0,
      // Using parseListOf for clean list mapping
      betList: json.parseListOf<BetItemModel>(
          'bet_list',
              (v) => BetItemModel.fromJson(v as Map<String, dynamic>)
      ) ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'bet_list': betList.map((e) => e.toJson()).toList(),
  };
}

class BetItemModel {
  final String id;
  final UserModel? user;
  final String gameMode;
  final String marketId;
  final String marketName;
  final num commission;
  final String session;
  final String openDigit;
  final String closeDigit;
  final String openPanna;
  final String closePanna;
  final String win;
  final num points;
  final List<dynamic> result;
  final String tag;
  final String status;
  final int v;
  final String createdAt;
  final String updatedAt;

  BetItemModel({
    required this.id, this.user, required this.gameMode, required this.marketId,
    required this.marketName, required this.commission, required this.session,
    required this.openDigit, required this.closeDigit, required this.openPanna,
    required this.closePanna, required this.win, required this.points,
    required this.result, required this.tag, required this.status,
    required this.v, required this.createdAt, required this.updatedAt,
  });

  factory BetItemModel.fromJson(Map<String, dynamic> json) {
    return BetItemModel(
      id: json.parse<String>('_id') ?? '',
      user: json.parseNested<UserModel>('user_id', (v) => UserModel.fromJson(v)),
      gameMode: json.parse<String>('game_mode') ?? '',
      marketId: json.parse<String>('market_id') ?? '',
      marketName: json.parse<String>('market_name') ?? '',
      // Note: 'num' is a base class, parse<double> or parse<int> is safer
      commission: json.parse<double>('commission') ?? 0.0,
      session: json.parse<String>('session') ?? '',
      openDigit: json.parse<String>('open_digit') ?? '',
      closeDigit: json.parse<String>('close_digit') ?? '',
      openPanna: json.parse<String>('open_panna') ?? '',
      closePanna: json.parse<String>('close_panna') ?? '',
      win: json.parse<String>('win') ?? '',
      points: json.parse<double>('points') ?? 0.0,
      result: json.parseListOf<dynamic>('result', (v) => v) ?? [],
      tag: json.parse<String>('tag') ?? '',
      status: json.parse<String>('status') ?? '',
      v: json.parse<int>('__v') ?? 0,
      createdAt: json.parse<String>('createdAt') ?? '',
      updatedAt: json.parse<String>('updatedAt') ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id, 'user_id': user?.toJson(), 'game_mode': gameMode,
    'market_id': marketId, 'market_name': marketName, 'commission': commission,
    'session': session, 'open_digit': openDigit, 'close_digit': closeDigit,
    'open_panna': openPanna, 'close_panna': closePanna, 'win': win,
    'points': points, 'result': result, 'tag': tag, 'status': status,
    '__v': v, 'createdAt': createdAt, 'updatedAt': updatedAt,
  };
}

class UserModel {
  final String id;
  final String userName;
  final String mobile;

  UserModel({required this.id, required this.userName, required this.mobile});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json.parse<String>('_id') ?? '',
      userName: json.parse<String>('user_name') ?? '',
      mobile: json.parse<String>('mobile') ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id, 'user_name': userName, 'mobile': mobile,
  };
}