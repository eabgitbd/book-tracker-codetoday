import '../../core/theme/app_theme.dart';

class AppSettings {
  final AppThemePreset themePreset;
  final double fontScale;
  final int dailyPageGoal;
  final int dailyMinuteGoal;
  final bool isPro;
  final DateTime? proExpiryDate;
  final bool isDriveSyncEnabled;
  final DateTime? lastDriveSyncTime;
  final bool ambientAudioEnabled;

  const AppSettings({
    this.themePreset = AppThemePreset.paperAndInk,
    this.fontScale = 1.0,
    this.dailyPageGoal = 25,
    this.dailyMinuteGoal = 30,
    this.isPro = false,
    this.proExpiryDate,
    this.isDriveSyncEnabled = false,
    this.lastDriveSyncTime,
    this.ambientAudioEnabled = false,
  });

  AppSettings copyWith({
    AppThemePreset? themePreset,
    double? fontScale,
    int? dailyPageGoal,
    int? dailyMinuteGoal,
    bool? isPro,
    DateTime? proExpiryDate,
    bool? isDriveSyncEnabled,
    DateTime? lastDriveSyncTime,
    bool? ambientAudioEnabled,
  }) {
    return AppSettings(
      themePreset: themePreset ?? this.themePreset,
      fontScale: fontScale ?? this.fontScale,
      dailyPageGoal: dailyPageGoal ?? this.dailyPageGoal,
      dailyMinuteGoal: dailyMinuteGoal ?? this.dailyMinuteGoal,
      isPro: isPro ?? this.isPro,
      proExpiryDate: proExpiryDate ?? this.proExpiryDate,
      isDriveSyncEnabled: isDriveSyncEnabled ?? this.isDriveSyncEnabled,
      lastDriveSyncTime: lastDriveSyncTime ?? this.lastDriveSyncTime,
      ambientAudioEnabled: ambientAudioEnabled ?? this.ambientAudioEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themePreset': themePreset.name,
      'fontScale': fontScale,
      'dailyPageGoal': dailyPageGoal,
      'dailyMinuteGoal': dailyMinuteGoal,
      'isPro': isPro,
      'proExpiryDate': proExpiryDate?.toIso8601String(),
      'isDriveSyncEnabled': isDriveSyncEnabled,
      'lastDriveSyncTime': lastDriveSyncTime?.toIso8601String(),
      'ambientAudioEnabled': ambientAudioEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themePreset: AppThemePreset.values.firstWhere(
        (p) => p.name == json['themePreset'],
        orElse: () => AppThemePreset.paperAndInk,
      ),
      fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1.0,
      dailyPageGoal: json['dailyPageGoal'] as int? ?? 25,
      dailyMinuteGoal: json['dailyMinuteGoal'] as int? ?? 30,
      isPro: json['isPro'] as bool? ?? false,
      proExpiryDate: json['proExpiryDate'] != null ? DateTime.parse(json['proExpiryDate'] as String) : null,
      isDriveSyncEnabled: json['isDriveSyncEnabled'] as bool? ?? false,
      lastDriveSyncTime: json['lastDriveSyncTime'] != null ? DateTime.parse(json['lastDriveSyncTime'] as String) : null,
      ambientAudioEnabled: json['ambientAudioEnabled'] as bool? ?? false,
    );
  }
}
