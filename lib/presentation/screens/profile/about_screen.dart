import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_links.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openFacebook(BuildContext context) async {
    final uri = Uri.parse(AppLinks.facebookPageUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback to platform default browser
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // App Emblem
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Version ${AppConstants.appVersion} (Build ${AppConstants.buildNumber})',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Developed by ${AppConstants.developer}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              AppConstants.appDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 32),

            // Required Facebook Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('facebook_visit_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2), // Facebook Brand Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.thumb_up, size: 20),
                label: const Text(
                  AppLinks.facebookButtonLabel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _openFacebook(context),
              ),
            ),
            const SizedBox(height: 32),

            const Divider(),
            const SizedBox(height: 16),

            // Privacy & Architecture principles
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Product Guarantees',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _buildPrincipleRow(
              icon: Icons.offline_pin_outlined,
              title: '100% Offline-First',
              description: 'Your library and notes are stored locally on your device.',
            ),
            _buildPrincipleRow(
              icon: Icons.lock_outline,
              title: 'Private by Design',
              description: 'No telemetry or silent data collection. You own your reading data.',
            ),
            _buildPrincipleRow(
              icon: Icons.import_export,
              title: 'Open Portability',
              description: 'Export and restore your complete library anytime in open JSON.',
            ),

            const SizedBox(height: 32),
            Text(
              '© ${DateTime.now().year} ${AppConstants.developer}. All rights reserved.',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipleRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF315B48)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
