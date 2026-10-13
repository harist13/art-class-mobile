import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api.dart';
import '../core/theme.dart';

/// Memuat data lalu menampilkannya dalam daftar yang bisa ditarik untuk
/// memuat ulang. Status muat & galat ditangani di sini.
class AsyncList<T> extends StatefulWidget {
  const AsyncList({super.key, required this.load, required this.builder, this.errorBuilder});

  final Future<T> Function() load;
  final List<Widget> Function(BuildContext context, T data, Future<void> Function() reload) builder;

  /// Tampilan galat khusus (mis. raport terkunci); null = tampilan galat umum.
  final Widget? Function(BuildContext context, ApiException error)? errorBuilder;

  @override
  State<AsyncList<T>> createState() => AsyncListState<T>();
}

class AsyncListState<T> extends State<AsyncList<T>> {
  T? _data;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    try {
      final data = await widget.load();
      if (!mounted) return;
      setState(() {
        _data = data;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children;
    final data = _data;

    if (_loading && data == null) {
      children = const [SizedBox(height: 160), Center(child: CircularProgressIndicator())];
    } else if (data == null || (_error != null && _data == null)) {
      final err = _error;
      final custom = err is ApiException ? widget.errorBuilder?.call(context, err) : null;
      children = [
        custom ??
            MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'Gagal memuat',
              body: err is ApiException ? err.message : 'Terjadi kesalahan. Silakan coba lagi.',
              action: OutlinedButton(onPressed: reload, child: const Text('Coba lagi')),
            ),
      ];
    } else {
      children = widget.builder(context, data, reload);
    }

    return RefreshIndicator(
      onRefresh: reload,
      color: TacColors.coral,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: _spaced(children),
      ),
    );
  }

  List<Widget> _spaced(List<Widget> items) => [
        for (var i = 0; i < items.length; i++) ...[if (i > 0) const SizedBox(height: 16), items[i]],
      ];
}

/// Pesan di tengah layar: kosong, galat, atau terkunci.
class MessageState extends StatelessWidget {
  const MessageState({super.key, required this.icon, required this.title, this.body, this.action});

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          children: [
            Icon(icon, size: 40, color: TacColors.inkSoft),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(body!, textAlign: TextAlign.center, style: const TextStyle(color: TacColors.inkSoft)),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

/// Judul bagian + tombol opsional di kanan, lalu isinya.
class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.children, this.action});

  final String title;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            ?action,
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 12), children[i]],
      ],
    );
  }
}

/// Kartu dengan padding standar.
class TacCard extends StatelessWidget {
  const TacCard({super.key, required this.children, this.onTap, this.topColor});

  final List<Widget> children;
  final VoidCallback? onTap;
  final Color? topColor;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 6, children: children),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: topColor == null ? null : BoxDecoration(border: Border(top: BorderSide(color: topColor!, width: 5))),
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: TacColors.inkSoft)),
          const SizedBox(width: 12),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

enum Tone { neutral, good, warn, bad }

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.tone = Tone.neutral});

  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      Tone.good => (TacColors.leafLight, TacColors.leafDark),
      Tone.warn => (TacColors.sunLight, TacColors.sunDark),
      Tone.bad => (TacColors.coralLight, TacColors.coralDark),
      Tone.neutral => (TacColors.paper2, TacColors.inkSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

const mutedStyle = TextStyle(color: TacColors.inkSoft);
const headingStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
const labelStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: TacColors.inkSoft);

/// Foto dari server, dengan cache dan tempat kosong saat gagal dimuat.
class NetImage extends StatelessWidget {
  const NetImage(this.url, {super.key, this.radius = 14, this.aspectRatio = 1, this.onTap});

  final String url;
  final double radius;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => showPhoto(context, url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: TacColors.paper2),
            errorWidget: (_, _, _) => Container(
              color: TacColors.paper2,
              child: const Icon(Icons.broken_image_outlined, color: TacColors.inkSoft),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tampilkan foto layar penuh yang bisa diperbesar.
void showPhoto(BuildContext context, String url, {String? caption}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) => GestureDetector(
      onTap: () => Navigator.pop(ctx),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InteractiveViewer(child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain)),
          if (caption != null && caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(caption, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
    ),
  );
}

/// Buka tautan di luar app (WhatsApp, Instagram, email, halaman bayar).
Future<void> openLink(BuildContext context, String url, {bool inApp = false}) async {
  final ok = await launchUrl(
    Uri.parse(url),
    mode: inApp ? LaunchMode.inAppBrowserView : LaunchMode.externalApplication,
  );
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tautan tidak dapat dibuka.')));
  }
}
