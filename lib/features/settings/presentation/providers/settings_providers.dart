import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return SettingsRepositoryImpl(SettingsLocalDataSourceImpl(prefs));
});

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _initialLoad();
    return const AppSettings();
  }

  Future<void> _initialLoad() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final repo = SettingsRepositoryImpl(SettingsLocalDataSourceImpl(prefs));
    state = await repo.load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> setCurrency(String code) async {
    state = state.copyWith(currencyCode: code);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await ref.read(settingsRepositoryProvider).save(state);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
