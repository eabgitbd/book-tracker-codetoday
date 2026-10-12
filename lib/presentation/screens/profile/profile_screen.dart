import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/services/backup_restore_service.dart';
import '../../providers/book_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/drive_sync_provider.dart';
import '../../providers/sound_player_provider.dart';
import '../../widgets/theme_selector_dialog.dart';
import 'about_screen.dart';
import 'pro_paywall_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final entitlement = ref.watch(entitlementProvider);
    final driveSync = ref.watch(driveSyncProvider);
    final soundState = ref.watch(soundPlayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Pro Status / Upgrade Banner
          Card(
            color: entitlement.isPro
                ? theme.colorScheme.primary.withOpacity(0.12)
                : Colors.amber.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    entitlement.isPro ? Icons.verified : Icons.stars,
                    color: entitlement.isPro ? theme.colorScheme.primary : Colors.amber.shade800,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entitlement.isPro ? 'Book Tracker Pro Active' : 'Free Plan',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entitlement.isPro
                              ? 'All literary themes & cloud sync unlocked'
                              : 'Upgrade for premium themes, Drive sync & deep analytics',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const ProPaywallDialog(),
                      );
                    },
                    child: Text(entitlement.isPro ? 'Manage' : 'Upgrade'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Theme Preset'),
              subtitle: Text(settings.themePreset.displayName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const ThemeSelectorDialog(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Reading Goals
          _buildSectionHeader('Reading Goals'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.track_changes_outlined),
                  title: const Text('Daily Page Target'),
                  subtitle: Text('${settings.dailyPageGoal} pages per day'),
                  trailing: const Icon(Icons.edit_outlined, size: 20),
                  onTap: () => _editPageGoal(context, ref, settings.dailyPageGoal),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Daily Reading Time Target'),
                  subtitle: Text('${settings.dailyMinuteGoal} minutes per day'),
                  trailing: const Icon(Icons.edit_outlined, size: 20),
                  onTap: () => _editMinuteGoal(context, ref, settings.dailyMinuteGoal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Ambient Reading Sound Player
          _buildSectionHeader('Ambient Reading Atmosphere'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(soundState.currentSound.icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Text(
                            soundState.currentSound.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(soundState.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 32),
                        color: theme.colorScheme.primary,
                        onPressed: () {
                          ref.read(soundPlayerProvider.notifier).togglePlay();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: AmbientSound.values.map((sound) {
                      final isSelected = soundState.currentSound == sound;
                      return ChoiceChip(
                        label: Text('${sound.icon} ${sound.name.toUpperCase()}'),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) ref.read(soundPlayerProvider.notifier).selectSound(sound);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Backup & Data Management
          _buildSectionHeader('Data & Backup'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Export Library Backup (JSON)'),
                  subtitle: const Text('Export all books, reading sessions, and quotes'),
                  onTap: () => _exportBackup(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload_outlined),
                  title: const Text('Import / Restore Backup'),
                  subtitle: const Text('Safe restore with pre-restore snapshot guarantee'),
                  onTap: () => _showImportDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Google Drive Cloud Sync
          _buildSectionHeader('Google Drive Cloud Sync'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        driveSync.isConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: driveSync.isConnected ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driveSync.isConnected ? 'Google Drive Connected' : 'Drive Disconnected',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              driveSync.isConnected
                                  ? 'Account: ${driveSync.accountEmail}'
                                  : 'Connect for background library sync',
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (driveSync.isConnected)
                        TextButton(
                          onPressed: () => ref.read(driveSyncProvider.notifier).disconnect(),
                          child: const Text('Disconnect'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => _connectDrive(context, ref),
                          child: const Text('Connect'),
                        ),
                    ],
                  ),
                  if (driveSync.isConnected) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          driveSync.lastSyncTime != null
                              ? 'Last sync: ${DateFormatter.formatRelative(driveSync.lastSyncTime!)}'
                              : 'Not synced yet',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        TextButton.icon(
                          icon: driveSync.isSyncing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.sync, size: 18),
                          label: Text(driveSync.isSyncing ? 'Syncing...' : 'Sync Now'),
                          onPressed: driveSync.isSyncing
                              ? null
                              : () => ref.read(driveSyncProvider.notifier).triggerSync(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // About CodeToday
          _buildSectionHeader('About'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Book Tracker'),
              subtitle: const Text('Developed by CodeToday • Version 1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
      ),
    );
  }

  void _editPageGoal(BuildContext context, WidgetRef ref, int current) {
    final controller = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Daily Page Target'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Pages per day'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                ref.read(settingsProvider.notifier).setDailyGoals(pages: val);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editMinuteGoal(BuildContext context, WidgetRef ref, int current) {
    final controller = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Daily Minute Target'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Minutes per day'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                ref.read(settingsProvider.notifier).setDailyGoals(minutes: val);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _exportBackup(BuildContext context, WidgetRef ref) {
    final books = ref.read(booksProvider);
    final sessions = ref.read(sessionsProvider);
    final notes = ref.read(notesProvider);
    final settings = ref.read(settingsProvider);

    final backupJson = BackupRestoreService.createBackupJson(
      books: books,
      sessions: sessions,
      notes: notes,
      settings: settings,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Backup Generated'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Successfully packed ${books.length} books, ${sessions.length} sessions, and ${notes.length} notes into valid JSON.'),
              const SizedBox(height: 12),
              Container(
                height: 120,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    backupJson,
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Done')),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore / Import Backup'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Paste your .booktracker JSON backup content below. A safety pre-restore snapshot will be created before restoring.'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(hintText: 'Paste backup JSON here...'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final jsonStr = controller.text.trim();
              final validation = BackupRestoreService.validateBackupJson(jsonStr);
              if (!validation.isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid backup: ${validation.errorMessage}')),
                );
                return;
              }

              // Parse payload
              final payload = BackupRestoreService.parseBackupPayload(jsonStr);

              // Save safety snapshot of current data before overwriting
              final currentBooks = ref.read(booksProvider);
              final currentSessions = ref.read(sessionsProvider);
              final currentNotes = ref.read(notesProvider);
              final currentSettings = ref.read(settingsProvider);
              final snapshotJson = BackupRestoreService.createBackupJson(
                books: currentBooks,
                sessions: currentSessions,
                notes: currentNotes,
                settings: currentSettings,
              );
              await ref.read(localStorageSourceProvider).savePreRestoreSnapshot(snapshotJson);

              // Restore books
              for (final book in payload.books) {
                await ref.read(booksProvider.notifier).saveBook(book);
              }
              for (final session in payload.sessions) {
                await ref.read(sessionsProvider.notifier).logSession(session);
              }
              for (final note in payload.notes) {
                await ref.read(notesProvider.notifier).addNote(note);
              }

              if (context.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Restored ${payload.books.length} books successfully! Pre-restore snapshot created.')),
                );
              }
            },
            child: const Text('Validate & Restore'),
          ),
        ],
      ),
    );
  }

  void _connectDrive(BuildContext context, WidgetRef ref) {
    ref.read(driveSyncProvider.notifier).connect('reader@gmail.com');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connected to Google Drive!')),
    );
  }
}
