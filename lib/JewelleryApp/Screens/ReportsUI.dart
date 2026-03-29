import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../Theme.dart';
import '../Widgets/JewelleryCard.dart';

class ReportsUI extends StatelessWidget {
  const ReportsUI({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("SALES & ANALYTICS"),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: Icon(LucideIcons.download, size: 20, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Sales Summary
            Row(
              children: [
                _reportStat(context, "Monthly Revenue", "₹12,45,000", "+8%"),
                const SizedBox(width: 24),
                _reportStat(context, "Profit Margin", "32%", "+2%"),
                const SizedBox(width: 24),
                _reportStat(context, "Avg. Order Value", "₹68,400", "-5%"),
              ],
            ),
            const SizedBox(height: 32),

            // Revenue Chart & Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: JewelleryCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sales Performance (Past 7 Days)",
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Icon(
                              LucideIcons.calendar, 
                              size: 20, 
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),

                        // Simple Bar Chart Representation
                        SizedBox(
                          height: 250,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _bar(context, "Mon", 0.4),
                              _bar(context, "Tue", 0.6),
                              _bar(context, "Wed", 0.9),
                              _bar(context, "Thu", 0.5),
                              _bar(context, "Fri", 0.7),
                              _bar(context, "Sat", 1.0),
                              _bar(context, "Sun", 0.3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),

                // Best Sellers
                Expanded(
                  flex: 2,
                  child: JewelleryCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Top Selling Categories",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _sellingItem(context, "Wedding Jewellery", "₹5.4L", 0.8),
                        const SizedBox(height: 24),
                        _sellingItem(context, "Diamond Rings", "₹3.2L", 0.5),
                        const SizedBox(height: 24),
                        _sellingItem(context, "Silverware", "₹1.1L", 0.2),
                        const SizedBox(height: 24),
                        _sellingItem(context, "Gold Coins", "₹0.8L", 0.1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Sales Table
            JewelleryCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: isDark ? theme.colorScheme.surface : theme.scaffoldBackgroundColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "DAILY SALES RECORD", 
                          style: TextStyle(
                            fontWeight: FontWeight.w800, 
                            fontSize: 13, 
                            letterSpacing: 1,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          "MARCH 2026", 
                          style: TextStyle(
                            fontWeight: FontWeight.w500, 
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _tableRow(context, "29 Mar", "18 Sales", "₹2,45,000", "₹72,400"),
                  const Divider(height: 1),
                  _tableRow(context, "28 Mar", "12 Sales", "₹1,85,000", "₹54,200"),
                  const Divider(height: 1),
                  _tableRow(context, "27 Mar", "24 Sales", "₹4,12,000", "₹1,24,000"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportStat(BuildContext context, String label, String val, String trend) {
    final theme = Theme.of(context);
    bool isPositive = trend.startsWith("+");
    return Expanded(
      child: JewelleryCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label, 
              style: TextStyle(
                fontSize: 14, 
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  val, 
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(BuildContext context, String day, double heightFactor) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 200 * heightFactor,
          decoration: BoxDecoration(
            color: JewelleryTheme.gold,
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [JewelleryTheme.gold, JewelleryTheme.gold.withValues(alpha: 0.6)],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          day, 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w700, 
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _sellingItem(BuildContext context, String label, String val, double progress) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label, 
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              val, 
              style: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w800, 
                color: JewelleryTheme.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation(JewelleryTheme.gold),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _tableRow(BuildContext context, String date, String count, String revenue, String profit) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(date, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface))),
          Expanded(child: Center(child: Text(count, style: TextStyle(color: theme.colorScheme.onSurface)))),
          Expanded(child: Center(child: Text(revenue, style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)))),
          Expanded(child: Align(alignment: Alignment.centerRight, child: Text(profit, style: TextStyle(color: Colors.green.shade700)))),
        ],
      ),
    );
  }
}
