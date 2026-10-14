import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/async_page.dart';
import '../../shared/widgets/section_header.dart';
import '../lead/lead_form_page.dart';
import 'widgets/about_section.dart';
import 'widgets/closing_cta.dart';
import 'widgets/faq_section.dart';
import 'widgets/gallery_carousel.dart';
import 'widgets/hero_section.dart';
import 'widgets/location_section.dart';
import 'widgets/program_card.dart';
import 'widgets/stats_bar.dart';
import 'widgets/steps_section.dart';
import 'widgets/testimonial_carousel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final siteController = context.read<SiteController>();

    return AsyncSliverPage<Site>(
      load: siteController.fetch,
      appBar: const _HomeAppBar(),
      padding: EdgeInsets.zero,
      spacing: 32,
      bottomSpace: 96, // ruang untuk tombol WhatsApp mengambang
      builder: (context, site, _) => [
        HeroSection(site: site, onRegister: () => openLeadForm(context)),
        StatsBar(stats: site.stats),
        GalleryCarousel(site: site, onSeeAll: () => onOpenTab(AppTab.gallery)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SectionHeader(
              title: 'Program kelas',
              subtitle: 'Pilih sesuai usia anak Anda',
              actionLabel: 'Lihat semua',
              onAction: () => onOpenTab(AppTab.programs),
            ),
            for (final p in site.programs) ...[ProgramCard(program: p), const SizedBox(height: 14)],
          ]),
        ),
        const StepsSection(),
        if (site.testimonials.isNotEmpty) TestimonialCarousel(items: site.testimonials),
        AboutSection(site: site),
        LocationSection(site: site),
        if (site.faq.isNotEmpty) FaqSection(faq: site.faq),
        ClosingCta(onPressed: () => openLeadForm(context, classType: 'visit')),
      ],
    );
  }
}

/// App bar ringkas yang muncul kembali saat menggulir ke atas.
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      toolbarHeight: 56,
      backgroundColor: AppColors.background,
      titleSpacing: 20,
      title: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(AppAssets.logo, width: 32, height: 32, excludeFromSemantics: true),
        ),
        const SizedBox(width: 10),
        Flexible(child: Text(AppStrings.appName, style: AppTextStyles.h3, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
