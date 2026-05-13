import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getAll();
  Future<Either<Failure, Budget>> create(Budget budget);
  Future<Either<Failure, Budget>> update(Budget budget);
  Future<Either<Failure, Unit>> delete(String id);
  Stream<List<Budget>> watchAll();
}
