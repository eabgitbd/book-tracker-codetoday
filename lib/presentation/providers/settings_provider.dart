import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/sources/local_storage_source.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/services/entitlement_service.dart';

final localStorageSourceProvider = Provider<LocalStorageSource>((ref) {
  return LocalStorageSource();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorageSource _storage;

  SettingsNotifier(this._storage) : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _storage.loadSettings();
    state = settings;
  }

  Future<void> setTheme(AppThemePreset preset) async {
    state = state.copyWith(themePreset: preset);
    await _storage.saveSettings(state);
  }

  Future<void> setDailyGoals({int? pages, int? minutes}) async {
    state = state.copyWith(
      dailyPageGoal: pages ?? state.dailyPageGoal,
      dailyMinuteGoal: minutes ?? state.dailyMinuteGoal,
    );
    await _storage.saveSettings(state);
  }

  Future<void> setProStatus(bool isPro, {DateTime? expiry}) async {
    state = state.copyWith(
      isPro: isPro,
      proExpiryDate: expiry,
    );
    await _storage.saveSettings(state);
  }

  Future<void> toggleDriveSync(bool enabled) async {
    state = state.copyWith(isDriveSyncEnabled: enabled);
    await _storage.saveSettings(state);
  }

  Future<void> recordSyncCompleted() async {
    state = state.copyWith(lastDriveSyncTime: DateTime.now());
    await _storage.saveSettings(state);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(localStorageSourceProvider);
  return SettingsNotifier(storage);
});

final entitlementProvider = Provider<EntitlementService>((ref) {
  final settings = ref.watch(settingsProvider);
  return EntitlementService(settings);
});
