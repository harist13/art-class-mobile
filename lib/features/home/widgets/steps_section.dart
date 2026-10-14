import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/decorations.dart';
import '../../../shared/widgets/section_header.dart';

/// Alur pendaftaran tiga langkah dengan garis penghubung putus-putus.
class StepsSection extends StatelessWidget {
  const StepsSection({super.key});

  static const _icons = [Icons.touch_app_rounded, Icons.event_available_rounded, Icons.brush_rounded];
  static const _colors = [
    (AppColors.primary, AppColors.primarySoft),
    (AppColors.secondaryDark, AppColors.secondarySoft),
    (AppColors.tertiaryDark, AppColors.tertiarySoft),
  ];

  @override
  Widget build(BuildContext context) {
    const bubble = 56.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SectionHeader(title: 'Cara mendaftar', subtitle: 'Tiga langkah mudah'),
        AppCard(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 18),
          child: LayoutBuilder(builder: (context, c) {
            final third = c.maxWidth / 3;
            return Stack(children: [
              // Garis di belakang lingkaran, dari tengah langkah 1 ke tengah langkah 3.
              Positioned(
                top: bubble / 2 - 1,
                left: third / 2 + bubble / 2,
                right: third / 2 + bubble / 2,
                child: const DashedLine(color: AppColors.primary),
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var i = 0; i < AppStrings.steps.length; i++)
                  Expanded(
                    child: Semantics(
                      label: 'Langkah ${i + 1}: ${AppStrings.steps[i].title}. ${AppStrings.steps[i].body}',
                      excludeSemantics: true,
                      child: Column(children: [
                        Stack(clipBehavior: Clip.none, children: [
                          Container(
                            width: bubble,
                            height: bubble,
                            decoration: BoxDecoration(
                              color: _colors[i].$2,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Icon(_icons[i], color: _colors[i].$1, size: 26),
                          ),
                          Positioned(
                            right: -4,
                            top: -4,
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: _colors[i].$1,
                              child: Text('${i + 1}', style: AppTextStyles.smallStrong.copyWith(color: Colors.white)),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Text(AppStrings.steps[i].title, textAlign: TextAlign.center, style: AppTextStyles.bodyStrong),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(AppStrings.steps[i].body, textAlign: TextAlign.center, style: AppTextStyles.small),
                        ),
                      ]),
                    ),
                  ),
              ]),
            ]);
          }),
        ),
      ]),
    );
  }
}
