import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import '../../shared/widgets/entrance.dart';
import '../../shared/widgets/message_state.dart';
import '../../shared/widgets/net_image.dart';
import '../../shared/widgets/open_link.dart';
import '../../shared/widgets/page_app_bar.dart';
import '../../shared/widgets/photo_viewer.dart';
import '../../shared/widgets/pressable.dart';
import '../../shared/widgets/primary_button.dart';

/// Galeri karya: filter kategori, grid dua kolom, muat-lebih-banyak per halaman,
/// dan penampil layar penuh dengan animasi Hero.
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final _items = <Artwork>[];
  List<({String slug, String label})> _categories = [];
  String? _category;
  int _page = 0;
  int _lastPage = 1;
  bool _loading = false;
  bool _loadedOnce = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await context.read<Repository>().gallery(category: _category, page: reset ? 1 : _page + 1);
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page.items);
        _categories = page.categories;
        _page = page.meta.currentPage;
        _lastPage = page.meta.lastPage;
        _loadedOnce = true;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _select(String? slug) {
    if (slug == _category) return;
    setState(() => _category = slug);
    _load(reset: true);
  }

  String _label(String? slug) =>
      _categories.where((c) => c.slug == slug).map((c) => c.label).firstOrNull ?? 'Karya murid';

  @override
  Widget build(BuildContext context) {
    final firstLoad = _loading && !_loadedOnce;

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      color: AppColors.primary,
      edgeOffset: 112,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const PageAppBar(title: 'Galeri Karya', showBack: false),
          if (_categories.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.textScalerOf(context).scale(1) * 40 + 16,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  children: [
                    _chip('Semua', null),
                    for (final c in _categories) _chip(c.label, c.slug),
                  ],
                ),
              ),
            ),
          if (firstLoad)
            _grid([for (var i = 0; i < 6; i++) const ShimmerBox(radius: 24)])
          else if (_error != null && _items.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: MessageState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Gagal memuat',
                  body: _error,
                  action: PrimaryButton(label: 'Coba lagi', onPressed: () => _load(reset: true)),
                ),
              ),
            )
          else if (_items.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: MessageState(
                  icon: Icons.photo_library_rounded,
                  title: 'Galeri segera hadir',
                  body: 'Foto karya murid sedang kami kumpulkan. Lihat kegiatan terbaru di Instagram kami.',
                  color: AppColors.tertiaryDark,
                  action: SecondaryButton(
                    label: 'Buka Instagram',
                    icon: Icons.camera_alt_outlined,
                    onPressed: () {
                      final url = context.read<SiteController>().site?.contact.instagramUrl;
                      if (url != null) openLink(context, url);
                    },
                  ),
                ),
              ),
            )
          else
            _grid([
              for (var i = 0; i < _items.length; i++) _tile(i).entrance(i % 6),
            ]),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
              child: Center(
                child: _loading && _loadedOnce
                    ? const CircularProgressIndicator()
                    : _page < _lastPage && _items.isNotEmpty
                        ? SecondaryButton(label: 'Muat lebih banyak', icon: Icons.expand_more_rounded, onPressed: _load)
                        : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(List<Widget> children) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        sliver: SliverGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: children,
        ),
      );

  Widget _tile(int i) {
    final art = _items[i];
    final label = _label(art.category);
    return Semantics(
      button: true,
      label: 'Karya $label, ketuk untuk memperbesar',
      excludeSemantics: true,
      child: PressableScale(
        child: GestureDetector(
          onTap: () => openPhotoViewer(
            context,
            [for (var j = 0; j < _items.length; j++) ViewerPhoto(url: _items[j].url, heroTag: 'gal-$j', caption: _label(_items[j].category))],
            initialIndex: i,
          ),
          child: Stack(fit: StackFit.expand, children: [
            NetImage(art.url, radius: 24, heroTag: 'gal-$i'),
            Positioned(
              left: 10,
              bottom: 10,
              right: 10,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(99)),
                  child: Text(label, style: AppTextStyles.smallStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label, String? slug) {
    final active = _category == slug;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        labelStyle: AppTextStyles.bodyStrong.copyWith(color: active ? Colors.white : AppColors.text),
        selected: active,
        onSelected: (_) => _select(slug),
      ),
    );
  }
}
