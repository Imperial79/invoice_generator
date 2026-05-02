import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kCard.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Helper/update_service.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:prime_invoice/Resources/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prime_invoice/Essentials/kField.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Helper/security_helper.dart';
import 'package:flutter/foundation.dart';

class SetupUI extends StatefulWidget {
  const SetupUI({super.key});

  @override
  State<SetupUI> createState() => _SetupUIState();
}

class _SetupUIState extends State<SetupUI> {
  bool isWatermarkEnabled = true;
  String appVersion = "1.0.0";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final pref = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      isWatermarkEnabled = pref.getBool("pdf_watermark") ?? true;
      appVersion = packageInfo.version;
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
                LucideIcons.cloudUpload,
                "Cloud Sync",
                "Data is synced automatically via Supabase",
                onTap: () {
                  KSnackbar(
                    context,
                    message: "All data syncs automatically to Supabase cloud.",
                  );
                },
              ),
              _buildOption(
                LucideIcons.refreshCw,
                "Check for Updates",
                "Current version: $appVersion",
                onTap: () =>
                    UpdateService.checkForUpdates(context, showNoUpdate: true),
              ),
              _buildOption(
                LucideIcons.lock,
                "Security PIN",
                "Update your login PIN",
                onTap: _showChangePinSidebar,
              ),
              _buildOption(
                LucideIcons.info,
                "About",
                "Learn more about Prime Invoice",
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: "Invoice Generator",
                  applicationVersion: appVersion,
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

  void _showChangePinSidebar() {
    final oldPinC = TextEditingController();
    final newPinC = TextEditingController();
    final confirmPinC = TextEditingController();
    final isLoading = ValueNotifier(false);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (c, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (c, a1, a2, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
        child: Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: Container(
              width: Responsive.isMobile(context)
                  ? MediaQuery.sizeOf(context).width
                  : 500,
              height: double.infinity,
              color: kColor(context).surface,
              child: StatefulBuilder(
                builder: (cSelf, setSidebarState) {
                  return Column(
                    children: [
                      _sidebarHeader("Security PIN", LucideIcons.lock, cSelf),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 24,
                            children: [
                              KField(
                                controller: oldPinC,
                                label: "Current PIN",
                                hintText: "Enter current 5-digit PIN",
                                obscureText: true,
                                maxLength: 5,
                                keyboardType: TextInputType.number,
                              ),
                              const Divider(),
                              KField(
                                controller: newPinC,
                                label: "New PIN",
                                hintText: "Enter new 5-digit PIN",
                                obscureText: true,
                                maxLength: 5,
                                keyboardType: TextInputType.number,
                              ),
                              KField(
                                controller: confirmPinC,
                                label: "Confirm New PIN",
                                hintText: "Re-enter new 5-digit PIN",
                                obscureText: true,
                                maxLength: 5,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ),
                      _sidebarFooter("Update PIN", isLoading, () async {
                        if (oldPinC.text.length != 5 ||
                            newPinC.text.length != 5) {
                          KSnackbar(
                            context,
                            message: "PIN must be 5 digits",
                            error: true,
                          );
                          return;
                        }
                        if (newPinC.text != confirmPinC.text) {
                          KSnackbar(
                            context,
                            message: "New PINs do not match",
                            error: true,
                          );
                          return;
                        }

                        isLoading.value = true;
                        try {
                          final profile = await DatabaseService.instance
                              .getCompanyProfile();
                          if (!SecurityHelper.verifyPin(
                            oldPinC.text,
                            profile.securityPin,
                          )) {
                            KSnackbar(
                              context,
                              message: "Current PIN is incorrect",
                              error: true,
                            );
                            return;
                          }

                          final hashedNewPin = SecurityHelper.hashPin(
                            newPinC.text,
                          );
                          await DatabaseService.instance.saveCompanyProfile(
                            profile.copyWith(securityPin: hashedNewPin),
                          );

                          if (mounted) {
                            Navigator.pop(cSelf);
                            KSnackbar(
                              context,
                              message: "Security PIN updated successfully",
                            );
                          }
                        } catch (e) {
                          KSnackbar(
                            context,
                            message: "Error updating PIN: $e",
                            error: true,
                          );
                        } finally {
                          isLoading.value = false;
                        }
                      }, onCancel: () => Navigator.pop(cSelf)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidebarHeader(String title, IconData icon, BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: BoxDecoration(
        color: kColor(ctx).surfaceContainerLow,
        border: Border(bottom: BorderSide(color: kColor(ctx).outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: kColor(ctx).primary),
          const SizedBox(width: 16),
          Label(title, fontSize: 20, weight: 800).title,
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(LucideIcons.x),
          ),
        ],
      ),
    );
  }

  Widget _sidebarFooter(
    String label,
    ValueListenable<bool> loading,
    VoidCallback onSave, {
    VoidCallback? onCancel,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kColor(context).surface,
        border: Border(top: BorderSide(color: kColor(context).outlineVariant)),
      ),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: kRadius(18)),
              ),
              child: Label("Cancel", weight: 700).regular,
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: loading,
              builder: (context, val, _) {
                return ElevatedButton(
                  onPressed: val ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColor(context).primary,
                    foregroundColor: kColor(context).onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: kRadius(18)),
                  ),
                  child: val
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Label(label, weight: 700).regular,
                );
              },
            ),
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
