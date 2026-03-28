import 'package:go_router/go_router.dart';
import 'package:prime_invoice/Pages/Create_InvoiceUI.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Pages/ClientsUI.dart';
import 'package:prime_invoice/Pages/CompanyProfileUI.dart';
import 'package:prime_invoice/Pages/InvoicesListUI.dart';
import 'package:prime_invoice/Pages/SetupUI.dart';
import '../Pages/HomeUI.dart';

final routerConfig = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => HomeUI()),
    GoRoute(
      path: "/create-invoice",
      builder: (context, state) => CreateInvoiceUI(
        invoice: state.extra is InvoiceModel
            ? state.extra as InvoiceModel
            : null,
      ),
    ),
    GoRoute(
      path: "/invoices",
      builder: (context, state) => const InvoicesListUI(),
    ),
    GoRoute(path: "/clients", builder: (context, state) => const ClientsUI()),
    GoRoute(path: "/setup", builder: (context, state) => const SetupUI()),
    GoRoute(
      path: "/company-profile",
      builder: (context, state) => const CompanyProfileUI(),
    ),
  ],
);
