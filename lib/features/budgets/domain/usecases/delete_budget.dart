import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/budget_repository.dart';

class DeleteBudget implements UseCase<Unit, String> {
  DeleteBudget(this._repository);
  final BudgetRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repository.delete(id);
}
