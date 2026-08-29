import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformHelper {
  /// True when running on Windows desktop
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// True when running on macOS desktop
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// True when running on Linux desktop
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// True when running on any desktop platform
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// True on Android / iOS
  static bool get isMobile =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
