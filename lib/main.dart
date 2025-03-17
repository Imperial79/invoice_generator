import 'package:flutter/material.dart';
import 'package:invoice_generator/Helper/route_config.dart';
import 'package:invoice_generator/Resources/commons.dart';
import 'package:invoice_generator/Resources/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  systemColors();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Invoice Generator',
        theme: kTheme(context),
        routerConfig: routerConfig);
  }
}
