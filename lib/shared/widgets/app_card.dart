import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'pressable.dart';

/// Kartu putih membulat dengan bayangan lembut berlapis.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.color = AppColors.surface,
    this.accent,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;

  /// Garis warna di sisi kiri kartu (mis. status tagihan).
  final Color? accent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget body = Padding(padding: padding, child: child);
    if (accent != null) {
      body = DecoratedBox(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: accent!, width: 6))),
        child: body,
      );
    }

    final card = DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24), boxShadow: AppColors.cardShadow),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? body : InkWell(onTap: onTap, child: body),
      ),
    );

    if (onTap == null) return card;
    return Semantics(button: true, label: semanticLabel, child: PressableScale(child: card));
  }
}

/// Wadah ikon membulat berwarna lembut.
class IconBubble extends StatelessWidget {
  const IconBubble(this.icon, {super.key, required this.color, required this.background, this.size = 44});

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size * 0.36)),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}
