import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Baris informasi dengan ikon: "💰 Biaya ........ Rp400.000 / bulan".
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.icon, this.iconColor});

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, c) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
            ],
            // Label memakai lebar alaminya, paling banyak separuh baris; nilai
            // mengisi sisanya. Keduanya membungkus baris bila perlu (360dp, teks 1.3×).
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: c.maxWidth * 0.5),
              child: Text(label, style: AppTextStyles.bodySecondary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(value, textAlign: TextAlign.right, style: AppTextStyles.bodyStrong)),
          ],
        ),
      ),
    );
  }
}
