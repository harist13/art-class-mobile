import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';

/// Testimoni orang tua: geser pelan otomatis, berhenti sementara saat disentuh.
class TestimonialCarousel extends StatefulWidget {
  const TestimonialCarousel({super.key, required this.items});

  final List<Testimonial> items;

  @override
  State<TestimonialCarousel> createState() => _TestimonialCarouselState();
}

class _TestimonialCarouselState extends State<TestimonialCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  Timer? _timer;

  static const _avatarColors = [
    (AppColors.primarySoft, AppColors.primaryDark),
    (AppColors.tertiarySoft, AppColors.tertiaryDark),
    (AppColors.secondarySoft, AppColors.secondaryDark),
  ];

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.items.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_controller.hasClients) return;
      final next = ((_controller.page ?? 0).round() + 1) % widget.items.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final height = MediaQuery.textScalerOf(context).scale(1) * 236;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SectionHeader(title: 'Kata orang tua', subtitle: 'Pengalaman keluarga murid kami'),
      ),
      SizedBox(
        height: height,
        child: NotificationListener<ScrollStartNotification>(
          // Pengguna menggeser sendiri → jeda auto-scroll dengan memulai ulang timer.
          onNotification: (n) {
            if (n.dragDetails != null) _restartTimer();
            return false;
          },
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: items.length,
            itemBuilder: (context, i) {
              final t = items[i];
              final color = _avatarColors[i % _avatarColors.length];
              return Padding(
                padding: EdgeInsets.only(left: 16, right: i == items.length - 1 ? 16 : 0, bottom: 8),
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 32),
                    Expanded(
                      child: Text(
                        t.quote,
                        style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: color.$1,
                        child: Text(t.initial, style: AppTextStyles.h3.copyWith(color: color.$2)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(t.name, style: AppTextStyles.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(t.role, style: AppTextStyles.small, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ),
      ),
      if (items.length > 1) ...[
        const SizedBox(height: 8),
        Center(
          child: SmoothPageIndicator(
            controller: _controller,
            count: items.length,
            onDotClicked: (i) => _controller.animateToPage(i, duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
            effect: const ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.outline,
            ),
          ),
        ),
      ],
    ]);
  }
}
