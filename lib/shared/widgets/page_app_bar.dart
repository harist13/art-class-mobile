import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// App bar sliver dengan judul besar yang menyusut halus saat digulir.
class PageAppBar extends StatelessWidget {
  const PageAppBar({super.key, required this.title, this.actions, this.bottom, this.showBack});

  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  /// null = otomatis (muncul bila halaman bisa kembali).
  final bool? showBack;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: showBack ?? true,
      title: Text(title, style: AppTextStyles.h1, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: actions,
      bottom: bottom,
    );
  }
}
