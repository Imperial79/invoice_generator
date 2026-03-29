import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Resources/constants.dart';

class RootUI extends StatefulWidget {
  final Widget child;
  const RootUI({super.key, required this.child});

  @override
  State<RootUI> createState() => _RootUIState();
}

class _RootUIState extends State<RootUI> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location == '/invoices') return 1;
    if (location == '/create-invoice') return 2;
    if (location == '/clients') return 3;
    if (location == '/setup' || location == '/company-profile') return 4;
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
        context.push('/create-invoice');
        break;
      case 3:
        context.go('/clients');
        break;
      case 4:
        context.go('/setup');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(context, selectedIndex),
          Expanded(child: widget.child),
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
      padding: .all(kPadding),
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: kColor(context).surfaceContainerLow,
        border: Border(
          right: BorderSide(color: kColor(context).outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(context),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
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
                const Divider(height: 40),
                _sidebarItem(
                  context,
                  icon: LucideIcons.settings,
                  label: "Settings",
                  index: 4,
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
    return SizedBox(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kColor(context).primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.fileText,
              color: kColor(context).onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Label("Prime", fontSize: 18, weight: 800).title,
              Label(
                "Invoicing",
                fontSize: 14,
                color: kColor(context).onSurfaceVariant,
              ).regular,
            ],
          ),
        ],
      ),
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
    final color = isSelected
        ? kColor(context).primary
        : kColor(context).onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? kColor(context).primaryContainer.withAlpha(127)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Label(
                  label,
                  fontSize: 14,
                  weight: isSelected ? 600 : 500,
                  color: isSelected
                      ? kColor(context).onPrimaryContainer
                      : kColor(context).onSurface,
                ).regular,
              ),
              if (isSelected)
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kColor(context).primary,
                    shape: BoxShape.circle,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kColor(context).surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: kColor(context).primary,
            child: Label(
              "JD",
              fontSize: 10,
              color: kColor(context).onPrimary,
            ).title,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Label("John Doe", fontSize: 12, weight: 600).regular,
                Label(
                  "Administrator",
                  fontSize: 10,
                  color: kColor(context).onSurfaceVariant,
                ).regular,
              ],
            ),
          ),
          Icon(
            LucideIcons.ellipsis,
            size: 16,
            color: kColor(context).onSurfaceVariant,
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
