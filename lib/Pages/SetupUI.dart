import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prime_invoice/Resources/theme.dart';

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
      appBar: KAppBar(context, title: "Settings", showBack: false),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            primary: true,
            padding: const EdgeInsets.all(kPadding),
            children: [
              _buildOption(
                LucideIcons.user,
                "Company Profile",
                "Basic details & GSTIN",
                onTap: () => context.push("/company-profile"),
              ),
              _buildOption(
                LucideIcons.coins,
                "Metal Rates",
                "Update Gold, Silver & Platinum rates",
                onTap: () => context.push("/metal-rates"),
              ),
              _buildOption(
                LucideIcons.percent,
                "GST Settings",
                "Set Metal & Service GST rates",
                onTap: () => context.push("/gst-settings"),
              ),
              _buildOption(
                LucideIcons.palette,
                "App Theme",
                "Switch Light/Dark Mode",
                trailing: ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeModeNotifier,
                  builder: (context, mode, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 5,
                      children: ThemeMode.values.map((e) {
                        final isSelected = mode == e;
                        IconData icon;
                        switch (e) {
                          case ThemeMode.light:
                            icon = LucideIcons.sun;
                            break;
                          case ThemeMode.dark:
                            icon = LucideIcons.moon;
                            break;
                          default:
                            icon = LucideIcons.monitor;
                        }

                        return InkWell(
                          onTap: () async {
                            themeModeNotifier.value = e;
                            final pref = await SharedPreferences.getInstance();
                            await pref.setInt("theme_mode", e.index);
                          },
                          borderRadius: kRadius(10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kColor(context).primary
                                  : kColor(context).surfaceContainerHigh
                                        .withValues(alpha: .5),
                              borderRadius: kRadius(10),
                            ),
                            child: Icon(
                              icon,
                              size: 18,
                              color: isSelected
                                  ? kColor(context).onPrimary
                                  : kColor(context).onSurfaceVariant,
                            ),
                          ),
                        );
                      }).toList(),
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
                "Save & load local database backup",
                onTap: () => _showBackupRestoreDialog(context),
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
        ),
      ),
    );
  }

  void _showBackupRestoreDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: Label("Backup & Restore", weight: 700).title,
        content: Label("Select an action for your database.").regular,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Label("Cancel").regular,
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              String? dbPath = await DatabaseService.instance.getDbPath();
              if (dbPath == null) return;

              String? outputFile = await FilePicker.platform.saveFile(
                dialogTitle: 'Save Database Backup',
                fileName: 'invoice_backup.db',
              );

              if (outputFile != null) {
                try {
                  File(dbPath).copySync(outputFile);
                  if (parentContext.mounted) {
                    KSnackbar(
                      parentContext,
                      message: "Backup saved at: $outputFile",
                    );
                  }
                } catch (e) {
                  if (parentContext.mounted) {
                    KSnackbar(
                      parentContext,
                      message: "Error saving backup: $e",
                      error: true,
                    );
                  }
                }
              }
            },
            child: Label(
              "Backup",
              color: kColor(parentContext).primary,
            ).regular,
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              String? dbPath = await DatabaseService.instance.getDbPath();
              if (dbPath == null) return;

              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['db'],
              );

              if (result != null && result.files.single.path != null) {
                try {
                  File(result.files.single.path!).copySync(dbPath);
                  if (parentContext.mounted) {
                    KSnackbar(
                      parentContext,
                      message: "Database restored! Please restart the app.",
                    );
                  }
                } catch (e) {
                  if (parentContext.mounted) {
                    KSnackbar(
                      parentContext,
                      message: "Error restoring: $e",
                      error: true,
                    );
                  }
                }
              }
            },
            child: Label(
              "Restore",
              color: kColor(parentContext).secondary,
            ).regular,
          ),
          // TextButton(
          //   onPressed: () async {
          //     Navigator.pop(dialogContext); // Close dialog
          //     _showClearDialog(parentContext);
          //   },
          //   child: Label(
          //     "Clear DB",
          //     color: kColor(parentContext).error,
          //   ).regular,
          // ),
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
              await DatabaseService.instance.clearDatabase();
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
                  weight: 400,
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
