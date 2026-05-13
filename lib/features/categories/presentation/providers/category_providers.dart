import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/domain/entities/transaction_type.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/watch_categories.dart';

// ── Datasource ──────────────────────────────────────────────
final categoriesBoxProvider = FutureProvider((ref) => openCategoriesBox());

final categoryLocalDataSourceProvider =
    Provider<CategoryLocalDataSource>((ref) {
  final box = ref.watch(categoriesBoxProvider).requireValue;
  return CategoryLocalDataSourceImpl(box);
});

// ── Repository ──────────────────────────────────────────────
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryLocalDataSourceProvider));
});

// ── Use cases ───────────────────────────────────────────────
final createCategoryProvider = Provider(
  (ref) => CreateCategory(ref.watch(categoryRepositoryProvider)),
);

final updateCategoryProvider = Provider(
  (ref) => UpdateCategory(ref.watch(categoryRepositoryProvider)),
);

final deleteCategoryProvider = Provider(
  (ref) => DeleteCategory(ref.watch(categoryRepositoryProvider)),
);

final watchCategoriesProvider = Provider(
  (ref) => WatchCategories(ref.watch(categoryRepositoryProvider)),
);

// ── Seed (idempotente) ──────────────────────────────────────
final seedDefaultCategoriesProvider = FutureProvider<void>((ref) async {
  await ref.watch(categoriesBoxProvider.future);
  await ref.watch(categoryRepositoryProvider).seedDefaultsIfEmpty();
});

// ── State streams ───────────────────────────────────────────
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  ref.watch(categoriesBoxProvider);
  ref.watch(seedDefaultCategoriesProvider);
  return ref.watch(watchCategoriesProvider).call();
});

final categoriesByTypeProvider =
    Provider.family<List<Category>, TransactionType>((ref, type) {
  final categories = ref.watch(categoriesStreamProvider).maybeWhen(
        data: (d) => d,
        orElse: () => const <Category>[],
      );
  return categories.where((c) => c.type == type).toList();
});

final categoryByIdProvider = Provider.family<Category?, String?>((ref, id) {
  if (id == null) return null;
  final categories = ref.watch(categoriesStreamProvider).maybeWhen(
        data: (d) => d,
        orElse: () => const <Category>[],
      );
  for (final c in categories) {
    if (c.id == id) return c;
  }
  return null;
});
