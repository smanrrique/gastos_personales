import 'package:hive_ce/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getAll();
  Future<TransactionModel?> getById(String id);
  Future<TransactionModel> upsert(TransactionModel transaction);
  Future<void> delete(String id);
  Stream<List<TransactionModel>> watchAll();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  TransactionLocalDataSourceImpl(this._box);

  final Box<TransactionModel> _box;

  @override
  Future<List<TransactionModel>> getAll() async {
    final values = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return values;
  }

  @override
  Future<TransactionModel?> getById(String id) async => _box.get(id);

  @override
  Future<TransactionModel> upsert(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
    return transaction;
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const NotFoundException('Transacción no encontrada.');
    }
    await _box.delete(id);
  }

  @override
  Stream<List<TransactionModel>> watchAll() async* {
    yield await getAll();
    yield* _box.watch().asyncMap((_) => getAll());
  }
}

Future<Box<TransactionModel>> openTransactionsBox() async {
  if (Hive.isBoxOpen(HiveBoxes.transactions)) {
    return Hive.box<TransactionModel>(HiveBoxes.transactions);
  }
  return Hive.openBox<TransactionModel>(HiveBoxes.transactions);
}
