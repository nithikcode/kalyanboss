import 'package:kalyanboss/features/game/domain/entity/transaction_entity.dart';
import 'package:kalyanboss/utils/helpers/customJsonParser.dart';


class TransactionModel {
  final String? status;
  final int? total;
  final List<TransactionItemModel>? data;

  TransactionModel({this.status, this.total, this.data});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      status: json.parse<String>('status'),
      total: json.parse<int>('total'),
      data: json.parseListOf<TransactionItemModel>(
        'data',
            (v) => TransactionItemModel.fromJson(v as Map<String, dynamic>),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'total': total,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}

class TransactionItemModel {
  final String? id;
  final num? amount;
  final String? type;
  final String? status;
  final num? prevBalance;
  final num? currentBalance;
  final String? note;
  final String? transferType;
  final String? createdAt;

  TransactionItemModel({
    this.id,
    this.amount,
    this.type,
    this.status,
    this.prevBalance,
    this.currentBalance,
    this.note,
    this.transferType,
    this.createdAt,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json.parse<String>('_id'),
      amount: json.parse<int>('amount') ,
      type: json.parse<String>('type'),
      status: json.parse<String>('status'),
      prevBalance: json.parse<int>('prev_balance'),
      currentBalance: json.parse<int>('current_balance'),
      note: json.parse<String>('note'),
      transferType: json.parse<String>('transfer_type'),
      createdAt: json.parse<String>('createdAt'),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'amount': amount,
    'type': type,
    'status': status,
    'prev_balance': prevBalance,
    'current_balance': currentBalance,
    'note': note,
    'transfer_type': transferType,
    'createdAt': createdAt,
  };
}

/// Extension to convert Model to Entity
extension TransactionMapping on TransactionModel {
  TransactionEntity toEntity() {
    return TransactionEntity(
      status: status ?? 'error',
      total: total ?? 0,
      data: data?.map((m) => m.toEntity()).toList() ?? [],
    );
  }
}

extension TransactionItemMapping on TransactionItemModel {
  TransactionItemEntity toEntity() {
    return TransactionItemEntity(
      id: id ?? '',
      amount: amount ?? 0,
      type: type ?? '',
      status: status ?? '',
      prevBalance: prevBalance ?? 0,
      currentBalance: currentBalance ?? 0,
      note: note ?? '',
      transferType: transferType ?? '',
      createdAt: createdAt ?? '',
    );
  }
}