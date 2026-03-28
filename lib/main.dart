import 'package:flutter/material.dart';
import 'package:prime_invoice/Helper/route_config.dart';
import 'package:prime_invoice/Resources/theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Essentials/ConnectionGuard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final pref = await SharedPreferences.getInstance();
  final index = pref.getInt("theme_mode") ?? 0; // 0: system, 1: light, 2: dark
  themeModeNotifier.value = ThemeMode.values[index];

  // 🛑 Initialize Database on External Drive
  await DatabaseService.instance.checkDriveAvailability();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 🛡️ Safe Shutdown when app is closed
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      DatabaseService.instance.safeShutdown();
    }
  }

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
              title: 'Prime Invoice',
              theme: kTheme(context, lightDynamic: lightDynamic),
              darkTheme: kDarkTheme(context, darkDynamic: darkDynamic),
              routerConfig: routerConfig,
              scrollBehavior: const MyScrollBehavior(),
              builder: (context, child) => ConnectionGuard(child: child!),
            );
          },
        );
      },
    );
  }
}

class MyScrollBehavior extends MaterialScrollBehavior {
  const MyScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
