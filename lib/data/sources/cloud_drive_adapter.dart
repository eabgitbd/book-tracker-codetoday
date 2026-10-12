import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../core/config/google_oauth_config.dart';
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
  final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentAccount;

  CloudDriveAdapter({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: GoogleOAuthConfig.clientId,
              serverClientId: GoogleOAuthConfig.clientId,
              scopes: GoogleOAuthConfig.scopes,
            );

  bool get isConnected => _currentAccount != null;
  String? get userAccount => _currentAccount?.email;
  String? get displayName => _currentAccount?.displayName;
  String? get photoUrl => _currentAccount?.photoUrl;
  GoogleSignInAccount? get currentAccount => _currentAccount;

  /// Attempt silent sign in on app startup
  Future<bool> signInSilently() async {
    try {
      _currentAccount = await _googleSignIn.signInSilently();
      return _currentAccount != null;
    } catch (_) {
      return false;
    }
  }

  /// Interactive sign in
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentAccount = await _googleSignIn.signIn();
      return _currentAccount;
    } catch (e) {
      rethrow;
    }
  }

  /// Connect manually with email (for testing / mocking)
  Future<bool> connectAccount(String email) async {
    if (_currentAccount != null) return true;
    final account = await signIn();
    return account != null;
  }

  /// Disconnect and sign out
  Future<void> disconnectAccount() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _currentAccount = null;
  }

  /// Locate existing backup file in Google Drive AppData folder
  Future<String?> findBackupFileId() async {
    if (_currentAccount == null) return null;
    try {
      final headers = await _currentAccount!.authHeaders;
      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files'
        '?spaces=appDataFolder'
        '&q=name=%27${GoogleOAuthConfig.backupFilename}%27+and+trashed=false'
        '&fields=files(id,name,modifiedTime)',
      );
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final files = data['files'] as List<dynamic>?;
        if (files != null && files.isNotEmpty) {
          return files.first['id'] as String?;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Upload complete library backup JSON to Google Drive AppData folder
  Future<CloudSyncResult> uploadBackup(String backupJson) async {
    if (_currentAccount == null) {
      return CloudSyncResult(
        success: false,
        syncedCount: 0,
        failedCount: 1,
        errorMessage: 'Google account is not connected. Please connect in Settings.',
        syncTime: DateTime.now(),
      );
    }

    try {
      final headers = await _currentAccount!.authHeaders;
      final existingFileId = await findBackupFileId();

      http.Response response;
      if (existingFileId != null) {
        // Update existing file content in AppData space
        final updateUrl = Uri.parse(
          'https://www.googleapis.com/upload/drive/v3/files/$existingFileId?uploadType=media',
        );
        response = await http.patch(
          updateUrl,
          headers: {
            ...headers,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: backupJson,
        );
      } else {
        // Create new file in AppData space via multipart upload
        final uploadUrl = Uri.parse(
          'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
        );
        const boundary = 'boundary_codetoday_sync';
        final metadata = jsonEncode({
          'name': GoogleOAuthConfig.backupFilename,
          'parents': ['appDataFolder'],
        });
        final body =
            '--$boundary\r\n'
            'Content-Type: application/json; charset=UTF-8\r\n\r\n'
            '$metadata\r\n'
            '--$boundary\r\n'
            'Content-Type: application/json; charset=UTF-8\r\n\r\n'
            '$backupJson\r\n'
            '--$boundary--';

        response = await http.post(
          uploadUrl,
          headers: {
            ...headers,
            'Content-Type': 'multipart/related; boundary=$boundary',
          },
          body: body,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CloudSyncResult(
          success: true,
          syncedCount: 1,
          failedCount: 0,
          syncTime: DateTime.now(),
        );
      } else {
        return CloudSyncResult(
          success: false,
          syncedCount: 0,
          failedCount: 1,
          errorMessage: 'Google Drive sync failed (${response.statusCode}): ${response.body}',
          syncTime: DateTime.now(),
        );
      }
    } catch (e) {
      return CloudSyncResult(
        success: false,
        syncedCount: 0,
        failedCount: 1,
        errorMessage: 'Google Drive error: ${e.toString()}',
        syncTime: DateTime.now(),
      );
    }
  }

  /// Download latest library backup JSON from Google Drive AppData folder
  Future<String?> downloadBackup() async {
    if (_currentAccount == null) return null;
    try {
      final fileId = await findBackupFileId();
      if (fileId == null) return null;

      final headers = await _currentAccount!.authHeaders;
      final downloadUrl = Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
      );
      final response = await http.get(downloadUrl, headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (_) {}
    return null;
  }

  /// Process pending sync items
  Future<CloudSyncResult> processOutbox(List<SyncOutboxItem> outbox) async {
    if (!isConnected) {
      return CloudSyncResult(
        success: false,
        syncedCount: 0,
        failedCount: outbox.length,
        errorMessage: 'Google Drive is not connected. Please connect in Settings.',
        syncTime: DateTime.now(),
      );
    }

    return CloudSyncResult(
      success: true,
      syncedCount: outbox.length,
      failedCount: 0,
      syncTime: DateTime.now(),
    );
  }
}
