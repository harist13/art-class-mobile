import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/repository.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';
import 'report_detail_screen.dart';

/// Profil anak, kelas yang diikuti, dan daftar raport bulanannya.
class StudentScreen extends StatelessWidget {
  const StudentScreen({super.key, required this.studentId, required this.name});

  final int studentId;
  final String name;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: AsyncList<(StudentDetail, ReportList)>(
        load: () async => (await repo.student(studentId), await repo.reports(studentId)),
        builder: (context, data, _) {
          final (student, reports) = data;
          final s = student.summary;

          return [
            TacCard(children: [
              Text(s.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              InfoRow('ID murid', s.studentId),
              if (student.age != null) InfoRow('Usia', '${student.age} tahun'),
              if (student.dateOfBirth != null) InfoRow('Tanggal lahir', formatDate(student.dateOfBirth)),
              if (student.joinDate != null) InfoRow('Bergabung', formatDate(student.joinDate)),
            ]),
            if (student.classes.isNotEmpty)
              Section(title: 'Kelas', children: [
                for (final c in student.classes)
                  TacCard(children: [
                    Text(c.category, style: headingStyle),
                    Text('${c.day}, ${c.timeRange} WITA', style: mutedStyle),
                    Text([c.typeLabel, ?c.tutor].where((e) => e.isNotEmpty).join(' · '),
                        style: const TextStyle(fontSize: 13)),
                  ]),
              ]),
            Section(title: 'Raport', children: [
              if (reports.locked && reports.lockedMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TacColors.coralLight.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.lock_outline, color: TacColors.coralDark),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(reports.lockedMessage!,
                          style: const TextStyle(color: TacColors.coralDark, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
              if (reports.reports.isEmpty)
                const MessageState(
                  icon: Icons.description_outlined,
                  title: 'Belum ada raport',
                  body: 'Raport bulanan akan muncul di sini setelah dibuat tutor.',
                )
              else
                for (final r in reports.reports)
                  TacCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ReportDetailScreen(studentId: studentId, reportId: r.id, title: r.periodLabel),
                      ),
                    ),
                    children: [
                      Row(children: [
                        Icon(r.locked ? Icons.lock_outline : Icons.description_outlined,
                            color: r.locked ? TacColors.inkSoft : TacColors.coralDark),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.periodLabel, style: headingStyle),
                            Text('${formatDate(r.periodStart)} – ${formatDate(r.periodEnd)}', style: mutedStyle),
                          ]),
                        ),
                        const Icon(Icons.chevron_right, color: TacColors.inkSoft),
                      ]),
                    ],
                  ),
            ]),
          ];
        },
      ),
    );
  }
}
