import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

/// Foto dari server: cache, shimmer saat memuat, dan tempat kosong saat gagal.
/// [heroTag] mengaktifkan animasi Hero ke penampil layar penuh.
class NetImage extends StatelessWidget {
  const NetImage(this.url, {super.key, this.radius = 20, this.heroTag, this.fit = BoxFit.cover, this.semanticLabel});

  final String url;
  final double radius;
  final Object? heroTag;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, _) => const ShimmerBox(),
      errorWidget: (_, _, _) => Container(
        color: AppColors.surfaceMuted,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
      ),
    );
    if (heroTag != null) image = Hero(tag: heroTag!, child: image);

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: image),
    );
  }
}

/// Kotak shimmer untuk skeleton loading.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.height, this.width, this.radius = 0});

  final double? height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: Colors.white,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}
