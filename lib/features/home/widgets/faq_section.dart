import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/section_header.dart';
import 'about_section.dart';

/// Pertanyaan umum dalam akordion. [limit] membatasi jumlah di Beranda.
class FaqSection extends StatelessWidget {
  const FaqSection({super.key, required this.faq, this.limit = 4});

  final List<({String q, String a})> faq;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SectionHeader(title: 'Pertanyaan umum'),
        for (final f in faq.take(limit)) ...[
          AccordionCard(title: f.q, children: [Text(f.a, style: AppTextStyles.bodySecondary)]),
          const SizedBox(height: 10),
        ],
      ]),
    );
  }
}
