import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:prime_invoice/Resources/constants.dart';
import '../Theme.dart';
import '../Widgets/JewelleryCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Models/Invoice_Model.dart';

class DashboardUI extends StatefulWidget {
  const DashboardUI({super.key});

  @override
  State<DashboardUI> createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI> {
  List<InvoiceModel> recentInvoices = [];
  double totalInvoicedNum = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final invoices = await DatabaseService.instance.getAllInvoices();
      double total = 0;
      for (var inv in invoices) {
        total += inv.grandTotal;
      }
      if (mounted) {
        setState(() {
          recentInvoices = invoices.take(5).toList();
          totalInvoicedNum = total;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("DASHBOARD"),
        automaticallyImplyLeading: false, // Shell handles navigation
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(LucideIcons.refreshCw, size: 20),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 18,
            backgroundColor: JewelleryTheme.gold,
            child: Icon(LucideIcons.user, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: JewelleryTheme.gold),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back, Administrator",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            "Business Summary: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : JewelleryTheme.slate,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.plus, size: 18),
                        label: const Text("NEW SALE"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Summary Cards with Real Data
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      return GridView.count(
                        crossAxisCount: isWide ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: isWide ? 1.6 : 1.4,
                        children: [
                          _summaryCard(
                            "Total Revenue",
                            kCurrencyFormat(totalInvoicedNum),
                            LucideIcons.indianRupee,
                            JewelleryTheme.gold,
                            "All-time total",
                          ),
                          _summaryCard(
                            "Recent Orders",
                            recentInvoices.length.toString(),
                            LucideIcons.shoppingCart,
                            JewelleryTheme.gold,
                            "Last 5 transactions",
                          ),
                          _summaryCard(
                            "Inventory Status",
                            "Good",
                            LucideIcons.box,
                            Colors.green,
                            "Regularly updated",
                          ),
                          _summaryCard(
                            "Low Stock",
                            "3 Items",
                            LucideIcons.circleAlert,
                            JewelleryTheme.error,
                            "Needs attention",
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 48),

                  // Quick Actions & Recent Transactions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Transactions List (Real Data)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recent Transactions",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            JewelleryCard(
                              padding: EdgeInsets.zero,
                              child: recentInvoices.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(40.0),
                                      child: Center(
                                        child: Text(
                                          "No transactions yet",
                                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        for (
                                          var i = 0;
                                          i < recentInvoices.length;
                                          i++
                                        ) ...[
                                          _transactionItem(
                                            recentInvoices[i].invoiceId,
                                            recentInvoices[i].customerName,
                                            "Invoice #${recentInvoices[i].invoiceId}",
                                            kCurrencyFormat(
                                              recentInvoices[i].grandTotal,
                                            ),
                                            "PAID",
                                          ),
                                          if (i < recentInvoices.length - 1)
                                            const Divider(height: 1),
                                        ],
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),

                      // Quick Access sidebar
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quick Actions",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            JewelleryCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _quickActionButton(
                                    LucideIcons.userPlus,
                                    "Add Customer",
                                  ),
                                  const SizedBox(height: 12),
                                  _quickActionButton(
                                    LucideIcons.packagePlus,
                                    "Add Inventory",
                                  ),
                                  const SizedBox(height: 12),
                                  _quickActionButton(
                                    LucideIcons.trendingUp,
                                    "Sales Report",
                                  ),
                                  const SizedBox(height: 12),
                                  _quickActionButton(
                                    LucideIcons.settings2,
                                    "POS Settings",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(
    String title,
    String val,
    IconData icon,
    Color color,
    String sub,
  ) {
    final theme = Theme.of(context);
    return JewelleryCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            val,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(
    String id,
    String user,
    String item,
    String price,
    String status,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        user, 
        style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
      ),
      subtitle: Text(
        item,
        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.w700, 
              fontSize: 13,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton(IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? theme.scaffoldBackgroundColor : JewelleryTheme.cream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: JewelleryTheme.gold),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
