import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Helper/pdf_helper.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Helper/responsive.dart';

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
    final results = await DatabaseService.instance.getAllInvoices();
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
                  Label(
                    "No invoices found",
                    color: kColor(context).onSurfaceVariant,
                  ).regular,
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Responsive.isMobile(context)
                    ? ListView.separated(
                        primary: true,
                        padding: const EdgeInsets.all(kPadding),
                        itemCount: invoices.length,
                        separatorBuilder: (context, index) => height15,
                        itemBuilder: (context, index) =>
                            _buildInvoiceCard(invoices[index]),
                      )
                    : GridView.builder(
                        primary: true,
                        padding: const EdgeInsets.all(kPadding),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 500,
                              mainAxisExtent: 130,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) =>
                            _buildInvoiceCard(invoices[index]),
                      ),
              ),
            ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Label(invoice.invoiceId, fontSize: 16, weight: 600).regular,
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                          setState(
                            () => loadingInvoiceIds.remove(invoice.invoiceId),
                          );
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
                          setState(
                            () => loadingInvoiceIds.remove(invoice.invoiceId),
                          );
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
