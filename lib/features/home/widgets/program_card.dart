import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/open_link.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../lead/lead_form_page.dart';
import '../../programs/program_detail_sheet.dart';

/// Ikon per `icon` program di config/site.php.
IconData programIcon(String? name) => switch (name) {
      'sparkle' => Icons.auto_awesome_rounded,
      'pencil' => Icons.edit_rounded,
      'palette' => Icons.palette_rounded,
      'sun' => Icons.wb_sunny_rounded,
      _ => Icons.brush_rounded,
    };

/// Kartu program yang bisa langsung ditindaklanjuti: Lihat Detail & Daftar.
class ProgramCard extends StatelessWidget {
  const ProgramCard({super.key, required this.program});

  final Program program;

  @override
  Widget build(BuildContext context) {
    final p = program;
    final accent = ProgramAccent.of(p.color);

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBubble(programIcon(p.icon), color: accent.dark, background: accent.soft, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: AppTextStyles.h3),
              if (p.age != null) Text(p.age!, style: AppTextStyles.bodySecondary),
            ]),
          ),
          if (p.isLive) const StatusBadge('Dibuka', tone: Tone.success, icon: Icons.circle),
        ]),
        const SizedBox(height: 12),
        if (p.price != null) InfoRow(icon: Icons.payments_outlined, iconColor: accent.dark, label: 'Biaya', value: p.price!),
        if (p.visitPrice != null)
          InfoRow(
            icon: Icons.confirmation_number_outlined,
            iconColor: accent.dark,
            label: 'Per pertemuan',
            value: p.visitPrice!.replaceAll(RegExp(r'\s*/\s*visit', caseSensitive: false), ''),
          ),
        if (p.scheduleSummary != null)
          InfoRow(icon: Icons.schedule_rounded, iconColor: accent.dark, label: 'Jadwal', value: p.scheduleSummary!),
        if (p.nextHoliday != null)
          InfoRow(
            icon: Icons.event_rounded,
            iconColor: accent.dark,
            label: 'Sesi terdekat',
            value: formatDateTime(p.nextHoliday!.startsAt),
          ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: SecondaryButton(
              label: 'Lihat Detail',
              expand: true,
              onPressed: () => showProgramDetail(context, p),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: p.canRegister
                ? PrimaryButton(label: 'Daftar', expand: true, onPressed: () => openLeadForm(context, program: p.slug))
                : PrimaryButton(
                    label: 'Tanya',
                    icon: Icons.chat_rounded,
                    expand: true,
                    onPressed: () => openWhatsApp(context, message: 'Halo, saya ingin bertanya tentang ${p.name}.'),
                  ),
          ),
        ]),
      ]),
    );
  }
}
