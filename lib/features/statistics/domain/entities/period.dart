import 'package:equatable/equatable.dart';

class StatsPeriod extends Equatable {
  const StatsPeriod({required this.start, required this.end, required this.label});

  final DateTime start;
  final DateTime end;
  final String label;

  factory StatsPeriod.thisMonth() {
    final now = DateTime.now();
    return StatsPeriod(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1).subtract(const Duration(milliseconds: 1)),
      label: 'Este mes',
    );
  }

  factory StatsPeriod.lastMonth() {
    final now = DateTime.now();
    return StatsPeriod(
      start: DateTime(now.year, now.month - 1),
      end: DateTime(now.year, now.month).subtract(const Duration(milliseconds: 1)),
      label: 'Mes pasado',
    );
  }

  factory StatsPeriod.thisYear() {
    final now = DateTime.now();
    return StatsPeriod(
      start: DateTime(now.year),
      end: DateTime(now.year + 1).subtract(const Duration(milliseconds: 1)),
      label: 'Este año',
    );
  }

  @override
  List<Object?> get props => [start, end, label];
}

class CategoryBreakdownItem extends Equatable {
  const CategoryBreakdownItem({
    required this.categoryId,
    required this.categoryName,
    required this.iconKey,
    required this.colorKey,
    required this.amount,
    required this.percent,
  });

  final String? categoryId;
  final String categoryName;
  final String iconKey;
  final String colorKey;
  final double amount;
  final double percent;

  @override
  List<Object?> get props =>
      [categoryId, categoryName, iconKey, colorKey, amount, percent];
}

class MonthlyPoint extends Equatable {
  const MonthlyPoint({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final double income;
  final double expense;

  double get balance => income - expense;

  @override
  List<Object?> get props => [month, income, expense];
}
