import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sources/cloud_drive_adapter.dart';
import '../../domain/models/sync_outbox_item.dart';
import 'settings_provider.dart';

class DriveSyncState {
  final bool isConnected;
  final String? accountEmail;
  final bool isSyncing;
  final int pendingCount;
  final String? lastError;
  final DateTime? lastSyncTime;

  const DriveSyncState({
    this.isConnected = false,
    this.accountEmail,
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastError,
    this.lastSyncTime,
  });

  DriveSyncState copyWith({
    bool? isConnected,
    String? accountEmail,
    bool? isSyncing,
    int? pendingCount,
    String? lastError,
    DateTime? lastSyncTime,
  }) {
    return DriveSyncState(
      isConnected: isConnected ?? this.isConnected,
      accountEmail: accountEmail ?? this.accountEmail,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: lastError ?? this.lastError,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class DriveSyncNotifier extends StateNotifier<DriveSyncState> {
  final CloudDriveAdapter _adapter = CloudDriveAdapter();
  final Ref _ref;

  DriveSyncNotifier(this._ref) : super(const DriveSyncState()) {
    _init();
  }

  Future<void> _init() async {
    final storage = _ref.read(localStorageSourceProvider);
    final outbox = await storage.loadOutbox();
    final settings = _ref.read(settingsProvider);
    state = state.copyWith(
      pendingCount: outbox.length,
      lastSyncTime: settings.lastDriveSyncTime,
    );
  }

  Future<void> connect(String email) async {
    state = state.copyWith(isSyncing: true, lastError: null);
    final success = await _adapter.connectAccount(email);
    if (success) {
      await _ref.read(settingsProvider.notifier).toggleDriveSync(true);
      state = state.copyWith(
        isConnected: true,
        accountEmail: email,
        isSyncing: false,
      );
      await triggerSync();
    } else {
      state = state.copyWith(
        isSyncing: false,
        lastError: 'Failed to connect Google account.',
      );
    }
  }

  Future<void> disconnect() async {
    await _adapter.disconnectAccount();
    await _ref.read(settingsProvider.notifier).toggleDriveSync(false);
    state = const DriveSyncState();
  }

  Future<void> triggerSync() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true, lastError: null);

    final storage = _ref.read(localStorageSourceProvider);
    final outbox = await storage.loadOutbox();

    final result = await _adapter.processOutbox(outbox);
    if (result.success) {
      // Clear processed outbox
      await storage.saveOutbox([]);
      await _ref.read(settingsProvider.notifier).recordSyncCompleted();
      state = state.copyWith(
        isSyncing: false,
        pendingCount: 0,
        lastSyncTime: result.syncTime,
      );
    } else {
      state = state.copyWith(
        isSyncing: false,
        lastError: result.errorMessage,
      );
    }
  }

  Future<void> queueSyncItem(SyncOutboxItem item) async {
    final storage = _ref.read(localStorageSourceProvider);
    final outbox = await storage.loadOutbox();
    outbox.add(item);
    await storage.saveOutbox(outbox);
    state = state.copyWith(pendingCount: outbox.length);
  }
}

final driveSyncProvider = StateNotifierProvider<DriveSyncNotifier, DriveSyncState>((ref) {
  return DriveSyncNotifier(ref);
});
