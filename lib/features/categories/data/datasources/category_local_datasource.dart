import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/error/exceptions.dart';
import '../../../transactions/domain/entities/transaction_type.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAll();
  Future<CategoryModel?> getById(String id);
  Future<CategoryModel> upsert(CategoryModel category);
  Future<void> delete(String id);
  Stream<List<CategoryModel>> watchAll();
  Future<bool> seedDefaultsIfEmpty();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  CategoryLocalDataSourceImpl(this._box);

  final Box<CategoryModel> _box;

  @override
  Future<List<CategoryModel>> getAll() async {
    final values = _box.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return values;
  }

  @override
  Future<CategoryModel?> getById(String id) async => _box.get(id);

  @override
  Future<CategoryModel> upsert(CategoryModel category) async {
    await _box.put(category.id, category);
    return category;
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const NotFoundException('Categoría no encontrada.');
    }
    await _box.delete(id);
  }

  @override
  Stream<List<CategoryModel>> watchAll() async* {
    yield await getAll();
    yield* _box.watch().asyncMap((_) => getAll());
  }

  @override
  Future<bool> seedDefaultsIfEmpty() async {
    if (_box.isNotEmpty) return false;
    final now = DateTime.now();
    const uuid = Uuid();
    final defaults = <CategoryModel>[
      // Gastos
      _seed(uuid, 'Comida', 'food', 'orange', TransactionType.expense, now),
      _seed(uuid, 'Transporte', 'transport', 'blue', TransactionType.expense, now),
      _seed(uuid, 'Casa', 'home', 'teal', TransactionType.expense, now),
      _seed(uuid, 'Salud', 'health', 'red', TransactionType.expense, now),
      _seed(uuid, 'Entretenimiento', 'entertainment', 'purple',
          TransactionType.expense, now),
      _seed(uuid, 'Compras', 'shopping', 'pink', TransactionType.expense, now),
      _seed(uuid, 'Educación', 'education', 'indigo', TransactionType.expense, now),
      _seed(uuid, 'Otros gastos', 'other', 'grey', TransactionType.expense, now),
      // Ingresos
      _seed(uuid, 'Salario', 'salary', 'green', TransactionType.income, now),
      _seed(uuid, 'Freelance', 'freelance', 'cyan', TransactionType.income, now),
      _seed(uuid, 'Inversiones', 'investment', 'emerald',
          TransactionType.income, now),
      _seed(uuid, 'Otros ingresos', 'gift', 'amber', TransactionType.income, now),
    ];
    final map = {for (final c in defaults) c.id: c};
    await _box.putAll(map);
    return true;
  }
}

CategoryModel _seed(Uuid uuid, String name, String iconKey, String colorKey,
    TransactionType type, DateTime at) {
  return CategoryModel(
    id: uuid.v4(),
    name: name,
    iconKey: iconKey,
    colorKey: colorKey,
    typeIndex: type.index,
    createdAt: at,
    updatedAt: at,
    isDefault: true,
  );
}


Future<Box<CategoryModel>> openCategoriesBox() async {
  if (Hive.isBoxOpen(HiveBoxes.categories)) {
    return Hive.box<CategoryModel>(HiveBoxes.categories);
  }
  return Hive.openBox<CategoryModel>(HiveBoxes.categories);
}
