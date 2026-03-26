import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invoice_generator/Essentials/KScaffold.dart';
import 'package:invoice_generator/Essentials/Label.dart';
import 'package:invoice_generator/Essentials/kCard.dart';
import 'package:invoice_generator/Helper/database_helper.dart';
import 'package:invoice_generator/Resources/colors.dart';
import 'package:invoice_generator/Resources/commons.dart';
import 'package:invoice_generator/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invoice_generator/Resources/theme.dart';

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
    return KScaffold(
      appBar: KAppBar(context, title: "Settings"),
      body: ListView(
        padding: const EdgeInsets.all(kPadding),
        children: [
          _buildOption(
            LucideIcons.user,
            "Company Profile",
            "Basic details & GSTIN",
            onTap: () => context.push("/company-profile"),
          ),
          _buildOption(
            LucideIcons.palette,
            "App Theme",
            "Switch Light/Dark Mode",
            trailing: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeModeNotifier,
              builder: (context, mode, _) {
                return DropdownButtonHideUnderline(
                  child: DropdownButton<ThemeMode>(
                    value: mode,
                    onChanged: (newMode) async {
                      if (newMode != null) {
                        themeModeNotifier.value = newMode;
                        final pref = await SharedPreferences.getInstance();
                        await pref.setInt("theme_mode", newMode.index);
                      }
                    },
                    items: ThemeMode.values.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Label(e.name.toUpperCase(), fontSize: 13).regular,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            onTap: () {},
          ),
          _buildOption(
            LucideIcons.fileText,
            "Show/Hide Watermark",
            "Toggle Watermark",
            trailing: Switch(
              value: isWatermarkEnabled,
              activeTrackColor: kColor(context).primary,
              onChanged: (val) async {
                final pref = await SharedPreferences.getInstance();
                await pref.setBool("pdf_watermark", val);
                setState(() => isWatermarkEnabled = val);
                if (context.mounted) {
                  KSnackbar(
                    context,
                    message: "Watermark ${val ? 'Enabled' : 'Disabled'}",
                  );
                }
              },
            ),
            onTap: () {},
          ),
          _buildOption(
            LucideIcons.database,
            "Backup & Restore",
            "Clear all data",
            onTap: () => _showClearDialog(context),
          ),
          _buildOption(
            LucideIcons.info,
            "About",
            "Version 1.0.0",
            onTap: () => showAboutDialog(
              context: context,
              applicationName: "Invoice Generator",
              applicationVersion: "1.0.0",
              applicationIcon: Icon(
                LucideIcons.fileText,
                size: 40,
                color: kColor(context).primary,
              ),
              children: [
                Label(
                  "A premium tool for generating professional invoices locally on your device.",
                ).regular,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Label("Clear Database?", weight: 700).title,
        content: Label(
          "Are you sure? This will permanently delete all your invoices.",
        ).regular,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Label("Cancel").regular,
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearDatabase();
              if (context.mounted) {
                Navigator.pop(context);
                KSnackbar(context, message: "Database cleared successfully!");
              }
            },
            child: Label("Yes, Clear", color: kColor(context).error).regular,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    IconData icon,
    String title,
    String sub, {
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return KCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      color: kColor(context).surface,
      borderWidth: 1,
      borderColor: kColor(context).outlineVariant,
      radius: 15,
      child: Row(
        children: [
          Icon(icon, color: kColor(context).onSurface),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label(title, fontSize: 16, weight: 600).regular,
                Label(
                  sub,
                  fontSize: 12,
                  color: kColor(context).onSurfaceVariant,
                ).regular,
              ],
            ),
          ),
          trailing ??
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: kColor(context).onSurfaceVariant,
              ),
        ],
      ),
    );
  }
}
