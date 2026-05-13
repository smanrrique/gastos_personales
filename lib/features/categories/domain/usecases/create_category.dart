import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory implements UseCase<Category, CreateCategoryParams> {
  CreateCategory(this._repository);
  final CategoryRepository _repository;

  @override
  Future<Either<Failure, Category>> call(CreateCategoryParams params) {
    if (params.name.trim().isEmpty) {
      return Future.value(const Left(
        ValidationFailure(message: 'El nombre es obligatorio.'),
      ));
    }
    return _repository.create(params.toCategory());
  }
}

class CreateCategoryParams extends Equatable {
  const CreateCategoryParams({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorKey,
    required this.type,
  });

  final String id;
  final String name;
  final String iconKey;
  final String colorKey;
  final TransactionType type;

  Category toCategory() {
    final now = DateTime.now();
    return Category(
      id: id,
      name: name.trim(),
      iconKey: iconKey,
      colorKey: colorKey,
      type: type,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [id, name, iconKey, colorKey, type];
}
