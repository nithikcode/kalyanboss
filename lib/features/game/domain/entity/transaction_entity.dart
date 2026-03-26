import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String status;
  final int total;
  final List<TransactionItemEntity> data;

  const TransactionEntity({
    required this.status,
    required this.total,
    required this.data,
  });

  @override
  List<Object?> get props => [status, total, data];
}

class TransactionItemEntity extends Equatable {
  final String id;
  final num amount;
  final String type;
  final String status;
  final num prevBalance;
  final num currentBalance;
  final String note;
  final String transferType;
  final String createdAt;

  const TransactionItemEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.prevBalance,
    required this.currentBalance,
    required this.note,
    required this.transferType,
    required this.createdAt,
  });

  TransactionItemEntity copyWith({String? status, String? note}) {
    return TransactionItemEntity(
      id: id,
      amount: amount,
      type: type,
      status: status ?? this.status,
      prevBalance: prevBalance,
      currentBalance: currentBalance,
      note: note ?? this.note,
      transferType: transferType,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, amount, status, currentBalance, createdAt];
}