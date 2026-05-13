class AppConstants {
  AppConstants._();

  static const String appName = 'Gastos Personales';
  static const String defaultCurrency = 'COP';
  static const String defaultLocale = 'es_CO';

  static const Duration splashDuration = Duration(milliseconds: 1500);
  static const Duration debounceDuration = Duration(milliseconds: 350);

  static const int maxTransactionsPerPage = 25;
}
