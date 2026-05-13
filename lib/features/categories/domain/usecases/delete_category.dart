import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/category_repository.dart';

class DeleteCategory implements UseCase<Unit, String> {
  DeleteCategory(this._repository);
  final CategoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repository.delete(id);
}
