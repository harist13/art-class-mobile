import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'decorations.dart';
import 'open_link.dart';

/// Tombol mengambang "Tanya via WA". Halaman yang memakainya menyisakan ruang
/// di bawah (bottomSpace) supaya konten terakhir tidak tertutup.
class WhatsAppFab extends StatelessWidget {
  const WhatsAppFab({super.key, this.compact = false});

  /// Hanya ikon, tanpa label — dipakai di tab selain Beranda dan saat Beranda
  /// sudah digulir, supaya tidak menutupi konten.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const label = 'Tanya via WA';
    return Tooltip(
      message: 'Chat admin lewat WhatsApp',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
        child: compact
            ? FloatingActionButton(
                key: const ValueKey('compact'),
                heroTag: null, // dua FAB sempat tampil bersamaan saat berganti; tanpa Hero
                onPressed: () => openWhatsApp(context),
                backgroundColor: AppColors.whatsapp,
                shape: const CircleBorder(),
                child: const WhatsAppIcon(size: 26),
              )
            : FloatingActionButton.extended(
                key: const ValueKey('extended'),
                heroTag: null, // dua FAB sempat tampil bersamaan saat berganti; tanpa Hero
                onPressed: () => openWhatsApp(context),
                backgroundColor: AppColors.whatsapp,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                icon: const WhatsAppIcon(size: 24),
                label: Text(label, style: AppTextStyles.bodyStrong.copyWith(color: Colors.white)),
              ),
      ),
    );
  }
}
