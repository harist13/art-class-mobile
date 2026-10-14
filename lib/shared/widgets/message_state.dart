import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_card.dart';
import 'decorations.dart';

/// Pesan kosong / galat / terkunci, dengan ikon di atas blob dekoratif.
class MessageState extends StatelessWidget {
  const MessageState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(alignment: Alignment.center, children: [
            Blob(color: color.withValues(alpha: 0.16), size: 96, seed: icon.codePoint),
            Icon(icon, size: 40, color: color),
          ]),
        ),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.h3),
        if (body != null) ...[
          const SizedBox(height: 6),
          Text(body!, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
        ],
        if (action != null) ...[const SizedBox(height: 18), action!],
      ]),
    );
  }
}
