import 'package:equatable/equatable.dart';
import 'package:kalyanboss/features/game/data/model/market_model.dart';

/// Matches MarketResponseModel
class MarketResponseEntity extends Equatable {
  final String status;
  final String message;
  final int total;
  final List<MarketEntity> data;

  const MarketResponseEntity({
    required this.status,
    required this.message,
    required this.total,
    required this.data,
  });

  @override
  List<Object?> get props => [status, message, total, data];
}

/// Matches MarketModel
class MarketEntity extends Equatable {
  final String id;
  final String name;
  final String nameHindi;
  final String openTime;
  final String closeTime;
  final bool status;
  final String openDigit;
  final String closeDigit;
  final String openPanna;
  final String closePanna;
  final String tag;
  final bool marketStatus;
  final String? panelUrl;
  final String? jodiUrl;
  final MarketOffDayEntity marketOffDay;

  const MarketEntity({
    required this.id,
    required this.name,
    required this.nameHindi,
    required this.openTime,
    required this.closeTime,
    required this.status,
    required this.openDigit,
    required this.closeDigit,
    required this.openPanna,
    required this.closePanna,
    required this.tag,
    required this.marketStatus,
    required this.marketOffDay,
    this.panelUrl,
    this.jodiUrl,
  });

  @override
  List<Object?> get props => [
    id, name, nameHindi, openTime, closeTime, status,
    openDigit, closeDigit, openPanna, closePanna, tag,
    marketStatus, marketOffDay, panelUrl, jodiUrl,
  ];
}

/// Matches MarketOffDayModel
class MarketOffDayEntity extends Equatable {
  final bool monday, tuesday, wednesday, thursday, friday, saturday, sunday;

  const MarketOffDayEntity({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  @override
  List<Object?> get props => [monday, tuesday, wednesday, thursday, friday, saturday, sunday];
}

extension MarketResponseMapping on MarketResponseModel {
  MarketResponseEntity toEntity() {
    return MarketResponseEntity(
      status: status ?? '',
      message: message ?? '',
      total: total ?? 0,
      data: data?.map((m) => m.toEntity()).toList() ?? [],
    );
  }
}

extension MarketMapping on MarketModel {
  MarketEntity toEntity() {
    return MarketEntity(
      id: id ?? '',
      name: name ?? '',
      nameHindi: nameHindi ?? '',
      openTime: openTime ?? '',
      closeTime: closeTime ?? '',
      status: status ?? false,
      openDigit: openDigit ?? '',
      closeDigit: closeDigit ?? '',
      openPanna: openPanna ?? '',
      closePanna: closePanna ?? '',
      tag: tag ?? '',
      marketStatus: marketStatus ?? false,
      panelUrl: panelUrl,
      jodiUrl: jodiUrl,
      marketOffDay: marketOffDay?.toEntity() ??
          const MarketOffDayEntity(
              monday: false, tuesday: false, wednesday: false,
              thursday: false, friday: false, saturday: false, sunday: false
          ),
    );
  }
}

extension MarketOffDayMapping on MarketOffDayModel {
  MarketOffDayEntity toEntity() {
    return MarketOffDayEntity(
      monday: monday ?? false,
      tuesday: tuesday ?? false,
      wednesday: wednesday ?? false,
      thursday: thursday ?? false,
      friday: friday ?? false,
      saturday: saturday ?? false,
      sunday: sunday ?? false,
    );
  }
}