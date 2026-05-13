import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../entities/transaction_type.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction implements UseCase<Transaction, CreateTransactionParams> {
  CreateTransaction(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Transaction>> call(
      CreateTransactionParams params) async {
    if (params.amount <= 0) {
      return const Left(ValidationFailure(
          message: 'El monto debe ser mayor a cero.'));
    }
    if (params.description.trim().isEmpty) {
      return const Left(ValidationFailure(
          message: 'La descripción es obligatoria.'));
    }
    return _repository.create(params.toTransaction());
  }
}

class CreateTransactionParams extends Equatable {
  const CreateTransactionParams({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.categoryId,
  });

  final String id;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime date;
  final String? categoryId;

  Transaction toTransaction() {
    final now = DateTime.now();
    return Transaction(
      id: id,
      amount: amount,
      type: type,
      description: description.trim(),
      date: date,
      categoryId: categoryId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props =>
      [id, amount, type, description, date, categoryId];
}
