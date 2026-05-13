import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._local);

  final BudgetLocalDataSource _local;

  @override
  Future<Either<Failure, List<Budget>>> getAll() async {
    try {
      final models = await _local.getAll();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> create(Budget budget) => _write(budget);

  @override
  Future<Either<Failure, Budget>> update(Budget budget) => _write(budget);

  Future<Either<Failure, Budget>> _write(Budget budget) async {
    try {
      final saved = await _local.upsert(BudgetModel.fromEntity(budget));
      return Right(saved.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _local.delete(id);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Budget>> watchAll() =>
      _local.watchAll().map((list) => list.map((m) => m.toEntity()).toList());
}
