import 'package:go_router/go_router.dart';
import 'package:prime_invoice/Pages/Create_InvoiceUI.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Pages/ClientsUI.dart';
import 'package:prime_invoice/Pages/CompanyProfileUI.dart';
import 'package:prime_invoice/Pages/InvoicesListUI.dart';
import 'package:prime_invoice/Pages/SetupUI.dart';
import 'package:prime_invoice/Pages/RootUI.dart';
import 'package:prime_invoice/Pages/LoginUI.dart';
import 'package:prime_invoice/Pages/InventoryUI.dart';
import 'package:prime_invoice/Pages/MetalRatesUI.dart';
import 'package:prime_invoice/Pages/GstSettingsUI.dart';
import 'package:prime_invoice/Pages/ReportsUI.dart';
import '../Pages/HomeUI.dart';

final routerConfig = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: "/login", builder: (context, state) => const LoginUI()),
    ShellRoute(
      builder: (context, state, child) => RootUI(child: child),
      routes: [
        GoRoute(path: "/", builder: (context, state) => const HomeUI()),
        GoRoute(
          path: "/invoices",
          builder: (context, state) => const InvoicesListUI(),
        ),
        GoRoute(
          path: "/clients",
          builder: (context, state) => const ClientsUI(),
        ),
        GoRoute(
          path: "/inventory",
          builder: (context, state) => const InventoryUI(),
        ),
        GoRoute(path: "/setup", builder: (context, state) => const SetupUI()),
        GoRoute(
          path: "/company-profile",
          builder: (context, state) => const CompanyProfileUI(),
        ),
        GoRoute(
          path: "/metal-rates",
          builder: (context, state) => const MetalRatesUI(),
        ),
        GoRoute(
          path: "/gst-settings",
          builder: (context, state) => const GstSettingsUI(),
        ),
        GoRoute(
          path: "/create-invoice",
          builder: (context, state) => CreateInvoiceUI(
            invoice: state.extra is InvoiceModel
                ? state.extra as InvoiceModel
                : null,
          ),
        ),
        GoRoute(
          path: "/reports",
          builder: (context, state) => const ReportsUI(),
        ),
      ],
    ),
  ],
);
