import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategory implements UseCase<Category, Category> {
  UpdateCategory(this._repository);
  final CategoryRepository _repository;

  @override
  Future<Either<Failure, Category>> call(Category params) {
    if (params.name.trim().isEmpty) {
      return Future.value(const Left(
        ValidationFailure(message: 'El nombre es obligatorio.'),
      ));
    }
    return _repository.update(params.copyWith(updatedAt: DateTime.now()));
  }
}
