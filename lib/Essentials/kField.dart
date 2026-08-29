import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:prime_invoice/Helper/platform_helper.dart';
import 'package:prime_invoice/Resources/commons.dart';
import '../Resources/colors.dart';
import 'Label.dart';

class KField extends StatelessWidget {
  final bool showRequired;
  final bool autoFocus;
  final void Function()? onTap;
  final bool? readOnly;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? prefixText;
  final Widget? prefix;
  final Widget? suffix;
  final Color? cursorColor;
  final Color? fieldColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? hintTextColor;
  final bool? obscureText;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final FocusNode? focusNode;
  final String? label;
  final String? subLabel;
  final double? fontSize;
  final Widget? labelIcon;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String val)? onChanged;
  final String? Function(String? val)? validator;
  final void Function(String val)? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final String? initialValue;

  const KField({
    super.key,
    this.showRequired = true,
    this.autoFocus = false,
    this.onTap,
    this.readOnly,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.prefixText,
    this.prefix,
    this.suffix,
    this.cursorColor,
    this.fieldColor,
    this.borderColor,
    this.textColor,
    this.hintTextColor,
    this.obscureText,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.focusNode,
    this.label,
    this.subLabel,
    this.fontSize,
    this.labelIcon,
    this.textCapitalization = TextCapitalization.words,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.onFieldSubmitted,
    this.autofillHints,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isWindows) {
      return _buildFluentField(context);
    }
    return _buildMaterialField(context);
  }

  // ── Windows: Fluent TextBox ───────────────────────────────────────────────
  Widget _buildFluentField(BuildContext context) {
    final fluentTheme = fluent.FluentTheme.of(context);
    final isDark = fluentTheme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          _buildLabelRow(context),
          const SizedBox(height: 6),
        ],
        fluent.TextBox(
          autofocus: autoFocus,
          controller: controller,
          focusNode: focusNode,
          placeholder: hintText,
          readOnly: readOnly ?? false,
          obscureText: obscureText ?? false,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: minLines,
          onChanged: onChanged,
          onSubmitted: onFieldSubmitted,
          inputFormatters: [
            if (textCapitalization == TextCapitalization.words)
              CapitalizeWordsFormatter(),
            ...?inputFormatters,
          ],
          style: TextStyle(
            fontSize: fontSize ?? kFontSize,
            fontVariations: const [FontVariation.weight(600)],
            color: textColor,
            letterSpacing: .5,
          ),
          placeholderStyle: TextStyle(
            fontSize: fontSize ?? kFontSize,
            color: hintTextColor ??
                (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          prefix: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: prefix,
                )
              : prefixText != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8, right: 4),
                      child: Text(
                        prefixText!,
                        style: TextStyle(
                          fontSize: fontSize ?? kFontSize,
                          fontVariations: const [FontVariation.weight(700)],
                        ),
                      ),
                    )
                  : null,
          suffix: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8),
                  child: suffix,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildLabelRow(BuildContext context) {
    return Row(
      children: [
        ?labelIcon,
        kLabel,
        if (subLabel != null)
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Label(
              subLabel!,
              color: kColor(context).onSurfaceVariant,
              fontSize: 11,
              height: 1,
            ).regular,
          ),
        if (validator != null && showRequired)
          Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: Label(
              "(Required)",
              color: kColor(context).error,
              fontSize: 10,
              height: 1,
            ).regular,
          ),
      ],
    );
  }

  // ── Material: existing implementation ────────────────────────────────────
  Widget _buildMaterialField(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 7.0),
            child: Row(
              children: [
                ?labelIcon,
                kLabel,
                if (subLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Label(
                      subLabel!,
                      color: kColor(context).onSurfaceVariant,
                      fontSize: 11,
                      height: 1,
                    ).regular,
                  ),
                if (validator != null && showRequired)
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Label(
                      "(Required)",
                      color: kColor(context).error,
                      fontSize: 10,
                      height: 1,
                    ).regular,
                  ),
              ],
            ),
          ),
        TextFormField(
          autofocus: autoFocus,
          onTap: onTap,
          focusNode: focusNode,
          autofillHints: autofillHints,
          controller: controller,
          initialValue: initialValue,
          textCapitalization: textCapitalization,
          style: kFieldTextstyle.copyWith(fontSize: fontSize, color: textColor),
          cursorColor: cursorColor,
          readOnly: readOnly ?? false,
          obscureText: obscureText ?? false,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: minLines,
          inputFormatters: [
            if (textCapitalization == TextCapitalization.words)
              CapitalizeWordsFormatter(),
            ...?inputFormatters,
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldColor ?? kColor(context).surfaceContainerLowest,
            counterText: '',
            prefixIconConstraints: const BoxConstraints(
              minHeight: 0,
              minWidth: 0,
            ),
            suffixIconConstraints: const BoxConstraints(
              minHeight: 0,
              minWidth: 0,
            ),
            prefixIcon: prefix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 10),
                    child: prefix!,
                  )
                : prefixText != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 10),
                    child: Label(
                      prefixText!,
                      fontSize: fontSize,
                      height: kTextHeight,
                      weight: 700,
                    ).regular,
                  )
                : const SizedBox(width: 12),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 5, right: 12),
                    child: suffix!,
                  )
                : const SizedBox(width: 12),
            isDense: true,
            border: borderStyle(context, null),
            errorBorder: borderStyle(context, kColor(context).error),
            focusedBorder: borderStyle(
              context,
              kColor(context).primary,
              width: 1.5,
            ),
            enabledBorder: borderStyle(context, kColor(context).outlineVariant),
            errorStyle: TextStyle(
              color: kColor(context).error,
              fontVariations: [FontVariation.weight(500)],
            ),
            hintText: hintText,
            hintStyle: kHintTextstyle(
              context,
            ).copyWith(fontSize: fontSize, color: hintTextColor),
          ),
          onChanged: onChanged,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }

  static const double kFontSize = 15;
  static const double kTextHeight = 1.5;
  static Color khintColor = Colors.grey.shade400;

  Widget get kLabel => Label(label!, weight: 600, fontSize: 13).regular;

  TextStyle get kFieldTextstyle => TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: kFontSize,
    letterSpacing: .5,
    height: kTextHeight,
    fontVariations: [FontVariation.weight(600)],
  );

  TextStyle kHintTextstyle(BuildContext context) => TextStyle(
    fontVariations: [FontVariation.weight(400)],
    fontSize: kFontSize,
    height: kTextHeight,
    color: kColor(context).onSurfaceVariant,
  );

  InputBorder borderStyle(
    BuildContext context,
    Color? customBorder, {
    double width = 1.0,
  }) => OutlineInputBorder(
    borderRadius: kRadius(15),
    borderSide: BorderSide(
      color: borderColor ?? customBorder ?? kColor(context).outlineVariant,
      width: width,
    ),
  );
}

class KValidation {
  static String? required(String? val) =>
      (val ?? '').isEmpty ? 'Required!' : null;

  static String? phone(String? val) {
    if (val == null || val.isEmpty) return 'Required!';
    if (val.length != 10) return "Phone must be of length 10!";
    if (!RegExp(r'^\d+$').hasMatch(val)) {
      return "Phone must contain only digits!";
    }
    return null;
  }

  static const String emailPattern = r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+';

  static String? email(String? val) {
    if (val == null || val.isEmpty) return 'Required!';
    return !RegExp(emailPattern).hasMatch(val)
        ? 'Enter a valid email address'
        : null;
  }

  static String? pan(String? val) {
    if (val!.length != 10) return 'Length must be 10!';
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(val)) {
      return 'PAN must be alphanumeric!';
    }
    return null;
  }
}

class CapitalizeWordsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final String text = newValue.text;
    final List<String> words = text.split(' ');
    final List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).toList();

    final String result = capitalizedWords.join(' ');

    return newValue.copyWith(text: result, selection: newValue.selection);
  }
}
