enum TransactionType {
  income,
  expense;

  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;

  String get label => switch (this) {
        TransactionType.income => 'Ingreso',
        TransactionType.expense => 'Gasto',
      };
}
