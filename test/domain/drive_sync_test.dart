import 'package:flutter_test/flutter_test.dart';
import 'package:book_tracker/core/config/google_oauth_config.dart';
import 'package:book_tracker/data/sources/cloud_drive_adapter.dart';
import 'package:book_tracker/domain/models/sync_outbox_item.dart';
import 'package:book_tracker/presentation/providers/drive_sync_provider.dart';

void main() {
  group('Google OAuth Config & Drive Sync Tests', () {
    test('GoogleOAuthConfig has valid client ID and required drive scopes', () {
      expect(
        GoogleOAuthConfig.clientId,
        '50877154908-3hn292kf8uta9geu6hbvthcitoavpnib.apps.googleusercontent.com',
      );
      expect(GoogleOAuthConfig.projectId, 'book-tracker-codetoday');
      expect(
        GoogleOAuthConfig.scopes,
        contains('https://www.googleapis.com/auth/drive.appdata'),
      );
      expect(
        GoogleOAuthConfig.scopes,
        contains('https://www.googleapis.com/auth/drive.file'),
      );
      expect(GoogleOAuthConfig.backupFilename, 'book_tracker_library.json');
    });

    test('CloudDriveAdapter fails gracefully when not connected', () async {
      final adapter = CloudDriveAdapter();
      expect(adapter.isConnected, false);
      expect(adapter.userAccount, isNull);

      final uploadResult = await adapter.uploadBackup('{}');
      expect(uploadResult.success, false);
      expect(uploadResult.errorMessage, contains('not connected'));

      final downloadResult = await adapter.downloadBackup();
      expect(downloadResult, isNull);

      final outboxResult = await adapter.processOutbox([
        SyncOutboxItem(
          id: 'item1',
          entityType: 'book',
          entityId: 'b1',
          action: SyncAction.create,
          payloadJson: '{}',
          createdAt: DateTime.now(),
        ),
      ]);
      expect(outboxResult.success, false);
    });

    test('DriveSyncState copyWith preserves and updates state accurately', () {
      const initial = DriveSyncState();
      expect(initial.isConnected, false);
      expect(initial.isSyncing, false);
      expect(initial.pendingCount, 0);

      final updated = initial.copyWith(
        isConnected: true,
        accountEmail: 'reader@codetoday.app',
        accountDisplayName: 'Reader Name',
        pendingCount: 5,
        lastError: 'Temporary network timeout',
      );

      expect(updated.isConnected, true);
      expect(updated.accountEmail, 'reader@codetoday.app');
      expect(updated.accountDisplayName, 'Reader Name');
      expect(updated.pendingCount, 5);
      expect(updated.lastError, 'Temporary network timeout');

      // Clear error flag test
      final cleared = updated.copyWith(clearLastError: true);
      expect(cleared.lastError, isNull);
      expect(cleared.isConnected, true);
    });
  });
}
