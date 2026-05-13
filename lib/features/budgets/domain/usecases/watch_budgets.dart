import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class WatchBudgets {
  WatchBudgets(this._repository);
  final BudgetRepository _repository;

  Stream<List<Budget>> call() => _repository.watchAll();
}
