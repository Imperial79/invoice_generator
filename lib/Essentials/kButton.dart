import 'package:flutter/material.dart';
import '../Resources/colors.dart';
import '../Resources/commons.dart';
import '../Resources/theme.dart';
import 'Label.dart';

class KButton extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double fontSize;
  final double weight;
  final Widget? icon;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final ButtonStyle? customStyle;
  final bool isLoading;
  final VisualDensity? visualDensity;
  final KButtonStyle style;
  final double? buttonWidth;

  const KButton({
    super.key,
    required this.onPressed,
    this.label = "",
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize = 15,
    this.weight = 600,
    this.icon,
    this.radius = 10,
    this.padding,
    this.customStyle,
    this.isLoading = false,
    this.visualDensity,
    this.style = KButtonStyle.regular,
    this.buttonWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: !isLoading ? onPressed : null,
        style: customStyle ?? _buttonStyle(context),
        child: _buildChild(context),
      ),
    );
  }

  static const double defaultPadding = 12;

  ButtonStyle _buttonStyle(context) {
    switch (style) {
      case KButtonStyle.outlined:
        return ElevatedButton.styleFrom(
          side: BorderSide(
              color: foregroundColor ?? kColor(context).primary),
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor: foregroundColor ?? kColor(context).primary,
          iconColor: foregroundColor ?? kColor(context).primary,
          padding: padding ?? const EdgeInsets.all(defaultPadding),
          shape: RoundedRectangleBorder(
            borderRadius: kRadius(radius ?? 15),
          ),
          visualDensity: visualDensity,
          elevation: 0,
          shadowColor: Colors.transparent,
          alignment: Alignment.center,
          disabledBackgroundColor: kColor(context).surfaceContainerHighest,
          textStyle: TextStyle(
            fontSize: fontSize,
            fontVariations: [FontVariation.weight(weight)],
            fontFamily: kFont,
          ),
        );
      case KButtonStyle.pill:
        return TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: kRadius(radius ?? 15),
          ),
          backgroundColor: _getBg(context),
          foregroundColor: _getFg(context),
          iconColor: _getFg(context),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 15),
        );
      case KButtonStyle.thickPill:
        return ElevatedButton.styleFrom(
          backgroundColor: _getBg(context),
          foregroundColor: _getFg(context),
          iconColor: _getFg(context),
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: kRadius(radius ?? 15),
          ),
          visualDensity: visualDensity,
          elevation: 0,
          shadowColor: Colors.transparent,
          alignment: Alignment.center,
          disabledBackgroundColor: kColor(context).surfaceContainerHighest,
          textStyle: TextStyle(
            fontSize: fontSize,
            fontVariations: [FontVariation.weight(weight)],
            fontFamily: kFont,
          ),
        );
      case KButtonStyle.regular:
        return ElevatedButton.styleFrom(
          backgroundColor: _getBg(context),
          foregroundColor: _getFg(context),
          iconColor: _getFg(context),
          padding: padding ?? const EdgeInsets.all(defaultPadding),
          shape: RoundedRectangleBorder(
            borderRadius: kRadius(radius ?? 7),
          ),
          visualDensity: visualDensity,
          elevation: 0,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: kColor(context).surfaceContainerHighest,
          alignment: Alignment.center,
          textStyle: TextStyle(
            fontSize: fontSize,
            fontVariations: [FontVariation.weight(weight)],
            fontFamily: kFont,
          ),
        );
      case KButtonStyle.expanded:
        return ElevatedButton.styleFrom(
          backgroundColor: _getBg(context),
          foregroundColor: _getFg(context),
          iconColor: _getFg(context),
          padding: padding ?? const EdgeInsets.all(defaultPadding),
          shape: RoundedRectangleBorder(
            borderRadius: kRadius(radius ?? 15),
          ),
          visualDensity: visualDensity,
          elevation: 0,
          shadowColor: Colors.transparent,
          alignment: Alignment.center,
          disabledBackgroundColor: kColor(context).surfaceContainerHighest,
          textStyle: TextStyle(
            fontSize: fontSize,
            fontVariations: [FontVariation.weight(weight)],
            fontFamily: kFont,
          ),
          minimumSize: const Size.fromHeight(50), // Full width
        );
    }
  }

  Color _getBg(BuildContext context) => backgroundColor ?? kColor(context).primary;
  Color _getFg(BuildContext context) => foregroundColor ?? kColor(context).onPrimary;

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return _loadingIndicator(context);
    }

    switch (style) {
      case KButtonStyle.outlined:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Label(
              label,
              weight: weight,
              fontSize: fontSize,
            ).regular,
            if (icon != null) ...[
              const SizedBox(width: 10),
              icon!,
            ]
          ],
        );
      case KButtonStyle.pill:
      case KButtonStyle.thickPill:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) icon!,
            Text(
              label,
              style: TextStyle(fontSize: fontSize),
            ),
          ],
        );
      case KButtonStyle.regular:
      case KButtonStyle.expanded:
        return Row(
          mainAxisSize: style == KButtonStyle.expanded
              ? MainAxisSize.max
              : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Label(
              label,
              weight: weight,
              fontSize: fontSize,
              textAlign: TextAlign.center,
            ).regular,
            if (icon != null) ...[
              if (style == KButtonStyle.expanded) const Spacer(),
              if (style != KButtonStyle.expanded) const SizedBox(width: 10),
              icon!,
            ],
          ],
        );
    }
  }

  Widget _loadingIndicator(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getFg(context),
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "Loading...",
            style: TextStyle(
              fontSize: fontSize,
              fontVariations: [FontVariation.weight(weight)],
            ),
          ),
        ],
      );
}

enum KButtonStyle {
  regular,
  outlined,
  pill,
  thickPill,
  expanded,
}
