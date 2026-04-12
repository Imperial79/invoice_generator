import 'package:flutter/material.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kButton.dart';
import 'package:prime_invoice/Essentials/kField.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  _loadSettings() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      metalGstC.text = (pref.getDouble("metal_gst") ?? 3.0).toString();
      serviceGstC.text = (pref.getDouble("service_gst") ?? 18.0).toString();
    });
  }

  _saveSettings() async {
    isLoading.value = true;
    final pref = await SharedPreferences.getInstance();
    await pref.setDouble("metal_gst", parseToDouble(metalGstC.text));
    await pref.setDouble("service_gst", parseToDouble(serviceGstC.text));
    isLoading.value = false;
    if (mounted) {
      KSnackbar(context, message: "GST Settings saved successfully!");
      Navigator.pop(context);
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
