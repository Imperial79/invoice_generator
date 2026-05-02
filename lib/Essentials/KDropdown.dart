import 'package:flutter/material.dart';
import '../Resources/colors.dart';
import '../Resources/commons.dart';
import 'Label.dart';

class KDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Color? fieldColor;
  final Color? borderColor;

  const KDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.fieldColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 7.0),
          child: Label(label, weight: 600, fontSize: 13).regular,
        ),
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldColor ?? kColor(context).surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
            border: _borderStyle(context, null),
            errorBorder: _borderStyle(context, kColor(context).error),
            focusedBorder: _borderStyle(
              context,
              kColor(context).primary,
              width: 1.5,
            ),
            enabledBorder: _borderStyle(
              context,
              kColor(context).outlineVariant,
            ),
            errorStyle: TextStyle(
              color: kColor(context).error,
              fontVariations: const [FontVariation.weight(500)],
            ),
          ),
          items: items,
        ),
      ],
    );
  }

  InputBorder _borderStyle(
    BuildContext context,
    Color? customBorder, {
    double width = 1.0,
  }) {
    return OutlineInputBorder(
      borderRadius: kRadius(10),
      borderSide: BorderSide(
        color: borderColor ?? customBorder ?? kColor(context).outlineVariant,
        width: width,
      ),
    );
  }
}
