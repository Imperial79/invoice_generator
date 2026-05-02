import 'package:flutter/material.dart';
import 'package:prime_invoice/Resources/colors.dart';

const String kFont = "Inter";

ThemeData kTheme(
  BuildContext context, {
  ColorScheme? lightDynamic,
  Brightness brightness = Brightness.light,
}) {
  ColorScheme scheme =
      lightDynamic ??
      ColorScheme.fromSeed(
        seedColor: Kolor.secondary,
        primary: Kolor.primary,
        secondary: Kolor.secondary,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
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
        shape: const RoundedRectangleBorder(),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const RoundedRectangleBorder(),
      ),
    ),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero),
    ),
    appBarTheme: AppBarTheme(
      actionsIconTheme: const IconThemeData(color: Kolor.fadeText),
      surfaceTintColor: scheme.primary,
      backgroundColor: scheme.surface,
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      selectedColor: scheme.secondary,
      shape: const RoundedRectangleBorder(),
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
  return kTheme(
    context,
    lightDynamic: darkDynamic,
    brightness: Brightness.dark,
  );
}

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
