import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Essentials/KField.dart';
import 'package:prime_invoice/Essentials/KScaffold.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';

class MetalRatesUI extends StatefulWidget {
  const MetalRatesUI({super.key});

  @override
  State<MetalRatesUI> createState() => _MetalRatesUIState();
}

class _MetalRatesUIState extends State<MetalRatesUI> {
  final Map<String, List<String>> metals = {
    "Gold": ["24K", "22K", "18K", "14K"],
    "Silver": ["Base"],
    "Platinum": ["Base"],
  };

  final Map<String, Map<String, TextEditingController>> controllers = {};
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadRates();
  }

  void _initControllers() {
    metals.forEach((metal, purities) {
      controllers[metal] = {};
      for (var purity in purities) {
        controllers[metal]![purity] = TextEditingController();
      }
    });
  }

  Future<void> _loadRates() async {
    isLoading.value = true;
    try {
      final rates = await DatabaseService.instance.getAllMetalRates();
      for (var row in rates) {
        final metal = row.metalType;
        final purity = row.purity;
        final rate = row.ratePer10g.toString();
        if (controllers.containsKey(metal) &&
            controllers[metal]!.containsKey(purity)) {
          controllers[metal]![purity]!.text = rate == "0.0" ? "" : rate;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveRates() async {
    isLoading.value = true;
    try {
      for (var metalEntry in controllers.entries) {
        final metal = metalEntry.key;
        for (var purityEntry in metalEntry.value.entries) {
          final purity = purityEntry.key;
          final rate = double.tryParse(purityEntry.value.text) ?? 0.0;
          await DatabaseService.instance.saveMetalRate(metal, purity, rate);
        }
      }
      if (mounted) {
        KSnackbar(context, message: "Metal rates updated successfully");
      }
    } catch (e) {
      if (mounted) {
        KSnackbar(context, message: "Error saving rates", error: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      appBar: KAppBar(context, title: "Metal Rates"),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(kPadding),
            children: [
              _buildInfoCard(),
              height20,
              ...metals.keys.map((metal) => _buildMetalSection(metal)),
              height30,
              ElevatedButton.icon(
                onPressed: _saveRates,
                icon: const Icon(LucideIcons.save),
                label: Label("Save All Rates").regular,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColor(context).primary,
                  foregroundColor: kColor(context).onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: kRadius(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kColor(context).primaryContainer.withAlpha(50),
        borderRadius: kRadius(12),
        border: Border.all(color: kColor(context).primary.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.info, color: kColor(context).primary),
          width15,
          Expanded(
            child: Label(
              "Update the current market rates here. These rates will be used to calculate pricing during invoice generation. All rates are per 10 grams.",
              fontSize: 13,
              color: kColor(context).onSurfaceVariant,
            ).regular,
          ),
        ],
      ),
    );
  }

  Widget _buildMetalSection(String metal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Label(metal, fontSize: 18, weight: 700).title,
        ),
        ...controllers[metal]!.entries.map((purityEntry) {
          final purity = purityEntry.key;
          final controller = purityEntry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: KField(
              controller: controller,
              label: purity == "Base"
                  ? "$metal Rate (per 10g)"
                  : "$purity Gold Rate (per 10g)",
              hintText: "0.00",
              keyboardType: TextInputType.number,
              prefix: Icon(
                metal == "Gold"
                    ? LucideIcons.coins
                    : (metal == "Silver"
                          ? LucideIcons.disc
                          : LucideIcons.sparkles),
                size: 20,
              ),
            ),
          );
        }),
        const Divider(height: 32),
      ],
    );
  }
}
