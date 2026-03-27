import 'package:flutter/material.dart';
import '../Resources/colors.dart';
import '../Resources/commons.dart';
import '../Resources/theme.dart';

enum _LabelType { title, subtitle, regular, spread, withDivider }

class Label extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final double? weight;
  final int? maxLines;
  final FontStyle? fontStyle;
  final double? height;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final _LabelType _type;

  const Label(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.weight,
    this.maxLines,
    this.fontStyle,
    this.height,
    this.textAlign,
    this.decoration,
  }) : _type = _LabelType.regular;

  const Label._internal(
    this.text,
    this._type, {
    this.color,
    this.fontSize,
    this.weight,
    this.maxLines,
    this.fontStyle,
    this.height,
    this.textAlign,
    this.decoration,
  });

  Label get title => Label._internal(
    text,
    _LabelType.title,
    color: color,
    fontSize: fontSize,
    weight: weight,
    maxLines: maxLines,
    fontStyle: fontStyle,
    height: height,
    textAlign: textAlign,
    decoration: decoration,
  );

  Label get subtitle => Label._internal(
    text,
    _LabelType.subtitle,
    color: color,
    fontSize: fontSize,
    weight: weight,
    maxLines: maxLines,
    fontStyle: fontStyle,
    height: height,
    textAlign: textAlign,
    decoration: decoration,
  );

  Label get spread => Label._internal(
    text,
    _LabelType.spread,
    color: color,
    fontSize: fontSize,
    weight: weight,
    maxLines: maxLines,
    fontStyle: fontStyle,
    height: height,
    textAlign: textAlign,
    decoration: decoration,
  );

  Label get regular => Label._internal(
    text,
    _LabelType.regular,
    color: color,
    fontSize: fontSize,
    weight: weight,
    maxLines: maxLines,
    fontStyle: fontStyle,
    height: height,
    textAlign: textAlign,
    decoration: decoration,
  );

  Label get withDivider => Label._internal(
    text,
    _LabelType.withDivider,
    color: color,
    fontSize: fontSize,
    weight: weight,
    maxLines: maxLines,
    fontStyle: fontStyle,
    height: height,
    textAlign: textAlign,
    decoration: decoration,
  );

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case _LabelType.title:
        return Text(
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
      case _LabelType.subtitle:
        return Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? 14,
            color: color ?? kColor(context).onSurfaceVariant,
            fontVariations: [FontVariation.weight(weight ?? 500)],
            fontStyle: fontStyle,
            height: height,
            decoration: decoration,
            fontFamily: kFont,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
        );
      case _LabelType.spread:
        return Center(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              letterSpacing: 3,
              wordSpacing: 5,
              fontVariations: [FontVariation.weight(weight ?? 600)],
              fontSize: 14,
              fontStyle: fontStyle,
              height: height,
              color: color ?? kColor(context).onSurfaceVariant,
              fontFamily: kFont,
            ),
            textAlign: textAlign,
          ),
        );
      case _LabelType.regular:
        return Text(
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
      case _LabelType.withDivider:
        return Row(
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
            Expanded(
              child: Divider(
                color: kColor(context).outlineVariant,
                thickness: .5,
              ),
            ),
          ],
        );
    }
  }
}
