# Android Signing & Certificate Fingerprints

**App Package Name:** `com.codetoday.booktracker`  
**Alias Name:** `booktracker`  
**Organization / Owner:** `CN=CodeToday, OU=Mobile, O=CodeToday, C=BD`  
**Validity:** 10,000 days (Until Feb 27, 2054)

---

## Certificate Fingerprints for Google Cloud & OAuth

Use these fingerprints when configuring the **Android OAuth 2.0 Client ID** or **Firebase** in the [Google Cloud Console](https://console.cloud.google.com/apis/credentials):

### SHA-1 Fingerprint
```text
7F:3E:8E:54:0D:8D:60:78:47:87:06:23:3E:B1:DF:86:84:B3:A5:54
```

### SHA-256 Fingerprint
```text
D2:ED:46:C6:7A:50:D0:02:A3:AA:55:44:DE:A6:CB:B7:9A:DC:12:2F:CC:55:F6:93:D0:C8:73:1C:48:65:69:AC
```

---

## GitHub Actions Secret Configuration

The keystore is securely configured in GitHub Actions Secrets for [`eabgitbd/book-tracker-codetoday`](https://github.com/eabgitbd/book-tracker-codetoday):
* `KEYSTORE_BASE64` (Base64-encoded `upload-keystore.jks`)
* `KEYSTORE_PASSWORD`
* `KEY_ALIAS` (`booktracker`)
* `KEY_PASSWORD`

Every production release APK compiled by GitHub Actions is automatically signed with this certificate.
