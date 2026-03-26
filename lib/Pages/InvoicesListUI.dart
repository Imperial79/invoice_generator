import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:invoice_generator/Essentials/KScaffold.dart';
import 'package:invoice_generator/Essentials/Label.dart';
import 'package:invoice_generator/Essentials/kCard.dart';
import 'package:invoice_generator/Helper/database_helper.dart';
import 'package:invoice_generator/Helper/pdf_helper.dart';
import 'package:invoice_generator/Models/Invoice_Model.dart';
import 'package:invoice_generator/Resources/colors.dart';
import 'package:invoice_generator/Resources/commons.dart';
import 'package:invoice_generator/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InvoicesListUI extends StatefulWidget {
  const InvoicesListUI({super.key});

  @override
  State<InvoicesListUI> createState() => _InvoicesListUIState();
}

class _InvoicesListUIState extends State<InvoicesListUI> {
  final Set<String> loadingInvoiceIds = {};
  List<InvoiceModel> invoices = [];
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    isLoading.value = true;
    final results = await DatabaseHelper.instance.getAllInvoices();
    setState(() {
      invoices = results;
    });
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "All Invoices"),
      body: invoices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.inbox,
                    size: 40,
                    color: kColor(context).onSurfaceVariant,
                  ),
                  height10,
                  Label("No invoices found", color: kColor(context).onSurfaceVariant).regular,
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(kPadding),
              itemCount: invoices.length,
              separatorBuilder: (context, index) => height15,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return KCard(
                  padding: const EdgeInsets.all(15),
                  color: kColor(context).surface,
                  borderWidth: 1,
                  borderColor: kColor(context).outlineVariant,
                  radius: 15,
                  child: Row(
                    children: [
                      KCard(
                        radius: 10,
                        height: 50,
                        width: 50,
                        padding: EdgeInsets.zero,
                        color: kColor(context).primaryContainer,
                        child: Center(
                          child: Label(
                            "PDF",
                            fontSize: 10,
                            color: kColor(context).onPrimaryContainer,
                          ).title,
                        ),
                      ),
                      width15,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Label(
                              invoice.invoiceId,
                              fontSize: 16,
                              weight: 600,
                            ).regular,
                            Label(
                              "${invoice.customerName} - ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate ?? DateTime.now())}",
                              fontSize: 12,
                              color: kColor(context).onSurfaceVariant,
                            ).regular,
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Label(
                            kCurrencyFormat(invoice.grandTotal),
                            fontSize: 16,
                            weight: 700,
                          ).title,
                          height10,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _actionIcon(
                                LucideIcons.eye,
                                kColor(context).primary,
                                () async {
                                  setState(() => loadingInvoiceIds.add(invoice.invoiceId));
                                  try {
                                    await PdfHelper.generateInvoice(invoice);
                                  } finally {
                                    if (mounted) {
                                      setState(() => loadingInvoiceIds.remove(invoice.invoiceId));
                                    }
                                  }
                                },
                                isLoading: loadingInvoiceIds.contains(invoice.invoiceId),
                              ),
                              width10,
                              _actionIcon(
                                LucideIcons.pencil,
                                kColor(context).secondary,
                                () async {
                                  final res = await context.push(
                                    "/create-invoice",
                                    extra: invoice,
                                  );
                                  if (res == true) _loadInvoices();
                                },
                              ),
                              width10,
                              _actionIcon(
                                LucideIcons.share2,
                                kColor(context).tertiary,
                                () async {
                                  setState(() => loadingInvoiceIds.add(invoice.invoiceId));
                                  try {
                                    await PdfHelper.shareInvoice(invoice);
                                  } finally {
                                    if (mounted) {
                                      setState(() => loadingInvoiceIds.remove(invoice.invoiceId));
                                    }
                                  }
                                },
                                isLoading: loadingInvoiceIds.contains(invoice.invoiceId),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap, {bool isLoading = false}) {
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
