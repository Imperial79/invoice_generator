import 'package:flutter/material.dart';
import 'package:invoice_generator/Helper/route_config.dart';
import 'package:invoice_generator/Resources/commons.dart';
import 'package:invoice_generator/Resources/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
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
