import 'package:flutter/material.dart';

/// Warna disamakan dengan website publik (public/css/site.css, variabel --tac-*).
abstract final class TacColors {
  static const paper = Color(0xFFFFFBF3);
  static const paperLight = Color(0xFFFFFDF8);
  static const paper2 = Color(0xFFFCF2E4);
  static const ink = Color(0xFF2C2A33);
  static const inkSoft = Color(0xFF6B6670);
  static const line = Color(0x142C2A33);
  static const lineStrong = Color(0x242C2A33);

  static const coral = Color(0xFFF26C5A);
  static const coralLight = Color(0xFFF9A99B);
  static const coralDark = Color(0xFFC8442F);
  static const sun = Color(0xFFFFC24B);
  static const sunLight = Color(0xFFFFE1A0);
  static const sunDark = Color(0xFFD9971C);
  static const sky = Color(0xFF5EA3DE);
  static const skyLight = Color(0xFFB9D9F3);
  static const skyDark = Color(0xFF2F72B5);
  static const leaf = Color(0xFF7FB894);
  static const leafLight = Color(0xFFCBE3D2);
  static const leafDark = Color(0xFF3F7C57);
  static const grape = Color(0xFF9A86D6);
  static const grapeLight = Color(0xFFDED6F4);
  static const grapeDark = Color(0xFF5F4CA8);
}

/// Pasangan warna per `color` program di config/site.php.
class Accent {
  const Accent(this.base, this.light, this.dark);

  final Color base;
  final Color light;
  final Color dark;

  static Accent of(String? name) => switch (name) {
        'sun' => const Accent(TacColors.sun, TacColors.sunLight, TacColors.sunDark),
        'sky' => const Accent(TacColors.sky, TacColors.skyLight, TacColors.skyDark),
        'leaf' => const Accent(TacColors.leaf, TacColors.leafLight, TacColors.leafDark),
        'grape' => const Accent(TacColors.grape, TacColors.grapeLight, TacColors.grapeDark),
        _ => const Accent(TacColors.coral, TacColors.coralLight, TacColors.coralDark),
      };
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: TacColors.coral,
    primary: TacColors.coral,
    onPrimary: Colors.white,
    surface: TacColors.paper,
    onSurface: TacColors.ink,
  );

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: TacColors.lineStrong),
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: TacColors.paper,
    appBarTheme: const AppBarTheme(
      backgroundColor: TacColors.paper,
      foregroundColor: TacColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: TacColors.ink, fontSize: 20, fontWeight: FontWeight.w800),
    ),
    cardTheme: CardThemeData(
      color: TacColors.paperLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: TacColors.line),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: TacColors.paperLight,
      indicatorColor: TacColors.coralLight.withValues(alpha: 0.45),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        foregroundColor: TacColors.coralDark,
        side: const BorderSide(color: TacColors.coral, width: 1.5),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TacColors.paperLight,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(borderSide: const BorderSide(color: TacColors.coral, width: 1.5)),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: TacColors.paperLight,
      selectedColor: TacColors.ink,
      secondarySelectedColor: TacColors.ink,
      side: BorderSide(color: TacColors.lineStrong),
      showCheckmark: false,
    ),
  );
}
