import 'package:go_router/go_router.dart';
import 'package:invoice_generator/Pages/Create_InvoiceUI.dart';
import 'package:invoice_generator/Models/Invoice_Model.dart';
import 'package:invoice_generator/Pages/ClientsUI.dart';
import 'package:invoice_generator/Pages/CompanyProfileUI.dart';
import 'package:invoice_generator/Pages/InvoicesListUI.dart';
import 'package:invoice_generator/Pages/SetupUI.dart';
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
