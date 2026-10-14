import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animasi masuk seragam: fade + slide-up, bertahap menurut urutan.
/// Di dalam daftar sliver, item baru dibangun saat masuk layar, jadi animasi
/// ini muncul saat seksinya terlihat.
extension Entrance on Widget {
  Widget entrance([int index = 0]) => animate()
      .fadeIn(duration: 420.ms, delay: math.min(index * 70, 350).ms, curve: Curves.easeOut)
      .slideY(begin: 0.08, end: 0, duration: 420.ms, delay: math.min(index * 70, 350).ms, curve: Curves.easeOutCubic);
}
