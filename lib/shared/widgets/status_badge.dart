import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum Tone { neutral, success, warning, danger, info }

/// Pill status kecil, mis. "Dibuka", "Lunas", "Telat 3 hari".
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.tone = Tone.neutral, this.icon});

  final String label;
  final Tone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      Tone.success => (AppColors.successSoft, AppColors.success),
      Tone.warning => (AppColors.secondarySoft, AppColors.secondaryDark),
      Tone.danger => (AppColors.dangerSoft, AppColors.danger),
      Tone.info => (AppColors.skySoft, AppColors.skyDark),
      Tone.neutral => (AppColors.surfaceMuted, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
        Flexible(child: Text(label, style: AppTextStyles.smallStrong.copyWith(color: fg))),
      ]),
    );
  }
}
