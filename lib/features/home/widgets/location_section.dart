import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/open_link.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_header.dart';

/// Alamat studio, jam buka, dan tautan Maps/Instagram/email.
class LocationSection extends StatelessWidget {
  const LocationSection({super.key, required this.site});

  final Site site;

  @override
  Widget build(BuildContext context) {
    final c = site.contact;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SectionHeader(title: 'Lokasi & Kontak'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Peta statis berupa gambar (bukan Google Maps tertanam) supaya ringan
            // dan tidak butuh API key; tombol di bawah membuka Maps sungguhan.
            const SizedBox(height: 140, child: _MapPlaceholder()),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(c.address ?? AppStrings.address, style: AppTextStyles.body)),
                ]),
                if (site.hours.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final h in site.hours)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.access_time_rounded, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        SizedBox(width: 110, child: Text(h.day, style: AppTextStyles.bodyStrong)),
                        Expanded(child: Text(h.time, style: AppTextStyles.bodySecondary)),
                      ]),
                    ),
                ],
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Buka di Maps',
                  icon: Icons.map_rounded,
                  expand: true,
                  onPressed: () => openLink(context, AppStrings.mapsUrl),
                ),
                const SizedBox(height: 8),
                Wrap(alignment: WrapAlignment.center, spacing: 4, children: [
                  if (c.instagramUrl != null)
                    TextButton.icon(
                      onPressed: () => openLink(context, c.instagramUrl!),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text('@${c.instagram}'),
                    ),
                  if (c.email != null)
                    TextButton.icon(
                      onPressed: () => openLink(context, 'mailto:${c.email}'),
                      icon: const Icon(Icons.mail_outline_rounded),
                      label: const Text('Email'),
                    ),
                ]),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// Peta ilustrasi: jalan, blok, sungai, dan pin di tengah.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: _MapPainter()),
        const Center(child: Icon(Icons.location_on_rounded, size: 46, color: AppColors.primary)),
      ]),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFF3EDE4));
    final block = Paint()..color = const Color(0xFFE8DFD2);
    for (var x = 12.0; x < s.width; x += 64) {
      for (var y = 10.0; y < s.height; y += 50) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 46, 32), const Radius.circular(6)), block);
      }
    }
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 10;
    canvas.drawLine(Offset(0, s.height * 0.62), Offset(s.width, s.height * 0.48), road);
    canvas.drawLine(Offset(s.width * 0.38, 0), Offset(s.width * 0.46, s.height), road);
    final river = Path()
      ..moveTo(s.width * 0.75, 0)
      ..quadraticBezierTo(s.width * 0.68, s.height * 0.5, s.width * 0.9, s.height);
    canvas.drawPath(
      river,
      Paint()
        ..color = AppColors.skySoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
