import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction implements UseCase<Unit, String> {
  DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repository.delete(id);
}
