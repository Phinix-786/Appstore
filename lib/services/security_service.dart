import 'dart:io';
import 'package:crypto/crypto.dart';

class SecurityService {
  static Future<SecurityScanResult> scanApk(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return SecurityScanResult(
        isClean: false,
        threats: ['File not found'],
        score: 0,
      );
    }

    final threats = <String>[];
    var score = 100;

    final bytes = await file.readAsBytes();
    final fileHash = sha256.convert(bytes).toString();

    if (bytes.length < 1000) {
      threats.add('File too small - may be corrupted');
      score -= 50;
    }

    if (bytes.length > 0 && bytes[0] != 0x50) {
      threats.add('Invalid APK header - not a valid ZIP/APK file');
      score -= 80;
    }

    return SecurityScanResult(
      isClean: threats.isEmpty,
      threats: threats,
      score: score.clamp(0, 100),
      fileHash: fileHash,
      fileSize: bytes.length,
    );
  }

  static Future<bool> verifySignature(String filePath, String expectedSignature) async {
    if (expectedSignature.isEmpty) return true;

    final file = File(filePath);
    if (!await file.exists()) return false;

    final bytes = await file.readAsBytes();
    final actualHash = sha256.convert(bytes).toString();

    return actualHash == expectedSignature;
  }

  static Future<String> getFileHash(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return '';

    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  static Map<String, String> analyzePermissions(List<String> permissions) {
    final Map<String, String> analysis = {};

    const dangerousPermissions = {
      'android.permission.CAMERA': 'Can access your camera',
      'android.permission.RECORD_AUDIO': 'Can record audio',
      'android.permission.READ_CONTACTS': 'Can read your contacts',
      'android.permission.ACCESS_FINE_LOCATION': 'Can access precise location',
      'android.permission.READ_SMS': 'Can read SMS messages',
      'android.permission.SEND_SMS': 'Can send SMS messages',
      'android.permission.READ_CALL_LOG': 'Can read call history',
      'android.permission.READ_EXTERNAL_STORAGE': 'Can read files on device',
      'android.permission.WRITE_EXTERNAL_STORAGE': 'Can modify files on device',
      'android.permission.INTERNET': 'Can access the internet',
      'android.permission.ACCESS_NETWORK_STATE': 'Can check network status',
      'android.permission.RECEIVE_BOOT_COMPLETED': 'Runs at startup',
      'android.permission.SYSTEM_ALERT_WINDOW': 'Can display over other apps',
      'android.permission.REQUEST_INSTALL_PACKAGES': 'Can install other apps',
    };

    for (final perm in permissions) {
      if (dangerousPermissions.containsKey(perm)) {
        analysis[perm] = dangerousPermissions[perm]!;
      }
    }

    return analysis;
  }

  static String getRiskLevel(List<String> permissions) {
    int riskScore = 0;

    const highRisk = [
      'android.permission.SEND_SMS',
      'android.permission.READ_SMS',
      'android.permission.SYSTEM_ALERT_WINDOW',
      'android.permission.REQUEST_INSTALL_PACKAGES',
    ];

    const mediumRisk = [
      'android.permission.CAMERA',
      'android.permission.RECORD_AUDIO',
      'android.permission.READ_CONTACTS',
      'android.permission.ACCESS_FINE_LOCATION',
      'android.permission.READ_CALL_LOG',
    ];

    for (final perm in permissions) {
      if (highRisk.contains(perm)) riskScore += 3;
      if (mediumRisk.contains(perm)) riskScore += 2;
    }

    if (riskScore >= 8) return 'High';
    if (riskScore >= 4) return 'Medium';
    return 'Low';
  }
}

class SecurityScanResult {
  final bool isClean;
  final List<String> threats;
  final int score;
  final String? fileHash;
  final int? fileSize;

  SecurityScanResult({
    required this.isClean,
    required this.threats,
    required this.score,
    this.fileHash,
    this.fileSize,
  });
}
