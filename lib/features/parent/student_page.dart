import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/async_page.dart';
import '../../shared/widgets/info_row.dart';
import '../../shared/widgets/message_state.dart';
import '../../shared/widgets/page_app_bar.dart';
import '../../shared/widgets/section_header.dart';
import 'report_detail_page.dart';

/// Profil anak, kelas yang diikuti, dan daftar raport bulanannya.
class StudentPage extends StatelessWidget {
  const StudentPage({super.key, required this.studentId, required this.name});

  final int studentId;
  final String name;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return Scaffold(
      body: AsyncSliverPage<(StudentDetail, ReportList)>(
        load: () async => (await repo.student(studentId), await repo.reports(studentId)),
        appBar: PageAppBar(title: name),
        builder: (context, data, _) {
          final (student, reports) = data;
          final s = student.summary;

          return [
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.secondarySoft,
                    child: Text(s.name.isEmpty ? '?' : s.name[0].toUpperCase(),
                        style: AppTextStyles.h1.copyWith(color: AppColors.secondaryDark)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.name, style: AppTextStyles.h2),
                      Text('ID murid ${s.studentId}', style: AppTextStyles.small),
                    ]),
                  ),
                ]),
                const SizedBox(height: 12),
                if (student.age != null) InfoRow(icon: Icons.cake_outlined, label: 'Usia', value: '${student.age} tahun'),
                if (student.dateOfBirth != null)
                  InfoRow(icon: Icons.calendar_today_outlined, label: 'Tanggal lahir', value: formatDate(student.dateOfBirth)),
                if (student.joinDate != null)
                  InfoRow(icon: Icons.flag_outlined, label: 'Bergabung', value: formatDate(student.joinDate)),
              ]),
            ),
            if (student.classes.isNotEmpty)
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const SectionHeader(title: 'Kelas'),
                for (final c in student.classes) ...[
                  AppCard(
                    child: Row(children: [
                      const IconBubble(Icons.palette_rounded, color: AppColors.tertiaryDark, background: AppColors.tertiarySoft),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.category, style: AppTextStyles.bodyStrong),
                          Text('${c.day}, ${c.timeRange} WITA', style: AppTextStyles.body),
                          Text([c.typeLabel, ?c.tutor].where((e) => e.isNotEmpty).join(' · '), style: AppTextStyles.small),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
              ]),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SectionHeader(title: 'Raport bulanan'),
              if (reports.locked && reports.lockedMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(20)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.lock_rounded, color: AppColors.danger),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(reports.lockedMessage!,
                          style: AppTextStyles.body.copyWith(color: AppColors.danger, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
              ],
              if (reports.reports.isEmpty)
                const MessageState(
                  icon: Icons.description_rounded,
                  title: 'Belum ada raport',
                  body: 'Raport bulanan akan muncul di sini setelah dibuat tutor.',
                )
              else
                for (final r in reports.reports) ...[
                  AppCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ReportDetailPage(studentId: studentId, reportId: r.id, title: r.periodLabel),
                      ),
                    ),
                    semanticLabel: 'Raport ${r.periodLabel}${r.locked ? ', terkunci' : ''}',
                    child: Row(children: [
                      IconBubble(
                        r.locked ? Icons.lock_rounded : Icons.auto_stories_rounded,
                        color: r.locked ? AppColors.textSecondary : AppColors.primaryDark,
                        background: r.locked ? AppColors.surfaceMuted : AppColors.primarySoft,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.periodLabel, style: AppTextStyles.bodyStrong),
                          Text('${formatDate(r.periodStart)} – ${formatDate(r.periodEnd)}', style: AppTextStyles.small),
                        ]),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
            ]),
          ];
        },
      ),
    );
  }
}
