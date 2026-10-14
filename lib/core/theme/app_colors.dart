import 'package:flutter/material.dart';

/// Palet aplikasi: hangat & playful. Kontras teks diperiksa terhadap latar krem
/// dan putih (teks utama ±15:1, teks sekunder ±6:1 — lolos WCAG AA).
abstract final class AppColors {
  static const primary = Color(0xFFF26B5B); // coral
  static const primaryDark = Color(0xFFC94A3B); // coral untuk teks/ikon di atas latar terang
  static const primarySoft = Color(0xFFFDE3DF);
  static const secondary = Color(0xFFFFC857); // kuning hangat
  static const secondaryDark = Color(0xFF9A6B00);
  static const secondarySoft = Color(0xFFFFF1CC);
  static const tertiary = Color(0xFF4FB6A5); // teal lembut
  static const tertiaryDark = Color(0xFF1F7466);
  static const tertiarySoft = Color(0xFFDDF2EE);
  static const sky = Color(0xFF5EA3DE);
  static const skyDark = Color(0xFF2F6FA8);
  static const skySoft = Color(0xFFDCEBF8);
  static const grape = Color(0xFF9A86D6);
  static const grapeSoft = Color(0xFFECE7FA);

  static const background = Color(0xFFFFF8F0); // krem
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFFBEFE3);
  static const text = Color(0xFF2B2420);
  static const textSecondary = Color(0xFF6B5F57);
  static const outline = Color(0x1F2B2420);

  static const success = Color(0xFF2E8B57);
  static const successSoft = Color(0xFFDDF3E6);
  static const danger = Color(0xFFC0392B);
  static const dangerSoft = Color(0xFFFCE1DD);
  static const whatsapp = Color(0xFF25D366);
  static const whatsappDark = Color(0xFF128C7E);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A6B), primary, Color(0xFFE5534B)],
  );

  /// Bayangan lembut berlapis untuk kartu.
  static const cardShadow = [
    BoxShadow(color: Color(0x0D2B2420), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x142B2420), blurRadius: 24, offset: Offset(0, 10), spreadRadius: -6),
  ];
}

/// Pasangan warna per `color` program di config/site.php (sun, sky, coral, leaf).
class ProgramAccent {
  const ProgramAccent(this.base, this.soft, this.dark);

  final Color base;
  final Color soft;
  final Color dark;

  static ProgramAccent of(String? name) => switch (name) {
        'sun' => const ProgramAccent(AppColors.secondary, AppColors.secondarySoft, AppColors.secondaryDark),
        'sky' => const ProgramAccent(AppColors.sky, AppColors.skySoft, AppColors.skyDark),
        'leaf' => const ProgramAccent(AppColors.tertiary, AppColors.tertiarySoft, AppColors.tertiaryDark),
        'grape' => const ProgramAccent(AppColors.grape, AppColors.grapeSoft, Color(0xFF5F4CA8)),
        _ => const ProgramAccent(AppColors.primary, AppColors.primarySoft, AppColors.primaryDark),
      };
}
