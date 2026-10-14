import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'pressable.dart';

/// Tombol utama: gradient coral, sudut membulat, efek tekan.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.light = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  /// Lebar penuh.
  final bool expand;

  /// Versi putih untuk dipakai di atas latar coral (banner CTA).
  final bool light;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final fg = light ? AppColors.primaryDark : Colors.white;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: fg))
        else ...[
          if (icon != null) ...[Icon(icon, color: fg, size: 20), const SizedBox(width: 8)],
          Flexible(child: Text(label, style: AppTextStyles.button.copyWith(color: fg), textAlign: TextAlign.center)),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: PressableScale(
        enabled: enabled,
        child: AnimatedOpacity(
          opacity: enabled || loading ? 1 : 0.5,
          duration: const Duration(milliseconds: 150),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: light ? null : AppColors.primaryGradient,
              color: light ? Colors.white : null,
              borderRadius: BorderRadius.circular(18),
              boxShadow: light || !enabled
                  ? null
                  : const [BoxShadow(color: Color(0x40F26B5B), blurRadius: 16, offset: Offset(0, 6))],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: enabled ? onPressed : null,
                borderRadius: BorderRadius.circular(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52, minWidth: 48),
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12), child: content),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol sekunder bergaris, dipisah jelas dari tombol utama.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    this.expand = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? iconWidget;
  final bool expand;

  /// Warna garis & teks; bawaan coral.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryDark;
    final style = OutlinedButton.styleFrom(
      foregroundColor: c,
      side: BorderSide(color: color ?? AppColors.primary, width: 1.6),
      backgroundColor: Colors.white,
      minimumSize: Size(expand ? double.infinity : 48, 52),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
    final leading = iconWidget ?? (icon == null ? null : Icon(icon, size: 20));

    return PressableScale(
      enabled: onPressed != null,
      child: leading == null
          ? OutlinedButton(onPressed: onPressed, style: style, child: Text(label, textAlign: TextAlign.center))
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: style,
              icon: leading,
              label: Text(label, textAlign: TextAlign.center),
            ),
    );
  }
}
