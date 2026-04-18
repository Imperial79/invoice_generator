import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Essentials/Label.dart';

class RootUI extends StatefulWidget {
  final Widget child;
  const RootUI({super.key, required this.child});

  @override
  State<RootUI> createState() => _RootUIState();
}

class _RootUIState extends State<RootUI> with WidgetsBindingObserver {
  DateTime? _backgroundTimestamp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 🕒 Record the time when app goes to background
      _backgroundTimestamp = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTimestamp != null) {
        final elapsed = DateTime.now().difference(_backgroundTimestamp!);
        // 🔒 Logout only if app was in background for more than 20 seconds
        // This avoids logging out during quick app switches but captures device sleep.
        if (elapsed.inSeconds >= 20) {
          context.go('/login');
        }
        _backgroundTimestamp = null;
      }
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location == '/invoices') return 1;
    if (location == '/create-invoice') return 2;
    if (location == '/clients') return 3;
    if (location == '/inventory') return 4;
    if (location == '/reports') return 5;
    if (location == '/setup' || location == '/company-profile') return 6;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/invoices');
        break;
      case 2:
        context.go('/create-invoice');
        break;
      case 3:
        context.go('/clients');
        break;
      case 4:
        context.go('/inventory');
        break;
      case 5:
        context.go('/reports');
        break;
      case 6:
        context.go('/setup');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: kColor(context).surface,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kColor(context).primary.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kColor(context).secondary.withAlpha(11),
              ),
            ),
          ),
          Row(
            children: [
              if (!isMobile) _buildSidebar(context, selectedIndex),
              Expanded(
                child: ClipRRect(
                  borderRadius: isMobile
                      ? BorderRadius.zero
                      : const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          bottomLeft: Radius.circular(32),
                        ),
                  child: Container(
                    decoration: BoxDecoration(color: kColor(context).surface),
                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? _buildBottomNav(context, selectedIndex)
          : null,
      drawer: isMobile ? _buildDrawer(context, selectedIndex) : null,
    );
  }

  Widget _buildSidebar(BuildContext context, int selectedIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      width: 300,
      height: double.infinity,
      color: Colors.transparent, // Let background show through
      child: Column(
        children: [
          _buildSidebarHeader(context),
          const SizedBox(height: 48),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _sidebarItem(
                  context,
                  icon: LucideIcons.layoutGrid,
                  label: "Dashboard",
                  index: 0,
                  selectedIndex: selectedIndex,
                ),
                _sidebarItem(
                  context,
                  icon: LucideIcons.fileText,
                  label: "All Invoices",
                  index: 1,
                  selectedIndex: selectedIndex,
                ),
                _sidebarItem(
                  context,
                  icon: LucideIcons.plus,
                  label: "New Invoice",
                  index: 2,
                  selectedIndex: selectedIndex,
                ),
                _sidebarItem(
                  context,
                  icon: LucideIcons.users,
                  label: "Clients",
                  index: 3,
                  selectedIndex: selectedIndex,
                ),
                _sidebarItem(
                  context,
                  icon: LucideIcons.package2,
                  label: "Inventory",
                  index: 4,
                  selectedIndex: selectedIndex,
                ),
                _sidebarItem(
                  context,
                  icon: LucideIcons.chartPie,
                  label: "Reports",
                  index: 5,
                  selectedIndex: selectedIndex,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Divider(
                    color: kColor(context).outlineVariant.withAlpha(30),
                  ),
                ),
                _sidebarItem(
                  context,
                  icon: LucideIcons.settings,
                  label: "Settings",
                  index: 6,
                  selectedIndex: selectedIndex,
                ),
              ],
            ),
          ),
          _buildSidebarFooter(context),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kColor(context).primary,
                kColor(context).primary.withAlpha(180),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: kColor(context).primary.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(LucideIcons.gem, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label("Prime", fontSize: 20, weight: 900).title,
            Label(
              "Management",
              fontSize: 12,
              color: kColor(context).onSurfaceVariant,
            ).regular,
          ],
        ),
      ],
    );
  }

  Widget _sidebarItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? kColor(context).primary.withAlpha(25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? kColor(context).primary.withAlpha(40)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? kColor(context).primary
                    : kColor(context).onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Label(
                  label,
                  fontSize: 14,
                  weight: isSelected ? 700 : 500,
                  color: isSelected
                      ? kColor(context).primary
                      : kColor(context).onSurface,
                ).regular,
              ),
              if (isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: kColor(context).primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kColor(context).primary.withAlpha(100),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kColor(context).surfaceContainerHigh.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kColor(context).outlineVariant.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kColor(context).primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Label(
              "JD",
              fontSize: 12,
              weight: 800,
              color: kColor(context).primary,
            ).title,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Label("John Doe", fontSize: 13, weight: 700).regular,
                Label(
                  "Admin",
                  fontSize: 11,
                  color: kColor(context).onSurfaceVariant,
                ).regular,
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go('/login'),
            icon: Icon(
              LucideIcons.logOut,
              size: 18,
              color: kColor(context).onSurfaceVariant,
            ),
            visualDensity: VisualDensity.compact,
            tooltip: "Logout",
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int selectedIndex) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _onItemTapped(index, context),
      destinations: const [
        NavigationDestination(
          icon: Icon(LucideIcons.layoutGrid),
          label: "Dash",
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.fileText),
          label: "Invoices",
        ),
        NavigationDestination(icon: Icon(LucideIcons.plus), label: "New"),
        NavigationDestination(icon: Icon(LucideIcons.users), label: "Clients"),
        NavigationDestination(
          icon: Icon(LucideIcons.chartPie),
          label: "Reports",
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.settings),
          label: "Settings",
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, int selectedIndex) {
    return Drawer(child: _buildSidebar(context, selectedIndex));
  }
}
