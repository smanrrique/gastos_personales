import 'package:equatable/equatable.dart';

/// Presupuesto mensual. Si [categoryId] es null, aplica al gasto total del mes.
class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.alertThreshold,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.isActive = true,
  });

  final String id;
  final String name;
  final double amount;
  final double alertThreshold; // 0.0 — 1.0
  final String? categoryId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    double? alertThreshold,
    String? categoryId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        alertThreshold,
        categoryId,
        isActive,
        createdAt,
        updatedAt,
      ];
}

class BudgetProgress extends Equatable {
  const BudgetProgress({
    required this.budget,
    required this.spent,
  });

  final Budget budget;
  final double spent;

  double get limit => budget.amount;
  double get remaining => (limit - spent).clamp(double.negativeInfinity, limit);
  double get percentUsed => limit <= 0 ? 0 : (spent / limit).clamp(0, double.infinity);
  bool get isOverThreshold => percentUsed >= budget.alertThreshold;
  bool get isOverBudget => spent > limit;

  @override
  List<Object?> get props => [budget, spent];
}
