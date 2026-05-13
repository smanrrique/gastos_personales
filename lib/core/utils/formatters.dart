import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class Formatters {
  Formatters._();

  static String currency(
    num value, {
    String locale = AppConstants.defaultLocale,
    String currencyCode = AppConstants.defaultCurrency,
    int decimalDigits = 0,
  }) {
    final fmt = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      decimalDigits: decimalDigits,
    );
    return fmt.format(value);
  }

  static String compactNumber(num value, {String locale = AppConstants.defaultLocale}) {
    return NumberFormat.compact(locale: locale).format(value);
  }

  static String date(DateTime date,
      {String pattern = 'dd MMM yyyy',
      String locale = AppConstants.defaultLocale}) {
    return DateFormat(pattern, locale).format(date);
  }

  static String monthYear(DateTime date,
      {String locale = AppConstants.defaultLocale}) {
    return DateFormat.yMMMM(locale).format(date);
  }

  static String relative(DateTime value) {
    final now = DateTime.now();
    final diff = now.difference(value);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'hace ${diff.inDays} d';
    return date(value);
  }

  static double? parseAmount(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9,.\-]'), '').replaceAll(',', '.');
    return double.tryParse(cleaned);
  }
}
