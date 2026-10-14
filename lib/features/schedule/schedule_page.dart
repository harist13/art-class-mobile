import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/async_page.dart';
import '../../shared/widgets/message_state.dart';
import '../../shared/widgets/page_app_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_badge.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return AsyncSliverPage<Schedule>(
      load: repo.schedule,
      appBar: const PageAppBar(title: 'Jadwal Kelas', showBack: false),
      bottomSpace: 96,
      builder: (context, data, _) => [
        if (data.days.isEmpty)
          const MessageState(
            icon: Icons.event_busy_rounded,
            title: 'Belum ada slot terjadwal',
            body: 'Jadwal angkatan berikutnya sedang disusun. Hubungi admin untuk info terbaru.',
          )
        else
          _DayBrowser(days: data.days, until: data.until),
        if (data.holidayClasses.isNotEmpty)
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SectionHeader(title: 'Holiday Class', subtitle: 'Kelas spesial saat libur sekolah'),
            for (final h in data.holidayClasses) ...[
              AppCard(
                color: AppColors.secondarySoft,
                child: Row(children: [
                  const IconBubble(Icons.wb_sunny_rounded, color: AppColors.secondaryDark, background: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(h.name, style: AppTextStyles.bodyStrong),
                      Text(formatDateTime(h.startsAt), style: AppTextStyles.small.copyWith(color: AppColors.text)),
                    ]),
                  ),
                  if (h.price != null) StatusBadge(rupiah(h.price!), tone: Tone.warning),
                ]),
              ),
              const SizedBox(height: 10),
            ],
          ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SectionHeader(title: 'Jadwal umum', subtitle: 'Pola mingguan tiap program'),
          AppCard(
            child: Column(children: [
              for (var i = 0; i < data.programs.length; i++) ...[
                if (i > 0) const Divider(height: 20, color: AppColors.outline),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 7, right: 12),
                    decoration: BoxDecoration(color: ProgramAccent.of(data.programs[i].color).base, shape: BoxShape.circle),
                  ),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(data.programs[i].name, style: AppTextStyles.bodyStrong),
                      Text(data.programs[i].schedule ?? '-', style: AppTextStyles.bodySecondary),
                    ]),
                  ),
                ]),
              ],
            ]),
          ),
        ]),
      ],
    );
  }
}

/// Strip tanggal horizontal + daftar sesi pada tanggal yang dipilih.
class _DayBrowser extends StatefulWidget {
  const _DayBrowser({required this.days, required this.until});

  final List<({String date, List<ScheduleSession> classes})> days;
  final String until;

  @override
  State<_DayBrowser> createState() => _DayBrowserState();
}

class _DayBrowserState extends State<_DayBrowser> {
  int _selected = 0;

  static const _shortDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  @override
  Widget build(BuildContext context) {
    final day = widget.days[_selected];
    final stripHeight = MediaQuery.textScalerOf(context).scale(1) * 84;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(title: 'Sesi terdekat', subtitle: 'Sampai ${formatDate(widget.until)} · ketuk tanggal'),
      SizedBox(
        height: stripHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.days.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final d = parseDate(widget.days[i].date);
            final active = i == _selected;
            return Semantics(
              selected: active,
              button: true,
              label: formatDayDate(widget.days[i].date),
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.primaryGradient : null,
                    color: active ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: active ? null : AppColors.cardShadow,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_shortDays[d.weekday - 1],
                        style: AppTextStyles.small.copyWith(color: active ? Colors.white : AppColors.textSecondary)),
                    Text('${d.day}', style: AppTextStyles.h2.copyWith(color: active ? Colors.white : AppColors.text)),
                    Text(_months[d.month - 1],
                        style: AppTextStyles.small.copyWith(color: active ? Colors.white : AppColors.textSecondary)),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
      Text(formatDayDate(day.date), style: AppTextStyles.h3),
      const SizedBox(height: 10),
      for (final s in day.classes) ...[_SessionCard(s), const SizedBox(height: 10)],
    ]);
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard(this.s);

  final ScheduleSession s;

  @override
  Widget build(BuildContext context) {
    final (badge, accent) = switch (s.availability) {
      'closed' => (const StatusBadge('Ditutup'), AppColors.textSecondary),
      'available' => (StatusBadge('${s.remainingSeats} kursi', tone: Tone.success), AppColors.tertiary),
      _ => (const StatusBadge('Penuh', tone: Tone.danger), AppColors.primary),
    };

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
          child: Text(s.time, style: AppTextStyles.h3.copyWith(color: AppColors.text)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.category, style: AppTextStyles.bodyStrong),
            Text([s.typeLabel, ?s.tutor].where((e) => e.isNotEmpty).join(' · '), style: AppTextStyles.small),
          ]),
        ),
        const SizedBox(width: 8),
        badge,
      ]),
    );
  }
}
