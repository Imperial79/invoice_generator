import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import '../Theme.dart';
import 'DashboardUI.dart';
import 'POS_BillingUI.dart';
import 'InventoryUI.dart';
import 'ReportsUI.dart';
import '../Controllers/ShellController.dart';
import 'package:prime_invoice/Pages/ClientsUI.dart';
import 'package:prime_invoice/Pages/InvoicesListUI.dart';
import 'package:prime_invoice/Pages/SetupUI.dart';

class MainShellUI extends StatefulWidget {
  const MainShellUI({super.key});

  @override
  State<MainShellUI> createState() => _MainShellUIState();
}

class _MainShellUIState extends State<MainShellUI> with WidgetsBindingObserver {
  final ShellController _shellController = ShellController();

  final List<Widget> _screens = [
    const InventoryUI(),
    const POSBillingUI(),
    const DashboardUI(),
    const InvoicesListUI(),
    const ClientsUI(),
    const SetupUI(),
    const ReportsUI(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shellController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 🛡️ DO NOT dispose of the singleton shell controller!
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 🛡️ Logout ONLY on system sleep (detected as 'hidden' in Flutter 3.13+)
    // We removed 'paused' to prevent logout when the app is simply minimized.
    if (state == AppLifecycleState.hidden) {
      debugPrint(
        "System hidden state detected (potentially sleep/lock). Logging out...",
      );
      _logout();
    }
  }

  void _logout() {
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            color: theme.colorScheme.surface,
            padding: .all(kPadding),
            child: Column(
              children: [
                // Logo section remains in View
                _buildSidebarLogo(theme),
                height20,

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nav Items
                        _navItem(0, LucideIcons.package, "Inventory"),
                        _navItem(1, LucideIcons.shoppingCart, "POS / Billing"),
                        _navItem(2, LucideIcons.layoutDashboard, "Dashboard"),
                        _navItem(3, LucideIcons.receipt, "Past Invoices"),
                        _navItem(4, LucideIcons.users, "Customers"),
                        _navItem(5, LucideIcons.settings, "Setup & Shop"),
                        _navItem(6, LucideIcons.trendingUp, "Reports"),
                      ],
                    ),
                  ),
                ),

                // User Profile & Logout
                _buildUserProfileTile(theme, isDark),
              ],
            ),
          ),

          // Content
          Expanded(child: _screens[_shellController.selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildSidebarLogo(ThemeData theme) {
    return Column(
      children: [
        const Icon(LucideIcons.gem, color: JewelleryTheme.gold, size: 32),
        const SizedBox(height: 12),
        Text(
          "AURORA",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const Text(
          "JEWELLERS",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: JewelleryTheme.gold,
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfileTile(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: JewelleryTheme.gold,
            child: Text(
              "JD",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "John Doe",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  "Admin",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                        : JewelleryTheme.slate,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: Icon(
              LucideIcons.logOut,
              size: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    bool isActive = _shellController.selectedIndex == index;
    return InkWell(
      onTap: () => _shellController.setIndex(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? JewelleryTheme.darkSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? JewelleryTheme.gold
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? JewelleryTheme.gold
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
