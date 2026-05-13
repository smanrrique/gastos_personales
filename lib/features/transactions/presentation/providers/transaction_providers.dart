import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/watch_transactions.dart';

// ── Datasource ──────────────────────────────────────────────
final transactionsBoxProvider = FutureProvider((ref) => openTransactionsBox());

final transactionLocalDataSourceProvider =
    Provider<TransactionLocalDataSource>((ref) {
  final box = ref.watch(transactionsBoxProvider).requireValue;
  return TransactionLocalDataSourceImpl(box);
});

// ── Repository ──────────────────────────────────────────────
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
      ref.watch(transactionLocalDataSourceProvider));
});

// ── Use cases ───────────────────────────────────────────────
final createTransactionProvider = Provider(
  (ref) => CreateTransaction(ref.watch(transactionRepositoryProvider)),
);

final updateTransactionProvider = Provider(
  (ref) => UpdateTransaction(ref.watch(transactionRepositoryProvider)),
);

final deleteTransactionProvider = Provider(
  (ref) => DeleteTransaction(ref.watch(transactionRepositoryProvider)),
);

final watchTransactionsProvider = Provider(
  (ref) => WatchTransactions(ref.watch(transactionRepositoryProvider)),
);

// ── State streams ───────────────────────────────────────────
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  ref.watch(transactionsBoxProvider);
  return ref.watch(watchTransactionsProvider).call();
});

final transactionTotalsProvider = Provider<TransactionTotals>((ref) {
  final txs =
      ref.watch(transactionsStreamProvider).maybeWhen(
            data: (d) => d,
            orElse: () => const <Transaction>[],
          );
  double income = 0, expense = 0;
  for (final t in txs) {
    if (t.type.isIncome) {
      income += t.amount;
    } else {
      expense += t.amount;
    }
  }
  return TransactionTotals(
    income: income,
    expense: expense,
    balance: income - expense,
  );
});

class TransactionTotals {
  const TransactionTotals({
    required this.income,
    required this.expense,
    required this.balance,
  });
  final double income;
  final double expense;
  final double balance;
}
