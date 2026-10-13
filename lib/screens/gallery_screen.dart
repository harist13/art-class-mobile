import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api.dart';
import '../core/repository.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/common.dart';

/// Galeri karya dengan filter kategori dan muat-lebih-banyak per halaman.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _items = <GalleryItem>[];
  List<({String slug, String label})> _categories = [];
  String? _category;
  int _page = 0;
  int _lastPage = 1;
  bool _loading = false;
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
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _select(String? category) {
    setState(() => _category = category);
    _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeri')),
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        color: TacColors.coral,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (_categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    children: [
                      _chip('Semua', null),
                      for (final c in _categories) _chip(c.label, c.slug),
                    ],
                  ),
                ),
              ),
            if (_error != null && _items.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: MessageState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Gagal memuat',
                    body: _error,
                    action: OutlinedButton(onPressed: () => _load(reset: true), child: const Text('Coba lagi')),
                  ),
                ),
              )
            else if (!_loading && _items.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: MessageState(icon: Icons.photo_outlined, title: 'Belum ada foto karya'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [for (final item in _items) NetImage(item.url)],
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Center(
                  child: _loading
                      ? const CircularProgressIndicator()
                      : _page < _lastPage
                          ? OutlinedButton(onPressed: _load, child: const Text('Muat lebih banyak'))
                          : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String? slug) {
    final active = _category == slug;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: active ? Colors.white : TacColors.ink, fontWeight: FontWeight.w600)),
        selected: active,
        onSelected: (_) => _select(slug),
      ),
    );
  }
}
