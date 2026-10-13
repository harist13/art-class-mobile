import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/repository.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal')),
      body: AsyncList<Schedule>(
        load: repo.schedule,
        builder: (context, data, _) => [
          Section(title: 'Jadwal umum', children: [
            TacCard(children: [
              for (final (i, p) in data.programs.indexed) ...[
                if (i > 0) const Divider(color: TacColors.line),
                Text(p.name, style: headingStyle),
                Text(p.schedule ?? '-', style: mutedStyle),
              ],
            ]),
          ]),
          if (data.holidayClasses.isNotEmpty)
            Section(title: 'Holiday Class', children: [
              for (final h in data.holidayClasses)
                TacCard(children: [
                  Text(h.name, style: headingStyle),
                  Text(formatDateTime(h.startsAt), style: mutedStyle),
                  if (h.price != null) Align(alignment: Alignment.centerLeft, child: StatusBadge(rupiah(h.price!), tone: Tone.warn)),
                ]),
            ]),
          Section(
            title: 'Sesi sampai ${formatDate(data.until)}',
            children: data.days.isEmpty
                ? const [
                    MessageState(
                      icon: Icons.event_busy_outlined,
                      title: 'Belum ada slot terjadwal',
                      body: 'Jadwal angkatan berikutnya sedang disusun. Hubungi admin untuk info terbaru.',
                    ),
                  ]
                : [
                    for (final day in data.days)
                      TacCard(children: [
                        Text(formatDayDate(day.date).toUpperCase(), style: labelStyle),
                        for (final (i, s) in day.classes.indexed) ...[
                          if (i > 0) const Divider(color: TacColors.line, height: 1),
                          _SessionRow(s),
                        ],
                      ]),
                  ],
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow(this.s);

  final ScheduleSession s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(s.time, style: headingStyle)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text([s.typeLabel, ?s.tutor].where((e) => e.isNotEmpty).join(' · '),
                    style: const TextStyle(fontSize: 12, color: TacColors.inkSoft)),
              ],
            ),
          ),
          switch (s.availability) {
            'closed' => const StatusBadge('Ditutup'),
            'available' => StatusBadge('${s.remainingSeats} kursi', tone: Tone.good),
            _ => const StatusBadge('Penuh', tone: Tone.bad),
          },
        ],
      ),
    );
  }
}
