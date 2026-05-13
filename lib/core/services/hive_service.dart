import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../features/budgets/data/models/budget_model.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/notifications/data/models/notification_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../constants/hive_boxes.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(NotificationModelAdapter());

    await Future.wait<void>([
      Hive.openBox<TransactionModel>(HiveBoxes.transactions),
      Hive.openBox<CategoryModel>(HiveBoxes.categories),
      Hive.openBox<BudgetModel>(HiveBoxes.budgets),
      Hive.openBox<NotificationModel>(HiveBoxes.notifications),
      Hive.openBox(HiveBoxes.settings),
    ]);
  }

  static Future<void> close() => Hive.close();
}
