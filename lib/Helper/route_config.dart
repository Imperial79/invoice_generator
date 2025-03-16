import 'package:go_router/go_router.dart';
import 'package:invoice_generator/Pages/Create_InvoiceUI.dart';
import '../Pages/HomeUI.dart';

final routerConfig = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => HomeUI(),
    ),
    GoRoute(
      path: "/create-invoice",
      builder: (context, state) => CreateInvoiceUI(),
    )
  ],
);
