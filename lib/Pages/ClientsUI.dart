import 'package:flutter/material.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Helper/responsive.dart';

class ClientsUI extends StatefulWidget {
  const ClientsUI({super.key});

  @override
  State<ClientsUI> createState() => _ClientsUIState();
}

class _ClientsUIState extends State<ClientsUI> {
  List<Map<String, String>> clients = [];
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    isLoading.value = true;
    final invoices = await DatabaseService.instance.getAllInvoices();
    final uniqueClients = <String, String>{};
    for (var inv in invoices) {
      if (!uniqueClients.containsKey(inv.customerName)) {
        uniqueClients[inv.customerName] = inv.customerPhone;
      }
    }
    setState(() {
      clients = uniqueClients.entries
          .map((e) => {"name": e.key, "phone": e.value})
          .toList();
    });
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "Client Directory"),
      body: clients.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 40,
                    color: kColor(context).onSurfaceVariant,
                  ),
                  height10,
                  Label(
                    "No clients found",
                    color: kColor(context).onSurfaceVariant,
                  ).regular,
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Responsive.isMobile(context)
                    ? ListView.separated(
                        primary: true,
                        padding: const EdgeInsets.all(kPadding),
                        itemCount: clients.length,
                        separatorBuilder: (context, index) => height15,
                        itemBuilder: (context, index) =>
                            _buildClientCard(clients[index]),
                      )
                    : GridView.builder(
                        primary: true,
                        padding: const EdgeInsets.all(kPadding),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              mainAxisExtent: 100,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                        itemCount: clients.length,
                        itemBuilder: (context, index) =>
                            _buildClientCard(clients[index]),
                      ),
              ),
            ),
    );
  }

  Widget _buildClientCard(Map<String, String> client) {
    return KCard(
      padding: const EdgeInsets.all(15),
      color: kColor(context).surface,
      borderWidth: 1,
      borderColor: kColor(context).outlineVariant,
      radius: 15,
      child: Row(
        children: [
          KCard(
            radius: 50,
            height: 50,
            width: 50,
            padding: EdgeInsets.zero,
            color: kColor(context).primaryContainer,
            child: Center(
              child: Icon(
                LucideIcons.user,
                size: 20,
                color: kColor(context).onPrimaryContainer,
              ),
            ),
          ),
          width15,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Label(
                  client["name"] ?? "Unknown",
                  fontSize: 16,
                  weight: 600,
                ).regular,
                Label(
                  client["phone"] ?? "No phone",
                  fontSize: 12,
                  color: kColor(context).onSurfaceVariant,
                ).regular,
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            size: 16,
            color: kColor(context).onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
