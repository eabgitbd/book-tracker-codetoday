import '../../core/theme/app_theme.dart';
import '../models/app_settings.dart';

enum EntitlementStatus {
  free,
  proActive,
  proGracePeriod,
  proExpired,
}

class EntitlementService {
  final AppSettings settings;

  const EntitlementService(this.settings);

  bool get isPro => settings.isPro && !isSubscriptionExpired;

  bool get isSubscriptionExpired {
    if (!settings.isPro) return false;
    if (settings.proExpiryDate == null) return false;
    return DateTime.now().isAfter(settings.proExpiryDate!);
  }

  EntitlementStatus get status {
    if (!settings.isPro) return EntitlementStatus.free;
    if (isSubscriptionExpired) return EntitlementStatus.proExpired;
    return EntitlementStatus.proActive;
  }

  bool canAccessTheme(AppThemePreset preset) {
    if (isPro) return true;
    switch (preset) {
      case AppThemePreset.paperAndInk:
      case AppThemePreset.forestLibrary:
      case AppThemePreset.midnightAmoled:
        return true;
      case AppThemePreset.vintageParchment:
      case AppThemePreset.glassLibrary:
      case AppThemePreset.sketchJournal:
        return false;
    }
  }

  bool get canUseAdvancedAnalytics => isPro;
  bool get canUseAutoDriveSync => isPro;
  bool get canUseDetailedExport => isPro;
  bool get canUseUnlimitedGoals => isPro;

  // Never lock users out of their core library, even if pro expired!
  bool get canAccessCoreLibrary => true;
  bool get canExportBasicData => true;
}
