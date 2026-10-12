import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class ProPaywallDialog extends ConsumerWidget {
  const ProPaywallDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Book Tracker Pro',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Unlock advanced customization, deep reading analytics, and cloud sync while keeping your data 100% private.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Feature comparison matrix
              _buildFeatureRow('Offline Library & Reading Log', true, true),
              _buildFeatureRow('Local Export & Safe Backup', true, true),
              _buildFeatureRow('All 6 Literary Themes', false, true),
              _buildFeatureRow('Automatic Google Drive Sync', false, true),
              _buildFeatureRow('Deep Reading Analytics & Prediction', false, true),
              _buildFeatureRow('Unlimited Reading Goals & Ambient Audio', false, true),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Flexible Plans • Cancel Anytime',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your local data is yours forever. Even if Pro expires, you will never lose access to your books or notes.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (settings.isPro) ...[
                OutlinedButton(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).setProStatus(false);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Switched back to Free plan.')),
                    );
                  },
                  child: const Text('Cancel / Switch to Free Plan'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    // Activate Pro (sandbox mock store)
                    ref.read(settingsProvider.notifier).setProStatus(
                          true,
                          expiry: DateTime.now().add(const Duration(days: 365)),
                        );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Welcome to Book Tracker Pro!')),
                    );
                  },
                  child: const Text('Upgrade to Pro • \$1.99 / Month'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).setProStatus(
                          true,
                          expiry: DateTime.now().add(const Duration(days: 365)),
                        );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Purchases restored successfully!')),
                    );
                  },
                  child: const Text('Restore Purchases'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool free, bool pro) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: 50,
            child: Center(
              child: free
                  ? const Icon(Icons.check, size: 18, color: Colors.green)
                  : const Icon(Icons.close, size: 18, color: Colors.grey),
            ),
          ),
          const SizedBox(
            width: 50,
            child: Center(
              child: Icon(Icons.check, size: 18, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
