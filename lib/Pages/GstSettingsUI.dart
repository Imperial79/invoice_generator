import 'package:flutter/material.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kButton.dart';
import 'package:prime_invoice/Essentials/kField.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GstSettingsUI extends StatefulWidget {
  const GstSettingsUI({super.key});

  @override
  State<GstSettingsUI> createState() => _GstSettingsUIState();
}

class _GstSettingsUIState extends State<GstSettingsUI> {
  final metalGstC = TextEditingController();
  final serviceGstC = TextEditingController();
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    metalGstC.dispose();
    serviceGstC.dispose();
    isLoading.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    isLoading.value = true;
    try {
      final profile = await DatabaseService.instance.getCompanyProfile();
      setState(() {
        metalGstC.text = profile.metalGst.toString();
        serviceGstC.text = profile.serviceGst.toString();
      });
    } catch (e) {
      debugPrint("Error loading GST settings: $e");
      setState(() {
        metalGstC.text = "3.0";
        serviceGstC.text = "18.0";
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveSettings() async {
    isLoading.value = true;
    try {
      // Load existing profile and patch only GST fields
      final existing = await DatabaseService.instance.getCompanyProfile();
      final updated = existing.copyWith(
        metalGst: parseToDouble(metalGstC.text),
        serviceGst: parseToDouble(serviceGstC.text),
      );
      await DatabaseService.instance.saveCompanyProfile(updated);
      if (mounted) {
        KSnackbar(context, message: "GST Settings saved successfully!");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        KSnackbar(context, message: "Error saving GST settings: $e", error: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "GST Settings"),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(kPadding),
            children: [
              Label(
                "Set default GST rates for different components of your bill.",
                color: kColor(context).onSurfaceVariant,
              ).regular,
              const SizedBox(height: 30),
              KField(
                controller: metalGstC,
                label: "Metal GST (%)",
                hintText: "e.g. 3.0",
                prefix: const Icon(LucideIcons.coins, size: 18),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 20),
              KField(
                controller: serviceGstC,
                label: "Service GST (%)",
                hintText: "e.g. 18.0",
                subLabel: "Applicable on making charges, labor, etc.",
                prefix: const Icon(LucideIcons.hammer, size: 18),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 40),
              KButton(
                onPressed: _saveSettings,
                label: "Save GST Settings",
                icon: const Icon(LucideIcons.save),
                style: KButtonStyle.expanded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
