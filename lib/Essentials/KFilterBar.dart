import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Essentials/KField.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Resources/commons.dart';
import 'package:prime_invoice/Resources/constants.dart';

class FilterConfig {
  final String id;
  final String label;
  final List<String>? options; // For dropdowns
  final Widget Function(BuildContext)? custom; // For pickers like DateRange
  final String? initialValue;
  final bool isSearch;

  FilterConfig({
    required this.id,
    required this.label,
    this.options,
    this.custom,
    this.initialValue,
    this.isSearch = false,
  });
}

class KFilterBar extends StatelessWidget {
  final List<FilterConfig> configs;
  final Map<String, String> selectedFilters;
  final Function(String id, String value) onFilterChanged;
  final VoidCallback onClearAll;
  final Widget? action;

  const KFilterBar({
    super.key,
    required this.configs,
    required this.selectedFilters,
    required this.onFilterChanged,
    required this.onClearAll,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: kColor(context).surface,
        border: Border(
          bottom: BorderSide(
            color: kColor(context).outlineVariant.withAlpha(50),
          ),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                ...configs.map((config) {
                  if (config.isSearch) {
                    return Expanded(
                      flex: 1, // Small search bar
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: KField(
                          hintText: config.label,
                          initialValue: selectedFilters[config.id],
                          prefix: const Icon(LucideIcons.search, size: 18),
                          onChanged: (v) => onFilterChanged(config.id, v),
                        ),
                      ),
                    );
                  } else if (config.options != null) {
                    return Expanded(
                      flex: 1, // Wider dropdown
                      child: _buildDropdown(context, config),
                    );
                  } else if (config.custom != null) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: config.custom!(context),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                if (action != null) ...[const SizedBox(width: 8), action!],
              ],
            ),
            if (selectedFilters.values.any((v) => v.isNotEmpty && v != "All"))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Label(
                      "Active Filters: ",
                      fontSize: 12,
                      weight: 600,
                      color: kColor(context).onSurfaceVariant,
                    ).regular,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...selectedFilters.entries
                              .where(
                                (e) => e.value.isNotEmpty && e.value != "All",
                              )
                              .map((e) {
                                final config = configs.firstWhere(
                                  (c) => c.id == e.key,
                                );
                                return _filterTag(
                                  context,
                                  "${config.label}: ${e.value}",
                                  () {
                                    onFilterChanged(
                                      e.key,
                                      config.options != null ? "All" : "",
                                    );
                                  },
                                );
                              }),
                          TextButton(
                            onPressed: onClearAll,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Label(
                              "Clear All",
                              fontSize: 12,
                              weight: 700,
                              color: kColor(context).primary,
                            ).regular,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, FilterConfig config) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: kColor(context).surfaceContainerLow,
        borderRadius: kRadius(12),
        border: Border.all(color: kColor(context).outlineVariant.withAlpha(80)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilters[config.id] ?? "All",
          items: config.options!
              .map((e) => DropdownMenuItem(value: e, child: Label(e).regular))
              .toList(),
          onChanged: (v) => onFilterChanged(config.id, v!),
        ),
      ),
    );
  }

  Widget _filterTag(BuildContext context, String label, VoidCallback onClear) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kColor(context).primary.withAlpha(15),
        borderRadius: kRadius(20),
        border: Border.all(color: kColor(context).primary.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Label(
            label,
            fontSize: 11,
            weight: 700,
            color: kColor(context).primary,
          ).regular,
          const SizedBox(width: 4),
          InkWell(
            onTap: onClear,
            child: Icon(
              LucideIcons.x,
              size: 12,
              color: kColor(context).primary,
            ),
          ),
        ],
      ),
    );
  }
}
