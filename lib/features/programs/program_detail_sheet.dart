import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/info_row.dart';
import '../../shared/widgets/open_link.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/status_badge.dart';
import '../home/widgets/program_card.dart';
import '../lead/lead_form_page.dart';

/// Lembar bawah berisi rincian lengkap satu program.
void showProgramDetail(BuildContext context, Program p) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scroll) => _ProgramDetail(program: p, controller: scroll),
    ),
  );
}

class _ProgramDetail extends StatelessWidget {
  const _ProgramDetail({required this.program, required this.controller});

  final Program program;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final p = program;
    final accent = ProgramAccent.of(p.color);

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Row(children: [
          IconBubble(programIcon(p.icon), color: accent.dark, background: accent.soft, size: 60),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: AppTextStyles.h1),
              if (p.age != null) Text('Usia ${p.age}', style: AppTextStyles.bodySecondary),
            ]),
          ),
          if (p.isLive) const StatusBadge('Dibuka', tone: Tone.success),
        ]),
        if (p.summary != null) ...[
          const SizedBox(height: 16),
          Text(p.summary!, style: AppTextStyles.body),
        ],
        if (p.highlights.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('YANG DIPELAJARI', style: AppTextStyles.label),
          const SizedBox(height: 8),
          for (final h in p.highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(Icons.check_circle_rounded, color: accent.dark, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(h, style: AppTextStyles.body)),
              ]),
            ),
        ],
        const SizedBox(height: 12),
        AppCard(
          child: Column(children: [
            if (p.price != null) InfoRow(icon: Icons.payments_outlined, label: 'Biaya', value: p.price!),
            if (p.visitPrice != null)
              InfoRow(
                icon: Icons.confirmation_number_outlined,
                label: 'Per pertemuan',
                value: p.visitPrice!.replaceAll(RegExp(r'\s*/\s*visit', caseSensitive: false), ''),
              ),
            if (p.duration != null) InfoRow(icon: Icons.timer_outlined, label: 'Durasi', value: p.duration!),
            if (p.capacity != null) InfoRow(icon: Icons.groups_outlined, label: 'Kapasitas', value: p.capacity!),
            if (p.schedule ?? p.scheduleSummary case final s?) InfoRow(icon: Icons.schedule_rounded, label: 'Jadwal', value: s),
            if (p.nextHoliday != null)
              InfoRow(icon: Icons.event_rounded, label: 'Sesi terdekat', value: formatDateTime(p.nextHoliday!.startsAt)),
          ]),
        ),
        const SizedBox(height: 20),
        if (p.canRegister)
          PrimaryButton(
            label: 'Daftar ${p.name}',
            icon: Icons.edit_note_rounded,
            expand: true,
            onPressed: () {
              Navigator.pop(context);
              openLeadForm(context, program: p.slug);
            },
          )
        else
          PrimaryButton(
            label: 'Tanya via WhatsApp',
            icon: Icons.chat_rounded,
            expand: true,
            onPressed: () => openWhatsApp(context, message: 'Halo, saya ingin bertanya tentang ${p.name}.'),
          ),
        if (!p.isLive && !p.isHoliday) ...[
          const SizedBox(height: 10),
          Text(
            'Angka di atas perkiraan. Admin akan mengonfirmasi jadwal & biaya terbaru.',
            textAlign: TextAlign.center,
            style: AppTextStyles.small,
          ),
        ],
      ],
    );
  }
}
