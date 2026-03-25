import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/utils/helpers/customJsonParser.dart';

class MarketResponseModel {
  final String? status;
  final String? message;
  final int? total;
  final List<MarketModel>? data;

  MarketResponseModel({this.status, this.message, this.total, this.data});

  factory MarketResponseModel.fromJson(Map<String, dynamic> json) {
    return MarketResponseModel(
      status: json.parse<String>('status'),
      message: json.parse<String>('message'),
      total: json.parse<int>('total'),
      data: json.parseListOf<MarketModel>(
        'data',
            (e) => MarketModel.fromJson(e as Map<String, dynamic>),
      ),
    );
  }


}

class MarketModel {
  final String? id;
  final String? name;
  final String? nameHindi;
  final String? openTime;
  final String? closeTime;
  final bool? status;
  final String? openDigit;
  final String? closeDigit;
  final String? openPanna;
  final String? closePanna;
  final String? tag;
  final bool? marketStatus;
  final String? panelUrl;
  final String? jodiUrl;
  final MarketOffDayModel? marketOffDay;

  MarketModel({
    this.id,
    this.name,
    this.nameHindi,
    this.openTime,
    this.closeTime,
    this.status,
    this.openDigit,
    this.closeDigit,
    this.openPanna,
    this.closePanna,
    this.tag,
    this.marketStatus,
    this.marketOffDay,
    this.panelUrl,
    this.jodiUrl,
  });

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: json.parse<String>('_id'),
      name: json.parse<String>('name'),
      nameHindi: json.parse<String>('name_hindi'),
      openTime: json.parse<String>('open_time'),
      closeTime: json.parse<String>('close_time'),
      status: json.parse<bool>('status'),
      openDigit: json.parse<String>('open_digit'),
      closeDigit: json.parse<String>('close_digit'),
      openPanna: json.parse<String>('open_panna'),
      closePanna: json.parse<String>('close_panna'),
      tag: json.parse<String>('tag'),
      marketStatus: json.parse<bool>('market_status'),
      panelUrl: json.parse<String>('panelUrl'),
      jodiUrl: json.parse<String>('jodiUrl'),
      marketOffDay: json.parseNested<MarketOffDayModel>(
        'market_off_day',
            (m) => MarketOffDayModel.fromJson(m),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'name_hindi': nameHindi,
    'open_time': openTime,
    'close_time': closeTime,
    'status': status,
    'open_digit': openDigit,
    'close_digit': closeDigit,
    'open_panna': openPanna,
    'close_panna': closePanna,
    'tag': tag,
    'market_status': marketStatus,
    'panelUrl': panelUrl,
    'jodiUrl': jodiUrl,
    'market_off_day': marketOffDay?.toJson(),
  };
}

class MarketOffDayModel {
  final bool? monday, tuesday, wednesday, thursday, friday, saturday, sunday;

  MarketOffDayModel({
    this.monday, this.tuesday, this.wednesday,
    this.thursday, this.friday, this.saturday, this.sunday,
  });

  factory MarketOffDayModel.fromJson(Map<String, dynamic> json) {
    return MarketOffDayModel(
      monday: json.parse<bool>('monday'),
      tuesday: json.parse<bool>('tuesday'),
      wednesday: json.parse<bool>('wednesday'),
      thursday: json.parse<bool>('thursday'),
      friday: json.parse<bool>('friday'),
      saturday: json.parse<bool>('saturday'),
      sunday: json.parse<bool>('sunday'),
    );
  }

  Map<String, dynamic> toJson() => {
    'monday': monday,
    'tuesday': tuesday,
    'wednesday': wednesday,
    'thursday': thursday,
    'friday': friday,
    'saturday': saturday,
    'sunday': sunday,
  };
}
