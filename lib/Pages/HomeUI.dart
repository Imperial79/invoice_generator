import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';
import 'package:prime_invoice/Helper/pdf_helper.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:intl/intl.dart';
import 'package:prime_invoice/Helper/responsive.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  final Set<String> loadingInvoiceIds = {};
  List<InvoiceModel> recentInvoices = [];
  double totalInvoicedNum = 0;
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      final invoices = await DatabaseService.instance.getAllInvoices();
      double total = 0;
      double todayTotal = 0;
      final now = DateTime.now();

      for (var inv in invoices) {
        total += inv.grandTotal;
        final invDate = inv.invoiceDate ?? DateTime.now();
        if (invDate.year == now.year &&
            invDate.month == now.month &&
            invDate.day == now.day) {
          todayTotal += inv.grandTotal;
        }
      }

      if (mounted) {
        setState(() {
          recentInvoices = invoices.take(5).toList();
          totalInvoicedNum = total;
          todaySales = todayTotal;
          totalOrders = invoices.length;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  double todaySales = 0;
  int totalOrders = 0;
  int lowStockCount = 3; // Mock low stock count for now

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          primary: true,
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNTFSNotice(),
              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      if (Responsive.isMobile(context)) ...[
                        _buildQuickActions(),
                        _buildRecentInvoicesHeader(),
                        _buildRecentInvoicesList(),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildQuickActions()),
                            const SizedBox(width: 30),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRecentInvoicesHeader(),
                                  _buildRecentInvoicesList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNTFSNotice() {
    return ValueListenableBuilder<bool>(
      valueListenable: DatabaseService.hasWriteIssue,
      builder: (context, hasIssue, _) {
        if (!hasIssue || Responsive.isMobile(context)) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(25),
            borderRadius: kRadius(12),
            border: Border.all(color: Colors.red.withAlpha(80)),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.triangleAlert,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Label(
                  "Drive '${DatabaseService.driveName}' is Read-Only (NTFS). Data is being saved to Local Storage instead.",
                  color: Colors.red,
                  fontSize: 12,
                  weight: 600,
                ).regular,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.isMobile(context)
          ? 1
          : MediaQuery.of(context).size.width > 1400
          ? 3
          : 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: Responsive.isMobile(context) ? 1.6 : 1.4,
      children: [
        _summaryCard(
          "Today's Sales",
          kCurrencyFormat(todaySales),
          LucideIcons.indianRupee,
          Colors.green,
        ),
        _summaryCard(
          "Total Orders",
          totalOrders.toString(),
          LucideIcons.shoppingBag,
          Colors.blue,
        ),
        _summaryCard(
          "Low Stock Alerts",
          lowStockCount.toString(),
          LucideIcons.info,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label(
              "Welcome back,",
              fontSize: 14,
              color: kColor(context).onSurfaceVariant,
            ).regular,
            Label(
              "Shri Krishn Jewellers",
              fontSize: Responsive.isMobile(context) ? 24 : 32,
              weight: 700,
            ).title,
            const SizedBox(height: 5),
            ValueListenableBuilder<String>(
              valueListenable: DatabaseService.storageType,
              builder: (context, type, _) {
                final isPortable = type == "Portable Drive";
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isPortable ? Colors.green : Colors.orange)
                        .withAlpha(40),
                    borderRadius: kRadius(20),
                    border: Border.all(
                      color: (isPortable ? Colors.green : Colors.orange)
                          .withAlpha(80),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPortable ? LucideIcons.usb : LucideIcons.hardDrive,
                        size: 12,
                        color: isPortable ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Label(
                        type,
                        fontSize: 10,
                        weight: 600,
                        color: isPortable ? Colors.green : Colors.orange,
                      ).regular,
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        KCard(
          onTap: () => context.push("/setup"),
          radius: 50,
          padding: const EdgeInsets.all(10),
          color: kColor(context).primaryContainer,
          child: Icon(
            LucideIcons.user,
            color: kColor(context).onPrimaryContainer,
            size: Responsive.isMobile(context) ? 24 : 30,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return KCard(
      padding: const EdgeInsets.all(24),
      color: kColor(context).surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: kRadius(16),
              border: Border.all(color: color.withAlpha(40)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Label(
                value,
                fontSize: 26,
                weight: 900,
                color: kColor(context).onSurface,
              ).title,
              const SizedBox(height: 4),
              Label(
                title,
                fontSize: 13,
                weight: 500,
                color: kColor(context).onSurfaceVariant,
              ).regular,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label("Quick Actions", fontSize: 18, weight: 600).title,
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: Responsive.isMobile(context) ? 1.4 : 1.2,
          ),
          children: [
            _actionButton(LucideIcons.filePlus2, "Create Bill", () async {
              final res = await context.push("/create-invoice");
              if (res == true) _loadData();
            }, color: kColor(context).primary),
            _actionButton(
              LucideIcons.userPlus,
              "Add Customer",
              () => context.push("/clients"),
              color: Colors.blueGrey,
            ),
            _actionButton(LucideIcons.packagePlus, "Add Inventory", () {
              context.push("/inventory");
            }, color: Colors.brown),
            _actionButton(LucideIcons.layoutPanelTop, "Reports", () {
              context.go("/reports");
            }, color: Colors.indigo),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    required Color color,
  }) {
    return KCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      color: kColor(context).surfaceContainerLow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              shape: BoxShape.rectangle,
              border: Border.all(color: color.withAlpha(30)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Label(
            label,
            fontSize: 13,
            weight: 700,
            textAlign: TextAlign.center,
          ).regular,
        ],
      ),
    );
  }

  Widget _buildRecentInvoicesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Label("Recent Invoices", fontSize: 18, weight: 600).title,
        TextButton(
          onPressed: () => context.push("/invoices"),
          child: Label(
            "See All",
            color: kColor(context).primary,
            fontSize: 14,
          ).regular,
        ),
      ],
    );
  }

  Widget _buildRecentInvoicesList() {
    if (recentInvoices.isEmpty) {
      return KCard(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        color: kColor(context).surfaceContainerLow,
        borderWidth: 1,
        borderColor: kColor(context).outlineVariant,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Icon(
              LucideIcons.inbox,
              size: 40,
              color: kColor(context).onSurfaceVariant,
            ),
            Label(
              "No invoices found",
              color: kColor(context).onSurfaceVariant,
            ).regular,
          ],
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentInvoices.length,
      separatorBuilder: (context, index) => height15,
      itemBuilder: (context, index) {
        final invoice = recentInvoices[index];
        return KCard(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 12),
          color: kColor(context).surfaceContainerLow,
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: kColor(context).primary.withAlpha(15),
                  borderRadius: kRadius(16),
                  border: Border.all(color: kColor(context).primary.withAlpha(30)),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.fileText,
                    size: 20,
                    color: kColor(context).primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Label(invoice.invoiceId, fontSize: 16, weight: 700).regular,
                    const SizedBox(height: 4),
                    Label(
                      "${invoice.customerName} • ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate ?? DateTime.now())}",
                      fontSize: 12,
                      color: kColor(context).onSurfaceVariant,
                    ).regular,
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Label(
                    kCurrencyFormat(invoice.grandTotal),
                    fontSize: 18,
                    weight: 900,
                    color: kColor(context).primary,
                  ).title,
                  const SizedBox(height: 10),
                  if (!loadingInvoiceIds.contains(invoice.invoiceId))
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
                        const SizedBox(width: 8),
                        _actionIcon(
                          LucideIcons.pencil,
                          kColor(context).secondary,
                          () async {
                            final res = await context.push("/create-invoice", extra: invoice);
                            if (res == true) _loadData();
                          },
                        ),
                        const SizedBox(width: 8),
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
                    )
                  else
                    const SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
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
          color: color.withAlpha(25),
          borderRadius: kRadius(8),
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
