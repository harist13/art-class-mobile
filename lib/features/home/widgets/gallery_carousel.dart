import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/message_state.dart';
import '../../../shared/widgets/net_image.dart';
import '../../../shared/widgets/open_link.dart';
import '../../../shared/widgets/photo_viewer.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';

/// Karya murid terbaru, digeser horizontal dengan snap per kartu.
class GalleryCarousel extends StatelessWidget {
  const GalleryCarousel({super.key, required this.site, required this.onSeeAll});

  final Site site;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final items = site.galleryPreview;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SectionHeader(
          title: 'Galeri Karya',
          subtitle: 'Hasil karya murid kami',
          actionLabel: items.isEmpty ? null : 'Lihat semua',
          onAction: onSeeAll,
        ),
      ),
      if (items.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MessageState(
            icon: Icons.photo_library_rounded,
            title: 'Galeri segera hadir',
            body: 'Foto karya murid sedang kami kumpulkan. Lihat kegiatan terbaru di Instagram kami.',
            color: AppColors.tertiaryDark,
            action: site.contact.instagramUrl == null
                ? null
                : SecondaryButton(
                    label: 'Buka Instagram',
                    icon: Icons.camera_alt_outlined,
                    onPressed: () => openLink(context, site.contact.instagramUrl!),
                  ),
          ),
        )
      else
        LayoutBuilder(builder: (context, c) {
          final cardWidth = (c.maxWidth * 0.6).clamp(180.0, 260.0);
          final captionHeight = MediaQuery.textScalerOf(context).scale(15) * 1.5 + 16;
          return SizedBox(
            height: cardWidth * 1.15 + captionHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => SizedBox(
                width: cardWidth,
                child: _ArtCard(
                  art: items[i],
                  label: site.categoryLabel(items[i].category),
                  heroTag: 'home-art-$i',
                  imageHeight: cardWidth * 1.15,
                  onTap: () => openPhotoViewer(
                    context,
                    [
                      for (var j = 0; j < items.length; j++)
                        ViewerPhoto(url: items[j].url, heroTag: 'home-art-$j', caption: site.categoryLabel(items[j].category)),
                    ],
                    initialIndex: i,
                  ),
                ),
              ),
            ),
          );
        }),
    ]);
  }
}

class _ArtCard extends StatelessWidget {
  const _ArtCard({required this.art, required this.label, required this.heroTag, required this.imageHeight, required this.onTap});

  final Artwork art;
  final String label;
  final Object heroTag;
  final double imageHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Karya $label, ketuk untuk memperbesar',
      child: PressableScale(
        child: GestureDetector(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: imageHeight, width: double.infinity, child: NetImage(art.url, radius: 24, heroTag: heroTag)),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ),
    );
  }
}
