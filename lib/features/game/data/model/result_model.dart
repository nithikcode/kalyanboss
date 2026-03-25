import 'package:kalyanboss/utils/helpers/customJsonParser.dart';

class MarketResponseResultModel {
  final String? status;
  final int? total;
  final List<MarketItemModel>? data;

  MarketResponseResultModel({this.status, this.total, this.data});

  factory MarketResponseResultModel.fromJson(Map<String, dynamic> json) {
    return MarketResponseResultModel(
      status: json.parse<String>('status'),
      total: json.parse<int>('total'),
      data: json.parseListOf<MarketItemModel>(
          'data', (element) => MarketItemModel.fromJson(element as Map<String, dynamic>)
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "total": total,
    "data": data?.map((x) => x.toJson()).toList(),
  };
}

class MarketItemModel {
  final String? id;
  final String? marketName;
  final String? tag;
  final String? from;
  final String? to;
  final String? openDigit;
  final String? openPanna;
  final String? closeDigit;
  final String? closePanna;
  final String? createdAt;
  final MarketIdDetailModel? marketId;

  MarketItemModel({
    this.id, this.marketName, this.tag, this.from, this.to,
    this.openDigit, this.openPanna, this.closeDigit, this.closePanna,
    this.createdAt, this.marketId,
  });

  factory MarketItemModel.fromJson(Map<String, dynamic> json) {
    return MarketItemModel(
      id: json.parse<String>('_id'),
      marketName: json.parse<String>('market_name'),
      tag: json.parse<String>('tag'),
      from: json.parse<String>('from'),
      to: json.parse<String>('to'),
      openDigit: json.parse<String>('open_digit'),
      openPanna: json.parse<String>('open_panna'),
      closeDigit: json.parse<String>('close_digit'),
      closePanna: json.parse<String>('close_panna'),
      createdAt: json.parse<String>('createdAt'),
      marketId: json.parseNested<MarketIdDetailModel>(
          'market_id', (data) => MarketIdDetailModel.fromJson(data)
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id, "market_name": marketName, "tag": tag, "from": from, "to": to,
    "open_digit": openDigit, "open_panna": openPanna, "close_digit": closeDigit,
    "close_panna": closePanna, "market_id": marketId?.toJson(),
  };

  MarketItemModel copyWith({String? marketName, String? openDigit}) {
    return MarketItemModel(
      id: id,
      marketName: marketName ?? this.marketName,
      openDigit: openDigit ?? this.openDigit,
      // ... add other fields as needed
    );
  }
}

class MarketIdDetailModel {
  final String? marketId;
  final String? name;
  final String? openTime;
  final String? closeTime;
  final bool? status;

  MarketIdDetailModel({this.marketId, this.name, this.openTime, this.closeTime, this.status});

  factory MarketIdDetailModel.fromJson(Map<String, dynamic> json) {
    return MarketIdDetailModel(
      marketId: json.parse<String>('market_id'),
      name: json.parse<String>('name'),
      openTime: json.parse<String>('open_time'),
      closeTime: json.parse<String>('close_time'),
      status: json.parse<bool>('status'),
    );
  }

  Map<String, dynamic> toJson() => {
    "market_id": marketId, "name": name, "open_time": openTime, "status": status,
  };
}