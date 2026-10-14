import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../../core/theme/app_colors.dart';
import 'entrance.dart';
import 'message_state.dart';
import 'net_image.dart';
import 'primary_button.dart';

/// Kerangka halaman yang memuat data: CustomScrollView dengan app bar sliver
/// (opsional), tarik-untuk-muat-ulang, skeleton shimmer saat memuat, dan
/// tampilan galat. Setiap item dari [builder] masuk dengan animasi bertahap.
class AsyncSliverPage<T> extends StatefulWidget {
  const AsyncSliverPage({
    super.key,
    required this.load,
    required this.builder,
    this.appBar,
    this.errorBuilder,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 0),
    this.spacing = 20,
    this.bottomSpace = 32,
  });

  final Future<T> Function() load;
  final List<Widget> Function(BuildContext context, T data, Future<void> Function() reload) builder;

  /// Sliver app bar, mis. [PageAppBar].
  final Widget? appBar;

  /// Tampilan galat khusus (mis. raport terkunci); null = tampilan galat umum.
  final Widget? Function(BuildContext context, ApiException error)? errorBuilder;
  final EdgeInsets padding;
  final double spacing;

  /// Ruang kosong di bawah, supaya konten terakhir tidak tertutup tombol mengambang.
  final double bottomSpace;

  @override
  State<AsyncSliverPage<T>> createState() => AsyncSliverPageState<T>();
}

class AsyncSliverPageState<T> extends State<AsyncSliverPage<T>> {
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
    final data = _data;
    final List<Widget> items;

    if (_loading && data == null) {
      items = const [SkeletonCard(height: 150), SkeletonCard(height: 110), SkeletonCard(height: 180)];
    } else if (data == null) {
      final err = _error;
      items = [
        (err is ApiException ? widget.errorBuilder?.call(context, err) : null) ??
            MessageState(
              icon: Icons.wifi_off_rounded,
              title: 'Gagal memuat',
              body: err is ApiException ? err.message : 'Terjadi kesalahan. Silakan coba lagi.',
              action: PrimaryButton(label: 'Coba lagi', icon: Icons.refresh_rounded, onPressed: reload),
            ),
      ];
    } else {
      items = widget.builder(context, data, reload);
    }

    final animate = data != null || !_loading;

    return RefreshIndicator(
      onRefresh: reload,
      color: AppColors.primary,
      edgeOffset: widget.appBar == null ? 0 : 112,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          ?widget.appBar,
          SliverPadding(
            padding: widget.padding.copyWith(bottom: widget.padding.bottom + widget.bottomSpace),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : widget.spacing),
                child: animate ? items[i].entrance(i) : items[i],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu skeleton shimmer untuk keadaan memuat.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(label: 'Memuat', child: ShimmerBox(height: height, radius: 24));
  }
}
