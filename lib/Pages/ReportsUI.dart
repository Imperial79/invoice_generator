import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:intl/intl.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Essentials/KFilterBar.dart';
import 'package:prime_invoice/Essentials/KTable.dart';

class ReportsUI extends StatefulWidget {
  const ReportsUI({super.key});

  @override
  State<ReportsUI> createState() => _ReportsUIState();
}

class _ReportsUIState extends State<ReportsUI> {
  final isLoading = ValueNotifier(false);

  // Data State
  double totalRevenue = 0;
  double metalRevenue = 0;
  double serviceRevenue = 0;
  double totalGst = 0;
  int totalInvoices = 0;

  List<MapEntry<String, double>> topCustomers = [];
  List<MapEntry<String, double>> topProducts = [];
  Map<String, double> monthlySales = {};

  String selectedYear = "All";
  final List<String> years = ["All", "2024", "2025", "2026"];

  @override
  void initState() {
    super.initState();
    _calculateReports();
  }

  Future<void> _calculateReports() async {
    try {
      isLoading.value = true;
      final invoices = await DatabaseService.instance.getAllInvoices();

      double tr = 0;
      double mr = 0;
      double sr = 0;
      double tg = 0;
      int count = 0;

      Map<String, double> customerMap = {};
      Map<String, double> productMap = {};
      Map<String, double> monthlyMap = {};

      for (var inv in invoices) {
        if (selectedYear != "All" && inv.invoiceDate?.year.toString() != selectedYear) continue;

        tr += inv.grandTotal;
        count++;

        // Customer Analytics
        customerMap[inv.customerName] = (customerMap[inv.customerName] ?? 0) + inv.grandTotal;

        // Monthly Analytics
        if (inv.invoiceDate != null) {
          String monthKey = DateFormat('MMM yyyy').format(inv.invoiceDate!);
          monthlyMap[monthKey] = (monthlyMap[monthKey] ?? 0) + inv.grandTotal;
        }

        for (var item in inv.items) {
          mr += item.metalAmount;
          sr += item.serviceAmount;

          double itemMetalGst = (item.metalAmount * item.metalGst) / 100;
          double itemServiceGst = (item.serviceAmount * item.serviceGst) / 100;
          tg += (itemMetalGst + itemServiceGst);

          productMap[item.itemName] = (productMap[item.itemName] ?? 0) + item.qty;
        }
      }

      var sortedCustomers = customerMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      var sortedProducts = productMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      if (mounted) {
        setState(() {
          totalRevenue = tr;
          metalRevenue = mr;
          serviceRevenue = sr;
          totalGst = tg;
          totalInvoices = count;
          topCustomers = sortedCustomers.take(5).toList();
          topProducts = sortedProducts.take(5).toList();
          monthlySales = monthlyMap;
        });
      }
    } catch (e) {
      debugPrint("Error calculating reports: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  KFilterBar(
                    configs: [
                      FilterConfig(
                        id: "year",
                        label: "Filter by Year",
                        options: years,
                        initialValue: selectedYear,
                      ),
                    ],
                    selectedFilters: {"year": selectedYear},
                    onFilterChanged: (id, value) {
                      setState(() {
                        selectedYear = value;
                        _calculateReports();
                      });
                    },
                    onClearAll: () {
                      setState(() {
                        selectedYear = "All";
                        _calculateReports();
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildRevenueOverview(),
                  const SizedBox(height: 32),
                  _buildPerformanceTables(),
                  const SizedBox(height: 32),
                  _buildMonthlyTrends(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceTables() {
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          _buildTopCustomersMobile(),
          const SizedBox(height: 32),
          _buildTopProductsMobile(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Label("Top Customers", fontSize: 18, weight: 700).regular,
              const SizedBox(height: 16),
              KTable(
                headingRowHeight: 50,
                dataRowHeight: 60,
                columns: [
                  KTableColumn(label: Label("CUSTOMER", weight: 700).regular),
                  KTableColumn(label: Label("SPEND", weight: 700).regular, numeric: true),
                  KTableColumn(label: Label("SHARE", weight: 700).regular, numeric: true),
                ],
                rows: topCustomers.map((e) {
                  final percentage = (e.value / (totalRevenue == 0 ? 1 : totalRevenue)) * 100;
                  return KTableRow(cells: [
                    Label(e.key, weight: 600).regular,
                    Label(kCurrencyFormat(e.value)).regular,
                    Label("${percentage.toStringAsFixed(1)}%", color: kColor(context).primary).regular,
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Label("Top Selling Products", fontSize: 18, weight: 700).regular,
              const SizedBox(height: 16),
              KTable(
                headingRowHeight: 50,
                dataRowHeight: 60,
                columns: [
                  KTableColumn(label: Label("PRODUCT", weight: 700).regular),
                  KTableColumn(label: Label("UNITS", weight: 700).regular, numeric: true),
                  KTableColumn(label: Label("STATUS", weight: 700).regular),
                ],
                rows: topProducts.map((e) {
                  return KTableRow(cells: [
                    Label(e.key, weight: 600).regular,
                    Label(e.value.toString()).regular,
                    Label("Trending", color: Colors.orange, weight: 700).regular,
                  ]);
                }).toList(),
              ),
            ],
          ),
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
            Label("Business Insights", fontSize: 32, weight: 800).title,
            const SizedBox(height: 4),
            Label(
              "Comprehensive performance analysis and reporting",
              fontSize: 14,
              color: kColor(context).onSurfaceVariant,
            ).regular,
          ],
        ),
        KCard(
          onTap: _calculateReports,
          padding: const EdgeInsets.all(12),
          color: kColor(context).primaryContainer,
          child: Icon(LucideIcons.refreshCw, size: 20, color: kColor(context).onPrimaryContainer),
        ),
      ],
    );
  }

  Widget _buildRevenueOverview() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.isMobile(context) ? 1 : 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.5,
      children: [
        _statCard("Total Revenue", kCurrencyFormat(totalRevenue), LucideIcons.trendingUp, Colors.green),
        _statCard("Metal Sales", kCurrencyFormat(metalRevenue), LucideIcons.gem, Colors.amber),
        _statCard("Service Income", kCurrencyFormat(serviceRevenue), LucideIcons.settings2, Colors.blue),
        _statCard("Tax Collected", kCurrencyFormat(totalGst), LucideIcons.landmark, Colors.deepPurple),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return KCard(
      padding: const EdgeInsets.all(20),
      color: kColor(context).surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Label(title, fontSize: 12, weight: 500, color: kColor(context).onSurfaceVariant).regular,
            ],
          ),
          const Spacer(),
          Label(value, fontSize: 22, weight: 800).title,
        ],
      ),
    );
  }

  Widget _buildTopCustomersMobile() {
    return KCard(
      padding: const EdgeInsets.all(10),
      color: kColor(context).surfaceContainerLow,
      child: topCustomers.isEmpty
          ? _buildEmptyState("No data available")
          : Column(
              children: topCustomers.map((entry) {
                final percentage = (entry.value / (totalRevenue == 0 ? 1 : totalRevenue)) * 100;
                return _listItem(
                  title: entry.key,
                  subtitle: "Total Spend: ${kCurrencyFormat(entry.value)}",
                  trailing: "${percentage.toStringAsFixed(1)}%",
                  icon: LucideIcons.user,
                  color: Colors.blue,
                );
              }).toList(),
            ),
    );
  }

  Widget _buildTopProductsMobile() {
    return KCard(
      padding: const EdgeInsets.all(10),
      color: kColor(context).surfaceContainerLow,
      child: topProducts.isEmpty
          ? _buildEmptyState("No data available")
          : Column(
              children: topProducts.map((entry) {
                return _listItem(
                  title: entry.key,
                  subtitle: "Units Sold: ${entry.value}",
                  trailing: "Trending",
                  icon: LucideIcons.package,
                  color: Colors.orange,
                );
              }).toList(),
            ),
    );
  }

  Widget _listItem({
    required String title,
    required String subtitle,
    required String trailing,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withAlpha(15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label(title, fontSize: 15, weight: 700).regular,
                Label(subtitle, fontSize: 12, color: kColor(context).onSurfaceVariant).regular,
              ],
            ),
          ),
          Label(trailing, fontSize: 13, weight: 700, color: kColor(context).primary).regular,
        ],
      ),
    );
  }

  Widget _buildMonthlyTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label("Monthly Sales Trend", fontSize: 18, weight: 700).regular,
        const SizedBox(height: 16),
        KCard(
          padding: const EdgeInsets.all(24),
          color: kColor(context).surfaceContainerLow,
          child: monthlySales.isEmpty
              ? _buildEmptyState("No time-series data")
              : SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: monthlySales.entries.map((entry) {
                      final maxVal = monthlySales.values.reduce((a, b) => a > b ? a : b);
                      final hFactor = entry.value / (maxVal == 0 ? 1 : maxVal);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 32,
                            height: 150 * hFactor,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [kColor(context).primary, kColor(context).primary.withAlpha(100)],
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Label(entry.key, fontSize: 10, weight: 600).regular,
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(LucideIcons.chartBar, color: kColor(context).onSurfaceVariant.withAlpha(100), size: 48),
            const SizedBox(height: 16),
            Label(msg, color: kColor(context).onSurfaceVariant).regular,
          ],
        ),
      ),
    );
  }
}
