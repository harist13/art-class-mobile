import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Heading memakai Baloo 2 (playful), isi memakai Nunito (mudah dibaca).
/// Ukuran isi minimal 15sp dengan line-height 1.5.
abstract final class AppTextStyles {
  static TextStyle _display(double size, {FontWeight weight = FontWeight.w800, Color color = AppColors.text}) =>
      GoogleFonts.baloo2(fontSize: size, fontWeight: weight, height: 1.15, color: color);

  static TextStyle _body(double size, {FontWeight weight = FontWeight.w500, Color color = AppColors.text}) =>
      GoogleFonts.nunito(fontSize: size, fontWeight: weight, height: 1.5, color: color);

  static final hero = _display(32);
  static final h1 = _display(26);
  static final h2 = _display(22, weight: FontWeight.w700);
  static final h3 = _display(18, weight: FontWeight.w700);
  static final number = _display(30);

  static final body = _body(15);
  static final bodyStrong = _body(15, weight: FontWeight.w700);
  static final bodySecondary = _body(15, color: AppColors.textSecondary);
  static final small = _body(13, color: AppColors.textSecondary);
  static final smallStrong = _body(13, weight: FontWeight.w700);
  static final label = _body(12, weight: FontWeight.w800, color: AppColors.textSecondary).copyWith(letterSpacing: 0.8);
  static final button = _body(16, weight: FontWeight.w800);

  static TextTheme textTheme() {
    final base = GoogleFonts.nunitoTextTheme().apply(bodyColor: AppColors.text, displayColor: AppColors.text);
    return base.copyWith(
      displaySmall: hero,
      headlineMedium: h1,
      headlineSmall: h2,
      titleLarge: h3,
      titleMedium: _body(16, weight: FontWeight.w700),
      bodyLarge: _body(16),
      bodyMedium: body,
      bodySmall: small,
      labelLarge: button,
    );
  }
}
