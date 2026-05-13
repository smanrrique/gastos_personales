import 'package:hive_ce/hive.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  TransactionModel({
    required this.id,
    required this.amount,
    required this.typeIndex,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  int typeIndex;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  String? categoryId;

  TransactionType get type => TransactionType.values[typeIndex];

  Transaction toEntity() => Transaction(
        id: id,
        amount: amount,
        type: type,
        description: description,
        date: date,
        createdAt: createdAt,
        updatedAt: updatedAt,
        categoryId: categoryId,
      );

  factory TransactionModel.fromEntity(Transaction t) => TransactionModel(
        id: t.id,
        amount: t.amount,
        typeIndex: t.type.index,
        description: t.description,
        date: t.date,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
        categoryId: t.categoryId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'typeIndex': typeIndex,
        'description': description,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'categoryId': categoryId,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        typeIndex: json['typeIndex'] as int,
        description: json['description'] as String,
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        categoryId: json['categoryId'] as String?,
      );
}
