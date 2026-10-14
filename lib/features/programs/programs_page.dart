import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/async_page.dart';
import '../../shared/widgets/page_app_bar.dart';
import '../home/widgets/closing_cta.dart';
import '../home/widgets/program_card.dart';
import '../lead/lead_form_page.dart';

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return AsyncSliverPage<List<Program>>(
      load: repo.programs,
      appBar: const PageAppBar(title: 'Program Kelas', showBack: false),
      spacing: 14,
      bottomSpace: 96,
      builder: (context, programs, _) => [
        AppCard(
          color: AppColors.tertiarySoft,
          child: Row(children: [
            const IconBubble(Icons.info_outline_rounded, color: AppColors.tertiaryDark, background: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Biaya, kapasitas, dan jadwal diambil langsung dari kelas yang sedang dibuka.',
                style: AppTextStyles.body.copyWith(color: AppColors.text),
              ),
            ),
          ]),
        ),
        for (final p in programs) ProgramCard(program: p),
        const SizedBox(height: 6),
        ClosingCta(
          title: 'Belum yakin pilih yang mana?',
          body: 'Isi form singkat, admin kami bantu memilihkan program sesuai usia & minat anak Anda.',
          buttonLabel: 'Tanya Program',
          padding: EdgeInsets.zero,
          onPressed: () => openLeadForm(context),
        ),
      ],
    );
  }
}
