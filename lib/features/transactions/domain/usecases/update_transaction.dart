import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction implements UseCase<Transaction, Transaction> {
  UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Transaction>> call(Transaction params) {
    if (params.amount <= 0) {
      return Future.value(const Left(
        ValidationFailure(message: 'El monto debe ser mayor a cero.'),
      ));
    }
    final updated = params.copyWith(updatedAt: DateTime.now());
    return _repository.update(updated);
  }
}
