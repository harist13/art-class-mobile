import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/repository.dart';
import '../core/theme.dart';
import '../main.dart' show Tabs;
import '../models/models.dart';
import '../widgets/common.dart';
import '../widgets/program_card.dart';
import 'lead_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final void Function(int tab) onOpenTab;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AsyncList<Site>(
          load: repo.site,
          builder: (context, site, _) => [
            _Hero(site),
            if (site.stats.isNotEmpty)
              Row(
                spacing: 12,
                children: [
                  for (final s in site.stats)
                    Expanded(
                      child: TacCard(children: [
                        Text(s.value,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w800, color: TacColors.coralDark)),
                        Text(s.label, style: const TextStyle(fontSize: 13)),
                      ]),
                    ),
                ],
              ),
            Section(
              title: 'Program kelas',
              action: TextButton(onPressed: () => onOpenTab(Tabs.programs), child: const Text('Lihat semua')),
              children: [for (final p in site.programs) ProgramCard(p, compact: true)],
            ),
            if (site.holidayClasses.isNotEmpty)
              Section(title: 'Holiday Class', children: [
                for (final h in site.holidayClasses)
                  TacCard(children: [
                    Text(h.name, style: headingStyle),
                    Text(formatDateTime(h.startsAt), style: mutedStyle),
                    Wrap(spacing: 8, children: [
                      StatusBadge('${h.capacity} kursi', tone: Tone.good),
                      if (h.price != null) StatusBadge(rupiah(h.price!), tone: Tone.warn),
                    ]),
                  ]),
              ]),
            if (site.galleryPreview.isNotEmpty)
              Section(
                title: 'Karya murid',
                action: TextButton(onPressed: () => onOpenTab(Tabs.gallery), child: const Text('Galeri')),
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [for (final g in site.galleryPreview) NetImage(g.url)],
                  ),
                ],
              ),
            if (site.testimonials.isNotEmpty)
              Section(title: 'Kata orang tua', children: [
                for (final t in site.testimonials)
                  TacCard(children: [
                    Text('“${t.quote}”', style: const TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    Text(t.name, style: headingStyle),
                    Text(t.role, style: mutedStyle),
                  ]),
              ]),
            if (site.story != null || site.vision != null) _About(site),
            if (site.faq.isNotEmpty)
              Section(title: 'Pertanyaan umum', children: [
                for (final f in site.faq)
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      title: Text(f.q, style: headingStyle),
                      shape: const Border(),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedAlignment: Alignment.centerLeft,
                      children: [Text(f.a, style: mutedStyle)],
                    ),
                  ),
              ]),
            _ContactSection(site),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero(this.site);

  final Site site;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        const SizedBox(height: 4),
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/images/logo.jpg', width: 40, height: 40),
          ),
          const SizedBox(width: 10),
          Text(site.name, style: headingStyle),
        ]),
        Text(site.tagline, style: const TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w800)),
        Text(site.description, style: mutedStyle),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const LeadFormScreen())),
            icon: const Icon(Icons.edit_note),
            label: const Text('Daftar / Tanya'),
          ),
          if (site.contact.whatsappUrl != null)
            OutlinedButton.icon(
              onPressed: () => openLink(context, site.contact.whatsappUrl!),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('WhatsApp'),
            ),
        ]),
      ],
    );
  }
}

class _About extends StatelessWidget {
  const _About(this.site);

  final Site site;

  @override
  Widget build(BuildContext context) {
    return Section(title: 'Tentang kami', children: [
      TacCard(children: [
        if (site.story != null) Text(site.story!),
        if (site.vision != null) ...[
          const SizedBox(height: 8),
          const Text('VISI', style: labelStyle),
          Text(site.vision!),
        ],
        if (site.mission.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('MISI', style: labelStyle),
          for (final m in site.mission) Text('•  $m', style: const TextStyle(fontSize: 13)),
        ],
      ]),
      for (final m in site.methods)
        TacCard(children: [
          Text(m.title, style: headingStyle),
          Text(m.body, style: mutedStyle),
        ]),
    ]);
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection(this.site);

  final Site site;

  @override
  Widget build(BuildContext context) {
    final c = site.contact;

    Widget link(IconData icon, String label, String url) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: TacColors.coralDark),
          title: Text(label),
          trailing: const Icon(Icons.open_in_new, size: 18, color: TacColors.inkSoft),
          onTap: () => openLink(context, url),
        );

    return Section(title: 'Kontak', children: [
      TacCard(children: [
        if (c.whatsappUrl != null) link(Icons.chat_outlined, c.whatsappDisplay ?? 'WhatsApp', c.whatsappUrl!),
        if (c.instagramUrl != null) link(Icons.camera_alt_outlined, '@${c.instagram}', c.instagramUrl!),
        if (c.email != null) link(Icons.mail_outline, c.email!, 'mailto:${c.email}'),
        if (c.address != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined, color: TacColors.coralDark),
            title: Text(c.address!, style: const TextStyle(fontSize: 13)),
          ),
      ]),
      if (site.hours.isNotEmpty)
        TacCard(children: [
          const Text('JAM BUKA', style: labelStyle),
          for (final h in site.hours) InfoRow(h.day, h.time),
        ]),
    ]);
  }
}
