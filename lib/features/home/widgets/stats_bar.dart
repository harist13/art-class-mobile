import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';

/// Tiga kartu kepercayaan. Dua dari statistik website, satu tetap
/// ("Semi private") karena itu ciri kelasnya, bukan angka yang berubah.
class StatsBar extends StatelessWidget {
  const StatsBar({super.key, required this.stats});

  final List<({String value, String label})> stats;

  @override
  Widget build(BuildContext context) {
    const styles = [
      (Icons.event_available_rounded, AppColors.primary, AppColors.primarySoft),
      (Icons.groups_rounded, AppColors.tertiaryDark, AppColors.tertiarySoft),
      (Icons.favorite_rounded, AppColors.secondaryDark, AppColors.secondarySoft),
    ];

    // Label website memuat keterangan dalam kurung; di kartu kecil cukup intinya.
    final items = [
      for (final s in stats.take(2)) (value: s.value, label: s.label.replaceAll(RegExp(r'\s*\(.*?\)'), '')),
      (value: 'Kecil', label: 'Kelas semi private'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    IconBubble(styles[i % 3].$1, color: styles[i % 3].$2, background: styles[i % 3].$3, size: 36),
                    const SizedBox(height: 8),
                    _CountUp(items[i].value, color: styles[i % 3].$2),
                    Text(items[i].label, style: AppTextStyles.small.copyWith(color: AppColors.text)),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Angka yang menghitung naik saat pertama tampil; teks non-angka ("3-4")
/// tampil apa adanya.
class _CountUp extends StatelessWidget {
  const _CountUp(this.value, {required this.color});

  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.number.copyWith(color: color, fontSize: 26);
    final n = int.tryParse(value);
    if (n == null) return Text(value, style: style);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: n.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text('${v.round()}', style: style, semanticsLabel: value),
    );
  }
}
