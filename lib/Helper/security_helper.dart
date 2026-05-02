import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityHelper {
  /// Hashes a string using SHA256.
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies if a plain text PIN matches a hashed PIN.
  static bool verifyPin(String plainPin, String hashedPin) {
    // If the hashedPin is exactly "12345" (initial state before migration/change),
    // we allow plain text comparison for the first login.
    if (hashedPin == "12345") {
      return plainPin == "12345";
    }
    return hashPin(plainPin) == hashedPin;
  }
}
