import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

class ViewerPhoto {
  const ViewerPhoto({required this.url, this.heroTag, this.caption});

  final String url;
  final Object? heroTag;
  final String? caption;
}

/// Buka penampil foto layar penuh (bisa digeser & diperbesar), dengan animasi
/// Hero dari thumbnail yang punya tag sama.
void openPhotoViewer(BuildContext context, List<ViewerPhoto> photos, {int initialIndex = 0}) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) => _PhotoViewer(photos: photos, initialIndex: initialIndex),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({required this.photos, required this.initialIndex});

  final List<ViewerPhoto> photos;
  final int initialIndex;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caption = widget.photos[_index].caption;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.photos.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) {
            final p = widget.photos[i];
            Widget img = CachedNetworkImage(imageUrl: p.url, fit: BoxFit.contain);
            if (p.heroTag != null) img = Hero(tag: p.heroTag!, child: img);
            return InteractiveViewer(maxScale: 4, child: Center(child: img));
          },
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              IconButton(
                tooltip: 'Tutup',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.white24, minimumSize: const Size(48, 48)),
              ),
              const Spacer(),
              if (widget.photos.length > 1)
                Text('${_index + 1} / ${widget.photos.length}',
                    style: AppTextStyles.bodyStrong.copyWith(color: Colors.white)),
              const SizedBox(width: 12),
            ]),
          ),
        ),
        if (caption != null && caption.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                child: Text(caption, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: Colors.white)),
              ),
            ),
          ),
      ]),
    );
  }
}
