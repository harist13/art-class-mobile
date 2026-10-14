import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/decorations.dart';
import '../../../shared/widgets/net_image.dart';
import '../../../shared/widgets/open_link.dart';
import '../../../shared/widgets/primary_button.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.site, required this.onRegister});

  final Site site;
  final VoidCallback onRegister;

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dekorasi latar: blob & kilau kecil.
        Positioned(right: -60, top: -40, child: Blob(color: AppColors.secondary.withValues(alpha: 0.35), size: 220, seed: 3)),
        Positioned(left: -70, top: 150, child: Blob(color: AppColors.tertiary.withValues(alpha: 0.18), size: 160, seed: 8)),
        const Positioned(right: 36, top: 96, child: Sparkle(color: AppColors.primary, size: 16)),
        const Positioned(left: 8, top: 72, child: Sparkle(size: 12)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo & nama sudah di app bar; di sini cukup sapaan.
              Text('${_greeting()}, Ayah & Bunda 👋', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: AppStrings.heroTitleStart),
                  TextSpan(
                    text: AppStrings.heroTitleHighlight,
                    style: AppTextStyles.hero.copyWith(color: AppColors.primary),
                  ),
                ]),
                style: AppTextStyles.hero,
              ),
              const SizedBox(height: 4),
              const CrayonUnderline(width: 120, height: 10),
              const SizedBox(height: 10),
              Text(AppStrings.heroSubtitle, style: AppTextStyles.bodySecondary, maxLines: 2),
              const SizedBox(height: 20),
              _Collage(site: site),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Daftar Sekarang',
                    icon: Icons.edit_note_rounded,
                    onPressed: onRegister,
                    expand: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SecondaryButton(
                    label: 'Chat WhatsApp',
                    iconWidget: const WhatsAppIcon(size: 20, color: AppColors.whatsappDark, phoneColor: Colors.white),
                    color: AppColors.whatsappDark,
                    onPressed: () => openWhatsApp(context),
                    expand: true,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kolase tiga gambar membulat dengan rotasi kecil yang saling menumpuk.
/// Sumber gambar: AppAssets.heroImages → foto galeri terbaru → ilustrasi bentuk.
class _Collage extends StatelessWidget {
  const _Collage({required this.site});

  final Site site;

  @override
  Widget build(BuildContext context) {
    final placeholders = [
      const ArtPlaceholder(icon: Icons.palette_rounded, color: AppColors.primary, background: AppColors.primarySoft),
      const ArtPlaceholder(icon: Icons.brush_rounded, color: AppColors.tertiaryDark, background: AppColors.tertiarySoft),
      const ArtPlaceholder(icon: Icons.draw_rounded, color: AppColors.secondaryDark, background: AppColors.secondarySoft),
    ];

    Widget tile(int i) {
      if (i < AppAssets.heroImages.length) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(AppAssets.heroImages[i], fit: BoxFit.cover),
        );
      }
      if (AppAssets.heroImages.isEmpty && i < site.galleryPreview.length) {
        return NetImage(site.galleryPreview[i].url, radius: 24, semanticLabel: 'Karya murid');
      }
      return placeholders[i];
    }

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final size = w * 0.42;
      return SizedBox(
        height: size * 1.18,
        child: Stack(children: [
          _tilted(left: 0, top: size * 0.12, size: size, angle: -0.08, child: tile(1)),
          _tilted(left: w - size, top: size * 0.16, size: size, angle: 0.09, child: tile(2)),
          _tilted(left: (w - size * 1.1) / 2, top: 0, size: size * 1.1, angle: -0.02, child: tile(0)),
        ]),
      );
    });
  }

  Widget _tilted({required double left, required double top, required double size, required double angle, required Widget child}) {
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: Transform.rotate(
        angle: angle,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: AppColors.cardShadow,
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(22), child: child),
        ),
      ),
    );
  }
}
