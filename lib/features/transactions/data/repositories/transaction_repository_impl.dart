import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._local);

  final TransactionLocalDataSource _local;

  @override
  Future<Either<Failure, List<Transaction>>> getAll() async {
    try {
      final models = await _local.getAll();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getById(String id) async {
    try {
      final model = await _local.getById(id);
      if (model == null) {
        return const Left(NotFoundFailure(message: 'Transacción no existe.'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> create(Transaction transaction) =>
      _write(transaction);

  @override
  Future<Either<Failure, Transaction>> update(Transaction transaction) =>
      _write(transaction);

  Future<Either<Failure, Transaction>> _write(Transaction transaction) async {
    try {
      final saved =
          await _local.upsert(TransactionModel.fromEntity(transaction));
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
  Stream<List<Transaction>> watchAll() =>
      _local.watchAll().map((list) => list.map((m) => m.toEntity()).toList());
}
