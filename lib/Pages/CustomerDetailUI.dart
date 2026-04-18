import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Models/Customer_Model.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:prime_invoice/Helper/pdf_helper.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Essentials/KTable.dart';

class CustomerDetailUI extends StatefulWidget {
  final CustomerModel customer;
  const CustomerDetailUI({super.key, required this.customer});

  @override
  State<CustomerDetailUI> createState() => _CustomerDetailUIState();
}

class _CustomerDetailUIState extends State<CustomerDetailUI> {
  List<InvoiceModel> purchaseHistory = [];
  double totalSpend = 0;
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    isLoading.value = true;
    try {
      final invoices = await DatabaseService.instance.getInvoicesByCustomer(
        widget.customer.name,
        widget.customer.phone,
      );
      double total = 0;
      for (var inv in invoices) {
        total += inv.grandTotal;
      }
      if (mounted) {
        setState(() {
          purchaseHistory = invoices;
          totalSpend = total;
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "Customer Overview"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: [
                _buildInfoCard(),
                _buildHistoryHeader(),
                _buildHistoryList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return KCard(
      padding: const EdgeInsets.all(24),
      radius: 20,
      color: kColor(context).primaryContainer.withAlpha(20),
      borderColor: kColor(context).primary.withAlpha(50),
      borderWidth: 1,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: kColor(context).primary,
                  shape: BoxShape.rectangle,
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.user,
                    color: kColor(context).onPrimary,
                    size: 32,
                  ),
                ),
              ),
              width20,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Label(widget.customer.name, fontSize: 24, weight: 800).title,
                    Label(
                      widget.customer.phone,
                      fontSize: 16,
                      color: kColor(context).onSurfaceVariant,
                    ).regular,
                  ],
                ),
              ),
              _buildStatCard("Total Spend", kCurrencyFormat(totalSpend)),
            ],
          ),
          if (widget.customer.address.isNotEmpty || widget.customer.gst.isNotEmpty) ...[
            const Divider(height: 48),
            Row(
              children: [
                if (widget.customer.address.isNotEmpty)
                  Expanded(
                    child: _infoItem(LucideIcons.mapPin, "Address", widget.customer.address),
                  ),
                if (widget.customer.gst.isNotEmpty)
                  Expanded(
                    child: _infoItem(LucideIcons.fingerprint, "GST Number", widget.customer.gst),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: kColor(context).surface,
        borderRadius: kRadius(16),
        border: Border.all(color: kColor(context).outlineVariant),
      ),
      child: Column(
        children: [
          Label(label, fontSize: 12, color: kColor(context).onSurfaceVariant).regular,
          Label(value, fontSize: 20, weight: 800, color: kColor(context).primary).title,
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: kColor(context).primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Label(label, fontSize: 12, color: kColor(context).onSurfaceVariant).regular,
              Label(value, fontSize: 14, weight: 500).regular,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Label("Purchase History", fontSize: 18, weight: 700).title,
        Label(
          "${purchaseHistory.length} Invoices",
          fontSize: 14,
          color: kColor(context).onSurfaceVariant,
        ).regular,
      ],
    );
  }

  Widget _buildHistoryList() {
    if (purchaseHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(LucideIcons.shoppingCart,
                  size: 48, color: kColor(context).outlineVariant),
              height15,
              Label("No purchases yet", color: kColor(context).onSurfaceVariant)
                  .regular,
            ],
          ),
        ),
      );
    }

    if (Responsive.isMobile(context)) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: purchaseHistory.length,
        separatorBuilder: (context, index) => height15,
        itemBuilder: (context, index) {
          final inv = purchaseHistory[index];
          return KCard(
            padding: const EdgeInsets.all(16),
            borderWidth: 1,
            borderColor: kColor(context).outlineVariant,
            onTap: () => PdfHelper.generateInvoice(inv),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kColor(context).surfaceContainerHigh,
                    borderRadius: kRadius(10),
                  ),
                  child: Icon(LucideIcons.fileText,
                      size: 20, color: kColor(context).primary),
                ),
                width15,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Label(inv.invoiceId, fontSize: 15, weight: 600).regular,
                      Label(
                        DateFormat('dd MMM yyyy')
                            .format(inv.invoiceDate ?? DateTime.now()),
                        fontSize: 12,
                        color: kColor(context).onSurfaceVariant,
                      ).regular,
                    ],
                  ),
                ),
                Label(
                  kCurrencyFormat(inv.grandTotal),
                  fontSize: 16,
                  weight: 800,
                ).title,
                width15,
                Icon(LucideIcons.eye,
                    size: 16, color: kColor(context).onSurfaceVariant),
              ],
            ),
          );
        },
      );
    }

    return KTable(
      showCheckboxColumn: false,
      columns: [
        KTableColumn(label: Label("DATE", weight: 700).regular),
        KTableColumn(label: Label("INVOICE ID", weight: 700).regular),
        KTableColumn(label: Label("TOTAL AMOUNT", weight: 700).regular),
        KTableColumn(label: Label("ACTION", weight: 700).regular),
      ],
      rows: purchaseHistory.map((inv) {
        return KTableRow(
          cells: [
            Label(DateFormat('dd MMM yyyy')
                    .format(inv.invoiceDate ?? DateTime.now()))
                .regular,
            Label(inv.invoiceId, weight: 700, color: kColor(context).primary)
                .regular,
            Label(kCurrencyFormat(inv.grandTotal), weight: 800).regular,
            IconButton(
              onPressed: () => PdfHelper.generateInvoice(inv),
              icon: Icon(LucideIcons.eye,
                  size: 18, color: kColor(context).primary),
            ),
          ],
        );
      }).toList(),
    );
  }
}
