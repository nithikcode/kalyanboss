import 'package:equatable/equatable.dart';
import 'package:kalyanboss/features/game/data/model/result_model.dart';

class MarketResponse {
  final String status;
  final int total;
  final List<MarketResultItem> data;

  const MarketResponse({required this.status, required this.total, required this.data});
}

class MarketResultItem extends Equatable {
  final String id;
  final String marketName;
  final String tag;
  final String from;
  final String to;
  final String openDigit;
  final String openPanna;
  final String closeDigit;
  final String closePanna;
  final String createdAt;
  final String updatedAt;
  final MarketDetails marketId;

  const MarketResultItem({
    required this.id, required this.marketName, required this.tag,
    required this.from, required this.to, required this.openDigit,
    required this.openPanna, required this.closeDigit, required this.closePanna,
    required this.createdAt, required this.updatedAt, required this.marketId,
  });

  @override
  List<Object?> get props => [id, marketName, tag, openDigit, closeDigit, marketId];
}

class MarketDetails extends Equatable {
  final String marketId;
  final String name;
  final String openTime;
  final String closeTime;
  final bool status;
  final bool marketStatus;

  const MarketDetails({
    required this.marketId, required this.name, required this.openTime,
    required this.closeTime, required this.status, required this.marketStatus,
  });

  @override
  List<Object?> get props => [marketId, name, status, marketStatus];
}

extension MarketMappingX on MarketItemModel {
  MarketResultItem toEntity() {
    return MarketResultItem(
      id: id ?? '',
      marketName: marketName ?? '',
      tag: tag ?? '',
      from: from ?? '',
      to: to ?? '',
      openDigit: openDigit ?? '',
      openPanna: openPanna ?? '',
      closeDigit: closeDigit ?? '',
      closePanna: closePanna ?? '',
      createdAt: createdAt ?? '',
      updatedAt: '',
      marketId: marketId?.toEntity() ?? const MarketDetails(
          marketId: '', name: '', openTime: '', closeTime: '', status: false, marketStatus: false
      ),
    );
  }
}
extension MarketResponseModelX on MarketResponseResultModel {
  /// Converts the full API response model to a clean Entity
  MarketResponse toEntity() {
    return MarketResponse(
      status: status ?? 'error',
      total: total ?? 0,
      data: data?.map((model) => model.toEntity()).toList() ?? [],
    );
  }
}
extension MarketDetailMappingX on MarketIdDetailModel {
  MarketDetails toEntity() {
    return MarketDetails(
      marketId: marketId ?? '',
      name: name ?? '',
      openTime: openTime ?? '',
      closeTime: closeTime ?? '',
      status: status ?? false,
      marketStatus: false,
    );
  }
}