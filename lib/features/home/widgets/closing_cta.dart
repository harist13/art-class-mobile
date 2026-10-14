import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/decorations.dart';
import '../../../shared/widgets/primary_button.dart';

/// Banner gradient coral penutup halaman.
class ClosingCta extends StatelessWidget {
  const ClosingCta({
    super.key,
    required this.onPressed,
    this.title = AppStrings.closingTitle,
    this.body = AppStrings.closingBody,
    this.buttonLabel = 'Daftar Trial',
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final VoidCallback onPressed;
  final String title;
  final String body;
  final String buttonLabel;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Stack(children: [
            Positioned(right: -40, top: -50, child: Blob(color: Colors.white.withValues(alpha: 0.14), size: 170, seed: 5)),
            Positioned(left: -30, bottom: -60, child: Blob(color: AppColors.secondary.withValues(alpha: 0.35), size: 150, seed: 9)),
            const Positioned(right: 24, bottom: 24, child: Sparkle(color: Colors.white, size: 18)),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppTextStyles.h1.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(body, style: AppTextStyles.body.copyWith(color: Colors.white)),
                const SizedBox(height: 18),
                PrimaryButton(label: buttonLabel, icon: Icons.arrow_forward_rounded, light: true, onPressed: onPressed),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
