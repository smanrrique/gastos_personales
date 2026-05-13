import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getAll();
  Future<Either<Failure, Transaction>> getById(String id);
  Future<Either<Failure, Transaction>> create(Transaction transaction);
  Future<Either<Failure, Transaction>> update(Transaction transaction);
  Future<Either<Failure, Unit>> delete(String id);
  Stream<List<Transaction>> watchAll();
}
