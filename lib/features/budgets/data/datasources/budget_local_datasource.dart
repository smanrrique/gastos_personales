import 'package:hive_ce/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/error/exceptions.dart';
import '../models/budget_model.dart';

abstract class BudgetLocalDataSource {
  Future<List<BudgetModel>> getAll();
  Future<BudgetModel> upsert(BudgetModel budget);
  Future<void> delete(String id);
  Stream<List<BudgetModel>> watchAll();
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  BudgetLocalDataSourceImpl(this._box);
  final Box<BudgetModel> _box;

  @override
  Future<List<BudgetModel>> getAll() async {
    final values = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return values;
  }

  @override
  Future<BudgetModel> upsert(BudgetModel budget) async {
    await _box.put(budget.id, budget);
    return budget;
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const NotFoundException('Presupuesto no encontrado.');
    }
    await _box.delete(id);
  }

  @override
  Stream<List<BudgetModel>> watchAll() async* {
    yield await getAll();
    yield* _box.watch().asyncMap((_) => getAll());
  }
}

Future<Box<BudgetModel>> openBudgetsBox() async {
  if (Hive.isBoxOpen(HiveBoxes.budgets)) {
    return Hive.box<BudgetModel>(HiveBoxes.budgets);
  }
  return Hive.openBox<BudgetModel>(HiveBoxes.budgets);
}
