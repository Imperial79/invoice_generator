import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prime_invoice/Helper/route_config.dart';
import 'package:prime_invoice/Resources/theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:prime_invoice/Essentials/ConnectionGuard.dart';
import 'package:prime_invoice/Helper/platform_helper.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final pref = await SharedPreferences.getInstance();
  final index = pref.getInt("theme_mode") ?? 0; // 0: system, 1: light, 2: dark
  themeModeNotifier.value = ThemeMode.values[index];

  // Windows-specific: set minimum window size and center on screen
  if (PlatformHelper.isWindows) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      minimumSize: Size(900, 600),
      title: 'Prime Invoice',
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

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
  Widget build(BuildContext context) {
    // ── Windows: use FluentApp ──────────────────────────────────────────────
    if (PlatformHelper.isWindows) {
      return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) {
          final isDark =
              mode == ThemeMode.dark ||
              (mode == ThemeMode.system &&
                  WidgetsBinding
                          .instance
                          .platformDispatcher
                          .platformBrightness ==
                      Brightness.dark);
          return fluent.FluentApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Prime Invoice',
            themeMode: mode,
            theme: fluent.FluentThemeData(
              brightness: Brightness.light,
              accentColor: fluent.Colors.blue,
              fontFamily: 'Inter',
              visualDensity: VisualDensity.standard,
            ),
            darkTheme: fluent.FluentThemeData(
              brightness: Brightness.dark,
              accentColor: fluent.Colors.blue,
              fontFamily: 'Inter',
              visualDensity: VisualDensity.standard,
            ),
            routerConfig: routerConfig,
            builder: (context, child) => ConnectionGuard(child: child!),
          );
        },
      );
    }

    // ── All other platforms: keep existing Material app ─────────────────────
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
