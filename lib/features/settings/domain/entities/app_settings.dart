import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.currencyCode = 'COP',
    this.locale = 'es_CO',
  });

  final ThemeMode themeMode;
  final String currencyCode;
  final String locale;

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? currencyCode,
    String? locale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      currencyCode: currencyCode ?? this.currencyCode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, currencyCode, locale];
}
