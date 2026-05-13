import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class CreateBudget implements UseCase<Budget, CreateBudgetParams> {
  CreateBudget(this._repository);
  final BudgetRepository _repository;

  @override
  Future<Either<Failure, Budget>> call(CreateBudgetParams p) {
    if (p.amount <= 0) {
      return Future.value(const Left(
        ValidationFailure(message: 'El monto debe ser mayor a cero.'),
      ));
    }
    if (p.name.trim().isEmpty) {
      return Future.value(const Left(
        ValidationFailure(message: 'El nombre es obligatorio.'),
      ));
    }
    final threshold = p.alertThreshold.clamp(0.1, 1.0);
    return _repository.create(p.toBudget(threshold));
  }
}

class CreateBudgetParams extends Equatable {
  const CreateBudgetParams({
    required this.id,
    required this.name,
    required this.amount,
    required this.alertThreshold,
    this.categoryId,
  });

  final String id;
  final String name;
  final double amount;
  final double alertThreshold;
  final String? categoryId;

  Budget toBudget(double threshold) {
    final now = DateTime.now();
    return Budget(
      id: id,
      name: name.trim(),
      amount: amount,
      alertThreshold: threshold,
      categoryId: categoryId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [id, name, amount, alertThreshold, categoryId];
}
