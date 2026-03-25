import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invoice_generator/Essentials/Label.dart';
import 'package:invoice_generator/Resources/commons.dart';
import 'package:invoice_generator/Resources/constants.dart';
import 'package:invoice_generator/Essentials/KScaffold.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:invoice_generator/Essentials/kCard.dart';
import 'package:invoice_generator/Helper/database_helper.dart';
import 'package:invoice_generator/Models/Invoice_Model.dart';
import 'package:invoice_generator/Helper/pdf_helper.dart';
import 'package:invoice_generator/Resources/colors.dart';
import 'package:intl/intl.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  final Set<String> loadingInvoiceIds = {};
  List<InvoiceModel> recentInvoices = [];
  double totalInvoicedNum = 0;
  double pendingAmountNum = 0;
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    final invoices = await DatabaseHelper.instance.getAllInvoices();
    double total = 0;
    for (var inv in invoices) {
      total += inv.grandTotal;
    }
    setState(() {
      recentInvoices = invoices.take(5).toList();
      totalInvoicedNum = total;
      // For demo, let's say 30% is pending if no status field exists yet
      pendingAmountNum = total * 0.3;
    });
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              _buildHeader(),
              _buildActions(),
              _buildRecentInvoicesHeader(),
              _buildRecentInvoicesList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push("/create-invoice");
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(LucideIcons.plus),
        elevation: 0,
        backgroundColor: Kolor.primary,
        foregroundColor: Colors.white,
        label: Label("New Invoice").regular,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label("Welcome back,", fontSize: 14, color: Kolor.fadeText).regular,
            Label("Sujit Verma", fontSize: 24, weight: 700).title,
          ],
        ),
        KCard(
          radius: 50,
          padding: const EdgeInsets.all(10),
          color: Kolor.primary.withValues(alpha: .1),
          child: const Icon(LucideIcons.user, color: Kolor.primary),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 12,
        children: [
          _actionButton(
            LucideIcons.plus,
            "Create",
            () async {
              final res = await context.push("/create-invoice");
              if (res == true) _loadData();
            },
            bgColor: Kolor.primary,
            fgColor: Kolor.card,
          ),
          _actionButton(LucideIcons.download, "Report", () {
            KSnackbar(
              context,
              message:
                  "Report generated for $totalInvoicedNum in current session.",
            );
          }),
          _actionButton(
            LucideIcons.users,
            "Clients",
            () => context.push("/clients"),
          ),
          _actionButton(
            LucideIcons.settings,
            "Setup",
            () => context.push("/setup"),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? bgColor,
    Color? fgColor,
  }) {
    return Column(
      spacing: 5,
      children: [
        KCard(
          radius: 12,
          padding: const EdgeInsets.all(12),
          color: bgColor ?? Kolor.card,
          borderWidth: 1,
          borderColor: Kolor.border,
          onTap: onTap,
          child: Icon(icon, size: 20, color: fgColor ?? Kolor.secondary),
        ),
        Label(label, fontSize: 12).regular,
      ],
    );
  }

  Widget _buildRecentInvoicesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Label("Recent Invoices", fontSize: 18, weight: 600).title,
        TextButton(
          onPressed: () => context.push("/invoices"),
          child: Label("See All", color: Kolor.primary, fontSize: 14).regular,
        ),
      ],
    );
  }

  Widget _buildRecentInvoicesList() {
    if (recentInvoices.isEmpty) {
      return KCard(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        color: Kolor.card.withValues(alpha: .5),
        borderWidth: 1,
        borderColor: Kolor.border,
        child: Column(
          spacing: 10,
          children: [
            const Icon(LucideIcons.inbox, size: 40, color: Kolor.fadeText),
            Label("No invoices found", color: Kolor.fadeText).regular,
          ],
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentInvoices.length,
      separatorBuilder: (context, index) => height15,
      itemBuilder: (context, index) {
        final invoice = recentInvoices[index];
        return KCard(
          padding: const EdgeInsets.all(15),
          color: Kolor.scaffold,
          borderWidth: 1,
          borderColor: Kolor.border,
          radius: 15,
          child: Row(
            spacing: 15,
            children: [
              KCard(
                radius: 10,
                height: 50,
                width: 50,
                padding: EdgeInsets.zero,
                color: Kolor.primary.withValues(alpha: .05),
                child: Center(
                  child: Label("PDF", fontSize: 10, color: Kolor.primary).title,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Label(invoice.invoiceId, fontSize: 16, weight: 600).regular,
                    Label(
                      "${invoice.customerName} - ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate ?? DateTime.now())}",
                      fontSize: 12,
                      color: Kolor.fadeText,
                    ).regular,
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  Label(
                    kCurrencyFormat(invoice.grandTotal),
                    fontSize: 16,
                    weight: 700,
                  ).title,
                  if (!loadingInvoiceIds.contains(invoice.invoiceId))
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        _actionIcon(
                          LucideIcons.eye,
                          Kolor.primary,
                          () async {
                            setState(
                              () => loadingInvoiceIds.add(invoice.invoiceId),
                            );
                            try {
                              await PdfHelper.generateInvoice(invoice);
                            } finally {
                              if (mounted) {
                                setState(
                                  () => loadingInvoiceIds.remove(
                                    invoice.invoiceId,
                                  ),
                                );
                              }
                            }
                          },
                          isLoading: loadingInvoiceIds.contains(
                            invoice.invoiceId,
                          ),
                        ),
                        _actionIcon(
                          LucideIcons.pencil,
                          Kolor.secondary,
                          () async {
                            final res = await context.push(
                              "/create-invoice",
                              extra: invoice,
                            );
                            if (res == true) _loadData();
                          },
                        ),
                        _actionIcon(
                          LucideIcons.share2,
                          StatusText.success,
                          () async {
                            setState(
                              () => loadingInvoiceIds.add(invoice.invoiceId),
                            );
                            try {
                              await PdfHelper.shareInvoice(invoice);
                            } finally {
                              if (mounted) {
                                setState(
                                  () => loadingInvoiceIds.remove(
                                    invoice.invoiceId,
                                  ),
                                );
                              }
                            }
                          },
                          isLoading: loadingInvoiceIds.contains(
                            invoice.invoiceId,
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(width: 50, child: LinearProgressIndicator()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionIcon(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Icon(icon, size: 16, color: color),
      ),
    );
  }
}
