import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._local);

  final CategoryLocalDataSource _local;

  @override
  Future<Either<Failure, List<Category>>> getAll() async {
    try {
      final models = await _local.getAll();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> getById(String id) async {
    try {
      final model = await _local.getById(id);
      if (model == null) {
        return const Left(NotFoundFailure(message: 'Categoría no existe.'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> create(Category category) =>
      _write(category);

  @override
  Future<Either<Failure, Category>> update(Category category) =>
      _write(category);

  Future<Either<Failure, Category>> _write(Category category) async {
    try {
      final saved = await _local.upsert(CategoryModel.fromEntity(category));
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
  Stream<List<Category>> watchAll() =>
      _local.watchAll().map((list) => list.map((m) => m.toEntity()).toList());

  @override
  Future<Either<Failure, Unit>> seedDefaultsIfEmpty() async {
    try {
      await _local.seedDefaultsIfEmpty();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
