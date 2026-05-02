import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prime_invoice/Helper/route_config.dart';
import 'package:prime_invoice/Resources/theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:prime_invoice/Essentials/ConnectionGuard.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

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
