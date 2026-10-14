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
import '../../shared/widgets/net_image.dart';
import '../../shared/widgets/page_app_bar.dart';
import '../../shared/widgets/photo_viewer.dart';
import '../../shared/widgets/pressable.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/section_header.dart';
import 'payments_page.dart';

/// Isi raport: catatan kegiatan & tutor, foto progres, dan karya periode itu.
/// Server menjawab 423 bila murid menunggak — ditampilkan sebagai raport terkunci.
class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key, required this.studentId, required this.reportId, required this.title});

  final int studentId;
  final int reportId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return Scaffold(
      body: AsyncSliverPage<ReportDetail>(
        load: () => repo.report(studentId, reportId),
        appBar: PageAppBar(title: 'Raport $title'),
        errorBuilder: (context, e) => e.status == 423
            ? MessageState(
                icon: Icons.lock_rounded,
                title: 'Raport ditahan',
                body: e.message,
                color: AppColors.danger,
                action: PrimaryButton(
                  label: 'Lihat tagihan',
                  icon: Icons.receipt_long_rounded,
                  onPressed: () => Navigator.pushReplacement(
                      context, MaterialPageRoute<void>(builder: (_) => const PaymentsPage())),
                ),
              )
            : null,
        builder: (context, r, _) => [
          AppCard(
            color: AppColors.primarySoft,
            child: Row(children: [
              const IconBubble(Icons.auto_stories_rounded, color: AppColors.primaryDark, background: Colors.white, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.studentName, style: AppTextStyles.h2),
                  Text('${formatDate(r.summary.periodStart)} – ${formatDate(r.summary.periodEnd)}',
                      style: AppTextStyles.body.copyWith(color: AppColors.text)),
                ]),
              ),
            ]),
          ),
          if (r.activityNotes?.isNotEmpty ?? false)
            _NoteCard(icon: Icons.brush_rounded, title: 'Kegiatan bulan ini', body: r.activityNotes!),
          if (r.tutorNotes?.isNotEmpty ?? false)
            _NoteCard(icon: Icons.format_quote_rounded, title: 'Catatan tutor', body: r.tutorNotes!, quote: true),
          if (r.progressPhotos.isNotEmpty)
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SectionHeader(title: 'Foto progres', subtitle: 'Perkembangan dari awal ke akhir bulan'),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var i = 0; i < r.progressPhotos.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: _ProgressPhoto(photos: r.progressPhotos, index: i)),
                ],
              ]),
            ]),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SectionHeader(title: 'Karya periode ini', subtitle: '${r.artworks.length} foto'),
            if (r.artworks.isEmpty)
              const MessageState(icon: Icons.photo_rounded, title: 'Belum ada foto karya untuk periode ini')
            else
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (var i = 0; i < r.artworks.length; i++)
                    PressableScale(
                      child: GestureDetector(
                        onTap: () => openPhotoViewer(
                          context,
                          [
                            for (var j = 0; j < r.artworks.length; j++)
                              ViewerPhoto(
                                url: r.artworks[j].url,
                                heroTag: 'report-art-$j',
                                caption: [r.artworks[j].description, if (r.artworks[j].takenOn != null) formatDate(r.artworks[j].takenOn)]
                                    .whereType<String>()
                                    .where((e) => e.isNotEmpty)
                                    .join(' · '),
                              ),
                          ],
                          initialIndex: i,
                        ),
                        child: NetImage(r.artworks[i].url, radius: 16, heroTag: 'report-art-$i', semanticLabel: 'Karya'),
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

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.icon, required this.title, required this.body, this.quote = false});

  final IconData icon;
  final String title;
  final String body;
  final bool quote;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accent: quote ? AppColors.secondary : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          IconBubble(icon, color: AppColors.tertiaryDark, background: AppColors.tertiarySoft, size: 38),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTextStyles.h3)),
        ]),
        const SizedBox(height: 10),
        Text(body, style: quote ? AppTextStyles.body.copyWith(fontStyle: FontStyle.italic) : AppTextStyles.body),
      ]),
    );
  }
}

class _ProgressPhoto extends StatelessWidget {
  const _ProgressPhoto({required this.photos, required this.index});

  final List<({String label, String url, String? caption})> photos;
  final int index;

  @override
  Widget build(BuildContext context) {
    final p = photos[index];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PressableScale(
        child: GestureDetector(
          onTap: () => openPhotoViewer(
            context,
            [for (var j = 0; j < photos.length; j++) ViewerPhoto(url: photos[j].url, heroTag: 'progress-$j', caption: photos[j].caption)],
            initialIndex: index,
          ),
          child: AspectRatio(aspectRatio: 3 / 4, child: NetImage(p.url, heroTag: 'progress-$index', semanticLabel: p.label)),
        ),
      ),
      const SizedBox(height: 8),
      Text(p.label, style: AppTextStyles.bodyStrong),
      if (p.caption?.isNotEmpty ?? false) Text(p.caption!, style: AppTextStyles.small),
    ]);
  }
}
