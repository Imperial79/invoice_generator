import 'package:flutter/material.dart';

import '../Resources/colors.dart';
import '../Resources/commons.dart';
import '../Resources/theme.dart';

class Label {
  final String text;
  final Color? color;
  final double? fontSize;
  final double? weight;
  final int? maxLines;
  final FontStyle? fontStyle;
  final double? height;
  final TextAlign? textAlign;
  final TextDecoration? decoration;

  Label(
    this.text, {
    this.color,
    this.fontSize,
    this.weight,
    this.maxLines,
    this.fontStyle,
    this.height,
    this.textAlign,
    this.decoration,
  });

  Widget get title => Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 20,
          color: color,
          fontVariations: [FontVariation.weight(weight ?? 700)],
          fontStyle: fontStyle,
          height: height,
          fontFamily: kFont,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
  Widget get subtitle => Text(
        text,
        style: TextStyle(
            fontSize: fontSize ?? 14,
            color: color ?? Kolor.fadeText,
            fontVariations: [FontVariation.weight(weight ?? 500)],
            fontStyle: fontStyle,
            height: height,
            decoration: decoration,
            fontFamily: kFont),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );

  Widget get spread => Center(
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            letterSpacing: 3,
            wordSpacing: 5,
            fontVariations: [FontVariation.weight(weight ?? 600)],
            fontSize: 14,
            fontStyle: fontStyle,
            height: height,
            color: color ?? Kolor.fadeText,
            fontFamily: kFont,
          ),
          textAlign: textAlign,
        ),
      );

  Widget get regular => Text(
        text,
        style: TextStyle(
          fontVariations: [FontVariation.weight(weight ?? 600)],
          color: color,
          fontSize: fontSize,
          fontStyle: fontStyle,
          height: height,
          fontFamily: kFont,
          decoration: decoration,
        ),
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
        textAlign: textAlign,
      );
  Widget get withDivider => Row(
        children: [
          Text(
            text.toUpperCase(),
            style: TextStyle(
              letterSpacing: .7,
              fontSize: fontSize,
              color: color,
              fontStyle: fontStyle,
              height: height,
              fontVariations: [FontVariation.weight(weight ?? 500)],
              fontFamily: kFont,
            ),
            textAlign: textAlign,
          ),
          width5,
          const Expanded(child: Divider())
        ],
      );
}
