/// Google OAuth 2.0 Client Configuration
/// Configured for project "book-tracker-codetoday"
class GoogleOAuthConfig {
  /// The OAuth 2.0 Web Client ID generated in Google Cloud Console
  /// Required as serverClientId on Android for Drive API scopes
  static const String webClientId =
      '50877154908-oilmqvro7cthu2fb4t3t0rji6ps12hkh.apps.googleusercontent.com';

  /// Legacy installed client ID
  static const String clientId =
      '50877154908-3hn292kf8uta9geu6hbvthcitoavpnib.apps.googleusercontent.com';

  /// Google Cloud Project ID
  static const String projectId = 'book-tracker-codetoday';

  /// Google OAuth Authorization Endpoint
  static const String authUri = 'https://accounts.google.com/o/oauth2/auth';

  /// Google OAuth Token Endpoint
  static const String tokenUri = 'https://oauth2.googleapis.com/token';

  /// Google OAuth Certificate URL
  static const String authProviderCertUrl =
      'https://www.googleapis.com/oauth2/v1/certs';

  /// Scopes required for Google Sign-In and private appData sync
  static const List<String> scopes = [
    'email',
    'https://www.googleapis.com/auth/drive.appdata',
    'https://www.googleapis.com/auth/drive.file',
  ];

  /// Drive AppData backup filename
  static const String backupFilename = 'book_tracker_library.json';
}
