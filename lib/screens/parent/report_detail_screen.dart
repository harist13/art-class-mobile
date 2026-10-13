import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/repository.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';
import 'payments_screen.dart';

/// Isi raport: catatan kegiatan & tutor, foto progres, dan karya periode itu.
/// Server menjawab 423 bila murid menunggak — ditampilkan sebagai raport terkunci.
class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.studentId, required this.reportId, required this.title});

  final int studentId;
  final int reportId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return Scaffold(
      appBar: AppBar(title: Text('Raport $title')),
      body: AsyncList<ReportDetail>(
        load: () => repo.report(studentId, reportId),
        errorBuilder: (context, e) => e.status == 423
            ? MessageState(
                icon: Icons.lock_outline,
                title: 'Raport ditahan',
                body: e.message,
                action: FilledButton(
                  onPressed: () => Navigator.pushReplacement(
                      context, MaterialPageRoute<void>(builder: (_) => const PaymentsScreen())),
                  child: const Text('Lihat tagihan'),
                ),
              )
            : null,
        builder: (context, r, _) => [
          TacCard(children: [
            Text(r.studentName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text('${formatDate(r.summary.periodStart)} – ${formatDate(r.summary.periodEnd)}', style: mutedStyle),
          ]),
          if (r.activityNotes?.isNotEmpty ?? false)
            Section(title: 'Kegiatan', children: [
              TacCard(children: [Text(r.activityNotes!)])
            ]),
          if (r.tutorNotes?.isNotEmpty ?? false)
            Section(title: 'Catatan tutor', children: [
              TacCard(children: [Text(r.tutorNotes!)])
            ]),
          if (r.progressPhotos.isNotEmpty)
            Section(title: 'Foto progres', children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  for (final p in r.progressPhotos)
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 6, children: [
                        NetImage(p.url, aspectRatio: 3 / 4, onTap: () => showPhoto(context, p.url, caption: p.caption)),
                        Text(p.label, style: headingStyle),
                        if (p.caption?.isNotEmpty ?? false) Text(p.caption!, style: mutedStyle),
                      ]),
                    ),
                ],
              ),
            ]),
          Section(title: 'Karya periode ini', children: [
            if (r.artworks.isEmpty)
              const MessageState(icon: Icons.photo_outlined, title: 'Belum ada foto karya untuk periode ini')
            else
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (final a in r.artworks)
                    NetImage(
                      a.url,
                      onTap: () => showPhoto(
                        context,
                        a.url,
                        caption: [a.description, if (a.takenOn != null) formatDate(a.takenOn)]
                            .whereType<String>()
                            .where((e) => e.isNotEmpty)
                            .join(' · '),
                      ),
                    ),
                ],
              ),
          ]),
        ],
      ),
    );
  }
}
