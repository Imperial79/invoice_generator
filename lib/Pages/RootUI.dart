import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Helper/platform_helper.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Resources/commons.dart';

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
      _backgroundTimestamp = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTimestamp != null) {
        final elapsed = DateTime.now().difference(_backgroundTimestamp!);
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

    if (PlatformHelper.isWindows) {
      return _buildFluentShell(context, selectedIndex);
    }

    return _buildMaterialShell(context, selectedIndex);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // WINDOWS — Fluent NavigationView shell
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildFluentShell(BuildContext context, int selectedIndex) {
    final fluentTheme = fluent.FluentTheme.of(context);
    final isDark = fluentTheme.brightness == Brightness.dark;
    final surfaceBg = isDark
        ? const Color(0xFF1C1C1C)
        : const Color(0xFFF3F3F3);
    final contentBody = fluent.ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Container(color: surfaceBg, child: widget.child),
    );

    return fluent.NavigationView(

      pane: fluent.NavigationPane(
        selected: selectedIndex,
        onChanged: (index) => _onItemTapped(index, context),
        displayMode: fluent.PaneDisplayMode.auto,
        size: const fluent.NavigationPaneSize(openWidth: 240),
        header: const SizedBox(height: 8),
        footerItems: [
          fluent.PaneItemSeparator(),
          fluent.PaneItem(
            key: const Key('settings'),
            icon: const Icon(LucideIcons.settings, size: 18),
            title: const Text('Settings'),
            body: contentBody,
          ),
          fluent.PaneItemAction(
            key: const Key('logout'),
            icon: const Icon(LucideIcons.logOut, size: 18),
            title: const Text('Logout'),
            onTap: () => context.go('/login'),
          ),
        ],
        items: [
          fluent.PaneItem(
            key: const Key('dashboard'),
            icon: const Icon(LucideIcons.layoutGrid, size: 18),
            title: const Text('Dashboard'),
            body: contentBody,
          ),
          fluent.PaneItem(
            key: const Key('invoices'),
            icon: const Icon(LucideIcons.fileText, size: 18),
            title: const Text('All Invoices'),
            body: contentBody,
          ),
          fluent.PaneItem(
            key: const Key('new_invoice'),
            icon: const Icon(LucideIcons.plus, size: 18),
            title: const Text('New Invoice'),
            body: contentBody,
          ),
          fluent.PaneItem(
            key: const Key('clients'),
            icon: const Icon(LucideIcons.users, size: 18),
            title: const Text('Clients'),
            body: contentBody,
          ),
          fluent.PaneItem(
            key: const Key('inventory'),
            icon: const Icon(LucideIcons.package2, size: 18),
            title: const Text('Inventory'),
            body: contentBody,
          ),
          fluent.PaneItem(
            key: const Key('reports'),
            icon: const Icon(LucideIcons.chartPie, size: 18),
            title: const Text('Reports'),
            body: contentBody,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Non-Windows — existing Material shell (unchanged)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMaterialShell(BuildContext context, int selectedIndex) {
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
                shape: BoxShape.rectangle,
                color: kColor(context).primary.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: 200,
            child: Container(
              width: Responsive.isMobile(context)
                  ? MediaQuery.sizeOf(context).width
                  : 400,
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
      color: Colors.transparent,
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
                    color: kColor(context).outlineVariant.withAlpha(100),
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
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/images/logo.png")),
          ),
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
        borderRadius: kRadius(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? kColor(context).primary.withAlpha(25)
                : Colors.transparent,
            borderRadius: kRadius(16),
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
        borderRadius: kRadius(20),
        border: Border.all(color: kColor(context).outlineVariant.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kColor(context).primary.withAlpha(30),
              shape: BoxShape.rectangle,
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
