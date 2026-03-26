import 'package:equatable/equatable.dart';
import 'package:kalyanboss/features/game/data/model/bet_history_model.dart';

class BetResponseEntity extends Equatable {
  final String status;
  final BetDataEntity? data;

  const BetResponseEntity({
    required this.status,
    this.data,
  });

  BetResponseEntity copyWith({
    String? status,
    BetDataEntity? data,
  }) {
    return BetResponseEntity(
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [status, data];
}

class BetDataEntity extends Equatable {
  final int total;
  final List<BetItemEntity> betList;

  const BetDataEntity({
    required this.total,
    required this.betList,
  });

  BetDataEntity copyWith({
    int? total,
    List<BetItemEntity>? betList,
  }) {
    return BetDataEntity(
      total: total ?? this.total,
      betList: betList ?? this.betList,
    );
  }

  @override
  List<Object?> get props => [total, betList];
}

class BetItemEntity extends Equatable {
  final String id;
  final UserEntity? user;
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

  const BetItemEntity({
    required this.id,
    this.user,
    required this.gameMode,
    required this.marketId,
    required this.marketName,
    required this.commission,
    required this.session,
    required this.openDigit,
    required this.closeDigit,
    required this.openPanna,
    required this.closePanna,
    required this.win,
    required this.points,
    required this.result,
    required this.tag,
    required this.status,
    required this.v,
    required this.createdAt,
    required this.updatedAt,
  });

  BetItemEntity copyWith({
    String? id,
    UserEntity? user,
    String? gameMode,
    String? marketId,
    String? marketName,
    num? commission,
    String? session,
    String? openDigit,
    String? closeDigit,
    String? openPanna,
    String? closePanna,
    String? win,
    num? points,
    List<dynamic>? result,
    String? tag,
    String? status,
    int? v,
    String? createdAt,
    String? updatedAt,
  }) {
    return BetItemEntity(
      id: id ?? this.id,
      user: user ?? this.user,
      gameMode: gameMode ?? this.gameMode,
      marketId: marketId ?? this.marketId,
      marketName: marketName ?? this.marketName,
      commission: commission ?? this.commission,
      session: session ?? this.session,
      openDigit: openDigit ?? this.openDigit,
      closeDigit: closeDigit ?? this.closeDigit,
      openPanna: openPanna ?? this.openPanna,
      closePanna: closePanna ?? this.closePanna,
      win: win ?? this.win,
      points: points ?? this.points,
      result: result ?? this.result,
      tag: tag ?? this.tag,
      status: status ?? this.status,
      v: v ?? this.v,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, user, gameMode, marketId, marketName, commission, session,
    openDigit, closeDigit, openPanna, closePanna, win, points,
    result, tag, status, v, createdAt, updatedAt,
  ];
}

class UserEntity extends Equatable {
  final String id;
  final String userName;
  final String mobile;

  const UserEntity({
    required this.id,
    required this.userName,
    required this.mobile,
  });

  UserEntity copyWith({
    String? id,
    String? userName,
    String? mobile,
  }) {
    return UserEntity(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      mobile: mobile ?? this.mobile,
    );
  }

  @override
  List<Object?> get props => [id, userName, mobile];
}

// Import your models and entities here

extension BetResponseModelX on BetResponseModel {
  BetResponseEntity toEntity() {
    return BetResponseEntity(
      status: status,
      data: data?.toEntity(),
    );
  }
}

extension BetDataModelX on BetDataModel {
  BetDataEntity toEntity() {
    return BetDataEntity(
      total: total,
      betList: betList.map((e) => e.toEntity()).toList(),
    );
  }
}

extension BetItemModelX on BetItemModel {
  BetItemEntity toEntity() {
    return BetItemEntity(
      id: id,
      user: user?.toEntity(),
      gameMode: gameMode,
      marketId: marketId,
      marketName: marketName,
      commission: commission,
      session: session,
      openDigit: openDigit,
      closeDigit: closeDigit,
      openPanna: openPanna,
      closePanna: closePanna,
      win: win,
      points: points,
      result: result,
      tag: tag,
      status: status,
      v: v,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension UserModelX on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      userName: userName,
      mobile: mobile,
    );
  }
}