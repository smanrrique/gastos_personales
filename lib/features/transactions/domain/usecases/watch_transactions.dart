import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class WatchTransactions {
  WatchTransactions(this._repository);

  final TransactionRepository _repository;

  Stream<List<Transaction>> call() => _repository.watchAll();
}
