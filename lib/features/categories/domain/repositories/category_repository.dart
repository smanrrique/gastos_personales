import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getAll();
  Future<Either<Failure, Category>> getById(String id);
  Future<Either<Failure, Category>> create(Category category);
  Future<Either<Failure, Category>> update(Category category);
  Future<Either<Failure, Unit>> delete(String id);
  Stream<List<Category>> watchAll();
  Future<Either<Failure, Unit>> seedDefaultsIfEmpty();
}
