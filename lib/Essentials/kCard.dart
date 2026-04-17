import 'package:flutter/material.dart';

import '../Resources/colors.dart';
import '../Resources/commons.dart';

class KCard extends StatelessWidget {
  final void Function()? onTap;
  final Widget? child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderWidth;
  final Color? color;
  final Color? borderColor;
  const KCard({
    super.key,
    this.onTap,
    this.radius = 20,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: kRadius(radius),
            color: color ?? kColor(context).surfaceContainerLow,
            border: Border.all(
              color: borderColor ?? kColor(context).outlineVariant.withAlpha(80),
              width: borderWidth,
            )),
        child: child,
      ),
    );
  }
}
