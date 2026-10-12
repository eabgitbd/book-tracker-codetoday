import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../screens/profile/pro_paywall_dialog.dart';

class ThemeSelectorDialog extends ConsumerWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final entitlement = ref.watch(entitlementProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Theme',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: AppThemePreset.values.map((preset) {
                  final isSelected = settings.themePreset == preset;
                  final isAllowed = entitlement.canAccessTheme(preset);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? BorderSide(color: theme.colorScheme.primary, width: 2)
                          : BorderSide.none,
                    ),
                    tileColor: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : null,
                    title: Row(
                      children: [
                        Text(
                          preset.displayName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        if (!isAllowed) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      preset.description,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                        : null,
                    onTap: () {
                      if (!isAllowed) {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (_) => const ProPaywallDialog(),
                        );
                      } else {
                        ref.read(settingsProvider.notifier).setTheme(preset);
                        Navigator.of(context).pop();
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
