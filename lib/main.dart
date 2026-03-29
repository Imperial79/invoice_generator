import 'package:flutter/material.dart';
import 'package:prime_invoice/Helper/route_config.dart';
import 'package:prime_invoice/JewelleryApp/Theme.dart';
import 'package:prime_invoice/Helper/theme_service.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:prime_invoice/Resources/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'dart:ui';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Essentials/ConnectionGuard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🎨 Initialize Theme Service (Hive Persistence)
  await ThemeService.instance.init();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      DatabaseService.instance.safeShutdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, mode, _) {
        debugPrint("[ThemeUpdate] Rebuilding Root with ThemeMode: $mode");
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            return MaterialApp.router(
              key: ValueKey(
                mode,
              ), // Force reset structure on mode change if needed
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.dark,
              title: 'Aurora Jewellers',
              // theme: JewelleryTheme.lightTheme(context),
              // darkTheme: JewelleryTheme.darkTheme(context),
              darkTheme: kDarkTheme(context),
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
