import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories implements UseCase<List<Category>, NoParams> {
  GetCategories(this._repository);
  final CategoryRepository _repository;

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) =>
      _repository.getAll();
}
