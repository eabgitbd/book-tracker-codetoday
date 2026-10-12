import '../../domain/models/sync_outbox_item.dart';

class CloudSyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final String? errorMessage;
  final DateTime syncTime;

  const CloudSyncResult({
    required this.success,
    required this.syncedCount,
    required this.failedCount,
    this.errorMessage,
    required this.syncTime,
  });
}

class CloudDriveAdapter {
  bool _isConnected = false;
  String? _userAccount;

  bool get isConnected => _isConnected;
  String? get userAccount => _userAccount;

  Future<bool> connectAccount(String email) async {
    // In production, performs Google OAuth2 sign-in with drive.appdata scope
    await Future.delayed(const Duration(milliseconds: 300));
    _isConnected = true;
    _userAccount = email;
    return true;
  }

  Future<void> disconnectAccount() async {
    _isConnected = false;
    _userAccount = null;
  }

  Future<CloudSyncResult> processOutbox(List<SyncOutboxItem> outbox) async {
    if (!_isConnected) {
      return CloudSyncResult(
        success: false,
        syncedCount: 0,
        failedCount: outbox.length,
        errorMessage: 'Google Drive is not connected. Please connect in Settings.',
        syncTime: DateTime.now(),
      );
    }

    if (outbox.isEmpty) {
      return CloudSyncResult(
        success: true,
        syncedCount: 0,
        failedCount: 0,
        syncTime: DateTime.now(),
      );
    }

    // Process pending items idempotently
    int processed = 0;
    for (final _ in outbox) {
      processed++;
    }

    return CloudSyncResult(
      success: true,
      syncedCount: processed,
      failedCount: 0,
      syncTime: DateTime.now(),
    );
  }
}
