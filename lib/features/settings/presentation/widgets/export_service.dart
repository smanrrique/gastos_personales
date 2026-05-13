import 'dart:convert';
import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../budgets/data/models/budget_model.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../transactions/data/models/transaction_model.dart';

class ExportService {
  ExportService._();

  static Future<File> exportAllToJson() async {
    final txBox = Hive.box<TransactionModel>(HiveBoxes.transactions);
    final catBox = Hive.box<CategoryModel>(HiveBoxes.categories);
    final budBox = Hive.box<BudgetModel>(HiveBoxes.budgets);

    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': 1,
      'transactions': txBox.values.map((t) => t.toJson()).toList(),
      'categories': catBox.values.map((c) => c.toJson()).toList(),
      'budgets': budBox.values.map((b) => b.toJson()).toList(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/gastos_backup_$stamp.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  static Future<({int txs, int cats, int budgets})> importFromJson(
      String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final txBox = Hive.box<TransactionModel>(HiveBoxes.transactions);
    final catBox = Hive.box<CategoryModel>(HiveBoxes.categories);
    final budBox = Hive.box<BudgetModel>(HiveBoxes.budgets);

    final txs = (data['transactions'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .toList();
    final cats = (data['categories'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
    final budgets = (data['budgets'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(BudgetModel.fromJson)
        .toList();

    await txBox.putAll({for (final t in txs) t.id: t});
    await catBox.putAll({for (final c in cats) c.id: c});
    await budBox.putAll({for (final b in budgets) b.id: b});

    return (txs: txs.length, cats: cats.length, budgets: budgets.length);
  }

  static Future<void> clearAll() async {
    await Hive.box<TransactionModel>(HiveBoxes.transactions).clear();
    await Hive.box<BudgetModel>(HiveBoxes.budgets).clear();
    // Las categorías por defecto se re-siembran al reabrir la app.
    await Hive.box<CategoryModel>(HiveBoxes.categories).clear();
  }
}
