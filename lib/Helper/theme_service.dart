import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const String _boxName = 'theme_box';
  static const String _themeKey = 'theme_mode';

  late Box _box;
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    
    // Load saved theme
    final int index = _box.get(_themeKey, defaultValue: ThemeMode.system.index);
    themeModeNotifier.value = ThemeMode.values[index];
    
    debugPrint("ThemeService Initialized: ${themeModeNotifier.value}");
  }

  void setThemeMode(ThemeMode mode) {
    if (themeModeNotifier.value == mode) return;
    
    themeModeNotifier.value = mode;
    _box.put(_themeKey, mode.index);
    debugPrint("ThemeMode changed to: $mode");
  }

  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;
}
