import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';

/// Tentang kami: pengantar dua kalimat, visi & misi dalam akordion.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.site});

  final Site site;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SectionHeader(title: 'Tentang kami'),
        AppCard(
          color: AppColors.secondarySoft,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const IconBubble(Icons.emoji_objects_rounded, color: AppColors.secondaryDark, background: Colors.white),
            const SizedBox(width: 14),
            Expanded(child: Text(AppStrings.aboutIntro, style: AppTextStyles.body)),
          ]),
        ),
        if (site.vision != null) ...[
          const SizedBox(height: 12),
          AccordionCard(
            icon: Icons.visibility_rounded,
            title: 'Visi',
            children: [Text(site.vision!, style: AppTextStyles.body)],
          ),
        ],
        if (site.mission.isNotEmpty) ...[
          const SizedBox(height: 12),
          AccordionCard(
            icon: Icons.flag_rounded,
            title: 'Misi',
            children: [
              for (final m in site.mission)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle_rounded, size: 20, color: AppColors.tertiary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(m, style: AppTextStyles.body)),
                  ]),
                ),
            ],
          ),
        ],
      ]),
    );
  }
}

/// Kartu akordion bergaya kartu (dipakai Tentang & FAQ).
class AccordionCard extends StatelessWidget {
  const AccordionCard({super.key, required this.title, required this.children, this.icon});

  final String title;
  final List<Widget> children;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: icon == null
              ? null
              : IconBubble(icon!, color: AppColors.primaryDark, background: AppColors.primarySoft, size: 38),
          title: Text(title, style: AppTextStyles.bodyStrong),
          iconColor: AppColors.primaryDark,
          collapsedIconColor: AppColors.textSecondary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          shape: const Border(),
          collapsedShape: const Border(),
          children: children,
        ),
      ),
    );
  }
}
