import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';

abstract class SettingsLocalDataSource {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;

  static const _kThemeMode = 'settings.themeMode';
  static const _kCurrency = 'settings.currencyCode';
  static const _kLocale = 'settings.locale';

  @override
  Future<AppSettings> load() async {
    final themeIndex = _prefs.getInt(_kThemeMode);
    return AppSettings(
      themeMode: themeIndex == null
          ? ThemeMode.system
          : ThemeMode.values[themeIndex],
      currencyCode: _prefs.getString(_kCurrency) ?? 'COP',
      locale: _prefs.getString(_kLocale) ?? 'es_CO',
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    await Future.wait([
      _prefs.setInt(_kThemeMode, settings.themeMode.index),
      _prefs.setString(_kCurrency, settings.currencyCode),
      _prefs.setString(_kLocale, settings.locale),
    ]);
  }
}
