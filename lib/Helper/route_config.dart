import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prime_invoice/Pages/Create_InvoiceUI.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Pages/ClientsUI.dart';
import 'package:prime_invoice/Pages/CompanyProfileUI.dart';
import 'package:prime_invoice/Pages/InvoicesListUI.dart';
import 'package:prime_invoice/Pages/SetupUI.dart';
import 'package:prime_invoice/JewelleryApp/Screens/MainShellUI.dart';
import 'package:prime_invoice/JewelleryApp/Screens/PinLoginUI.dart';
import 'package:prime_invoice/JewelleryApp/Theme.dart';
import '../Pages/HomeUI.dart';

final routerConfig = GoRouter(
  initialLocation: '/login', // App now starts with the PIN security screen
  routes: [
    // ShellRoute for the new Jewellery / Inventory centered UI
    ShellRoute(
      builder: (context, state, child) => Theme(
        data: JewelleryTheme.lightTheme(context),
        child: child,
      ),
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const MainShellUI(),
        ),
        GoRoute(
          path: "/old-home",
          builder: (context, state) => const HomeUI(),
        ),
        GoRoute(
          path: "/invoices",
          builder: (context, state) => const InvoicesListUI(),
        ),
        GoRoute(
          path: "/clients",
          builder: (context, state) => const ClientsUI(),
        ),
        GoRoute(path: "/setup", builder: (context, state) => const SetupUI()),
        GoRoute(
          path: "/company-profile",
          builder: (context, state) => const CompanyProfileUI(),
        ),
      ],
    ),
    
    // Security Login Gate
    GoRoute(
      path: "/login",
      builder: (context, state) => Theme(
        data: JewelleryTheme.lightTheme(context),
        child: const PinLoginUI(),
      ),
    ),
    
    GoRoute(
      path: "/create-invoice",
      builder: (context, state) => Theme(
        data: JewelleryTheme.lightTheme(context),
        child: CreateInvoiceUI(
          invoice: state.extra is InvoiceModel ? state.extra as InvoiceModel : null,
        ),
      ),
    ),
  ],
);
