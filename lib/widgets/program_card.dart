import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../screens/lead_form_screen.dart';
import 'common.dart';

class ProgramCard extends StatelessWidget {
  const ProgramCard(this.program, {super.key, this.compact = false});

  final Program program;

  /// Versi ringkas untuk Beranda: tanpa deskripsi, sorotan, dan tombol daftar.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = program;
    final color = Accent.of(p.color);

    return TacCard(
      topColor: color.base,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color.light, borderRadius: BorderRadius.circular(12)),
              child: Text(p.name.characters.first,
                  style: TextStyle(color: color.dark, fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: headingStyle),
                  if (p.age != null) Text(p.age!, style: mutedStyle),
                ],
              ),
            ),
            if (p.isLive) const StatusBadge('Dibuka', tone: Tone.good),
          ],
        ),
        if (!compact && p.summary != null) Text(p.summary!.replaceAll(RegExp(r'\s*\n\s*'), ' '), style: mutedStyle),
        if (p.price != null) InfoRow('Biaya', p.price!),
        if (p.visitPrice != null) InfoRow('Visit', p.visitPrice!),
        if (!compact && p.duration != null) InfoRow('Durasi', p.duration!),
        if (!compact && p.capacity != null) InfoRow('Kapasitas', p.capacity!),
        if (p.scheduleSummary != null) InfoRow('Jadwal', p.scheduleSummary!),
        if (p.nextHoliday != null) InfoRow('Sesi terdekat', formatDateTime(p.nextHoliday!.startsAt)),
        if (!compact) ...[
          for (final h in p.highlights) Text('•  $h'),
          if (p.canRegister)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => LeadFormScreen(initialProgram: p.slug)),
                ),
                child: const Text('Daftar kelas ini'),
              ),
            ),
        ],
      ],
    );
  }
}
