import 'package:equatable/equatable.dart';

import 'transaction_type.dart';

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
  });

  final String id;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? categoryId;

  double get signedAmount => type.isExpense ? -amount : amount;

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryId,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        description,
        date,
        createdAt,
        updatedAt,
        categoryId,
      ];
}
