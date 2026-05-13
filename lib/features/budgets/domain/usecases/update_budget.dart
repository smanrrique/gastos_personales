import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class UpdateBudget implements UseCase<Budget, Budget> {
  UpdateBudget(this._repository);
  final BudgetRepository _repository;

  @override
  Future<Either<Failure, Budget>> call(Budget params) {
    if (params.amount <= 0) {
      return Future.value(const Left(
        ValidationFailure(message: 'El monto debe ser mayor a cero.'),
      ));
    }
    return _repository.update(params.copyWith(updatedAt: DateTime.now()));
  }
}
