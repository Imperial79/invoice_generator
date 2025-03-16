import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final double? fontSize;
  final Widget? labelIcon;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String val)? onChanged;
  final String? Function(String? val)? validator;
  final void Function(String val)? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  const KField(
      {super.key,
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
      this.fontSize,
      this.labelIcon,
      this.textCapitalization = TextCapitalization.words,
      this.inputFormatters,
      this.onChanged,
      this.validator,
      this.onFieldSubmitted,
      this.autofillHints});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 7.0),
            child: Row(
              children: [
                if (labelIcon != null) labelIcon!,
                kLabel,
                if (validator != null && showRequired)
                  Padding(
                    padding: EdgeInsets.only(left: 3.0),
                    child: Label(
                      "(Required)",
                      color: StatusText.danger,
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
          textCapitalization: textCapitalization,
          style: kFieldTextstyle.copyWith(fontSize: fontSize, color: textColor),
          cursorColor: cursorColor,
          readOnly: readOnly ?? false,
          obscureText: obscureText ?? false,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: minLines,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldColor ?? Colors.white,
            counterText: '',
            prefixIconConstraints:
                const BoxConstraints(minHeight: 0, minWidth: 0),
            suffixIconConstraints:
                const BoxConstraints(minHeight: 0, minWidth: 0),
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
            border: borderStyle(null),
            errorBorder: borderStyle(StatusText.danger),
            focusedBorder: borderStyle(Kolor.primary, width: 1.5),
            enabledBorder: borderStyle(null),
            errorStyle: TextStyle(
              color: StatusText.danger,
              fontVariations: [
                FontVariation.weight(500),
              ],
            ),
            hintText: hintText,
            hintStyle: kHintTextstyle.copyWith(
                fontSize: fontSize, color: hintTextColor),
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

  Widget get kLabel => Label(
        label!,
        weight: 600,
        fontSize: 13,
      ).regular;

  TextStyle get kFieldTextstyle => TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: kFontSize,
      letterSpacing: .5,
      height: kTextHeight,
      fontVariations: [FontVariation.weight(600)]);

  TextStyle get kHintTextstyle => TextStyle(
        fontVariations: [FontVariation.weight(400)],
        fontSize: kFontSize,
        height: kTextHeight,
        color: khintColor,
      );

  InputBorder borderStyle(
    Color? customBorder, {
    double width = 1.0,
  }) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: borderColor ?? customBorder ?? Kolor.border,
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
