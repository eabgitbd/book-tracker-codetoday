import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/main_shell_screen.dart';

class BookTrackerApp extends ConsumerWidget {
  const BookTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeData = AppTheme.getThemeData(settings.themePreset);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const MainShellScreen(),
    );
  }
}
