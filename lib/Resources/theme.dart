import 'package:flutter/material.dart';
import 'package:invoice_generator/Resources/colors.dart';

const String kFont = "Inter";

ThemeData kTheme(BuildContext context, {ColorScheme? lightDynamic, Brightness brightness = Brightness.light}) {
  ColorScheme scheme = lightDynamic ?? ColorScheme.fromSeed(
    seedColor: Kolor.primary,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    brightness: brightness,
  );

  return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: kFont,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
        ),
      ),
      appBarTheme: AppBarTheme(
        actionsIconTheme: const IconThemeData(
          color: Kolor.fadeText,
        ),
        surfaceTintColor: scheme.primary,
        backgroundColor: scheme.surface,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        selectedColor: scheme.secondary,
        labelStyle: TextStyle(
          color: brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: scheme.primary,
        largeSize: 20,
        textStyle: const TextStyle(
          fontSize: 15,
          fontVariations: [FontVariation.weight(600)],
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: scheme.primary,
        cursorColor: scheme.primary,
        selectionColor: scheme.secondaryContainer,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.secondary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
        refreshBackgroundColor: scheme.surfaceContainerHighest,
      ),
    );
}

ThemeData kDarkTheme(BuildContext context, {ColorScheme? darkDynamic}) {
  return kTheme(context, lightDynamic: darkDynamic, brightness: Brightness.dark);
}

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
