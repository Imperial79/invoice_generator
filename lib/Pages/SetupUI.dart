import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:prime_invoice/JewelleryApp/Theme.dart';
import 'package:prime_invoice/JewelleryApp/Widgets/JewelleryCard.dart';
import 'package:prime_invoice/Helper/theme_service.dart';
import 'package:prime_invoice/Helper/database_service.dart';

class SetupUI extends StatefulWidget {
  const SetupUI({super.key});

  @override
  State<SetupUI> createState() => _SetupUIState();
}

class _SetupUIState extends State<SetupUI> {
  bool isWatermarkEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      isWatermarkEnabled = pref.getBool("pdf_watermark") ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("APP SETTINGS & SETUP"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(32),
            children: [
              // Theme Section
              _sectionTitle("Design & Appearance"),
              JewelleryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _settingItem(
                      LucideIcons.palette,
                      "Application Theme",
                      "Choose between light, dark or system default mode",
                      trailing: _themeToggle(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Shop Section
              _sectionTitle("Shop Configuration"),
              JewelleryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _settingItem(
                      LucideIcons.store,
                      "Shop Profile",
                      "Manage business name, GSTIN, and address",
                      onTap: () => context.push("/company-profile"),
                    ),
                    const Divider(height: 32),
                    _settingItem(
                      LucideIcons.coins,
                      "Gold & Metal Rates",
                      "Set current market rates for billing",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // PDF Section
              _sectionTitle("Document Settings"),
              JewelleryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _settingItem(
                      LucideIcons.fileType,
                      "Invoice Watermark",
                      "Show digital watermark on generated PDFs",
                      trailing: Switch(
                        value: isWatermarkEnabled,
                        onChanged: (val) async {
                          final pref = await SharedPreferences.getInstance();
                          await pref.setBool("pdf_watermark", val);
                          setState(() => isWatermarkEnabled = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Data Section
              _sectionTitle("Data Management"),
              JewelleryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _settingItem(
                      LucideIcons.database,
                      "Backup & Restore",
                      "Backup your invoices to a local file",
                      onTap: () {},
                    ),
                    const Divider(height: 32),
                    _settingItem(
                      LucideIcons.trash2,
                      "Purge Database",
                      "Permanently delete all transaction data",
                      color: JewelleryTheme.error,
                      onTap: () => _showClearDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),

              // Footer
              Center(
                child: Column(
                  children: [
                    const Icon(
                      LucideIcons.gem,
                      color: JewelleryTheme.gold,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "AURORA JEWELLERS v1.0.0",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                        letterSpacing: 2,
                      ),
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

  Widget _sectionTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _themeToggle() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, mode, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _themeOption(
                ThemeMode.light,
                LucideIcons.sun,
                mode == ThemeMode.light,
              ),
              _themeOption(
                ThemeMode.dark,
                LucideIcons.moon,
                mode == ThemeMode.dark,
              ),
              _themeOption(
                ThemeMode.system,
                LucideIcons.monitor,
                mode == ThemeMode.system,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _themeOption(ThemeMode mode, IconData icon, bool isActive) {
    return InkWell(
      onTap: () => ThemeService.instance.setThemeMode(mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? JewelleryTheme.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _settingItem(
    IconData icon,
    String title,
    String sub, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? JewelleryTheme.gold).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color ?? JewelleryTheme.gold),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color ?? theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permanently delete all data?"),
        content: const Text(
          "This action cannot be undone. All invoices and history will be cleared.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.clearDatabase();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Database cleared successfully"),
                  ),
                );
              }
            },
            child: const Text(
              "PURGE",
              style: TextStyle(color: JewelleryTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
