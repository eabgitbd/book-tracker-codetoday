import 'package:flutter_test/flutter_test.dart';
import 'package:book_tracker/core/theme/app_theme.dart';
import 'package:book_tracker/domain/models/app_settings.dart';
import 'package:book_tracker/domain/services/entitlement_service.dart';

void main() {
  group('EntitlementService Tests', () {
    test('Free tier allows essential themes but gates advanced presets', () {
      const freeSettings = AppSettings(isPro: false);
      const service = EntitlementService(freeSettings);

      expect(service.isPro, false);
      expect(service.canAccessTheme(AppThemePreset.paperAndInk), true);
      expect(service.canAccessTheme(AppThemePreset.forestLibrary), true);
      expect(service.canAccessTheme(AppThemePreset.midnightAmoled), true);

      // Pro themes
      expect(service.canAccessTheme(AppThemePreset.vintageParchment), false);
      expect(service.canAccessTheme(AppThemePreset.glassLibrary), false);
      expect(service.canAccessTheme(AppThemePreset.sketchJournal), false);

      // Core library and export are always free!
      expect(service.canAccessCoreLibrary, true);
      expect(service.canExportBasicData, true);
    });

    test('Pro tier allows all themes and advanced capabilities', () {
      final proSettings = AppSettings(
        isPro: true,
        proExpiryDate: DateTime.now().add(const Duration(days: 30)),
      );
      final service = EntitlementService(proSettings);

      expect(service.isPro, true);
      expect(service.canAccessTheme(AppThemePreset.vintageParchment), true);
      expect(service.canAccessTheme(AppThemePreset.glassLibrary), true);
      expect(service.canAccessTheme(AppThemePreset.sketchJournal), true);
      expect(service.canUseAdvancedAnalytics, true);
      expect(service.canUseAutoDriveSync, true);
    });

    test('Expired Pro reverts gracefully without losing core data access', () {
      final expiredSettings = AppSettings(
        isPro: true,
        proExpiryDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final service = EntitlementService(expiredSettings);

      expect(service.isPro, false);
      expect(service.status, EntitlementStatus.proExpired);
      expect(service.canAccessTheme(AppThemePreset.vintageParchment), false);
      // Data remains accessible
      expect(service.canAccessCoreLibrary, true);
      expect(service.canExportBasicData, true);
    });
  });
}
