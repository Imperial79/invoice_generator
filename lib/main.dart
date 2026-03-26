import 'package:flutter/material.dart';
import 'package:invoice_generator/Helper/route_config.dart';
import 'package:invoice_generator/Resources/theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  final pref = await SharedPreferences.getInstance();
  final index = pref.getInt("theme_mode") ?? 0; // 0: system, 1: light, 2: dark
  themeModeNotifier.value = ThemeMode.values[index];
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, mode, _) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              themeMode: mode,
              title: 'Invoice Generator',
              theme: kTheme(context, lightDynamic: lightDynamic),
              darkTheme: kDarkTheme(context, darkDynamic: darkDynamic),
              routerConfig: routerConfig,
            );
          },
        );
      },
    );
  }
}
