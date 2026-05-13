import 'package:hive_ce/hive.dart';

import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  BudgetModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.alertThreshold,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.isActive = true,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double amount;

  @HiveField(3)
  double alertThreshold;

  @HiveField(4)
  String? categoryId;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  Budget toEntity() => Budget(
        id: id,
        name: name,
        amount: amount,
        alertThreshold: alertThreshold,
        categoryId: categoryId,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory BudgetModel.fromEntity(Budget b) => BudgetModel(
        id: b.id,
        name: b.name,
        amount: b.amount,
        alertThreshold: b.alertThreshold,
        categoryId: b.categoryId,
        isActive: b.isActive,
        createdAt: b.createdAt,
        updatedAt: b.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'alertThreshold': alertThreshold,
        'categoryId': categoryId,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        alertThreshold: (json['alertThreshold'] as num).toDouble(),
        categoryId: json['categoryId'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
