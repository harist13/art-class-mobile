import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Blob organik berwarna untuk dekorasi latar (digambar, bukan gambar aset).
class Blob extends StatelessWidget {
  const Blob({super.key, required this.color, this.size = 160, this.seed = 0});

  final Color color;
  final double size;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: Size.square(size), painter: _BlobPainter(color, seed)),
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.color, this.seed);

  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    const points = 7;
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final pts = List.generate(points, (i) {
      final a = i * 2 * math.pi / points;
      final rr = r * (0.78 + rnd.nextDouble() * 0.22);
      return c + Offset(math.cos(a) * rr, math.sin(a) * rr);
    });

    // Kurva halus melalui titik tengah antarsudut.
    final path = Path();
    for (var i = 0; i < points; i++) {
      final p0 = pts[i];
      final p1 = pts[(i + 1) % points];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      if (i == 0) {
        final prev = pts[points - 1];
        path.moveTo((prev.dx + p0.dx) / 2, (prev.dy + p0.dy) / 2);
      }
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.color != color || old.seed != seed;
}

/// Bintang/kilau kecil empat sudut.
class Sparkle extends StatelessWidget {
  const Sparkle({super.key, this.color = AppColors.secondary, this.size = 18});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(child: CustomPaint(size: Size.square(size), painter: _SparklePainter(color)));
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..quadraticBezierTo(w * 0.56, h * 0.44, w, h / 2)
      ..quadraticBezierTo(w * 0.56, h * 0.56, w / 2, h)
      ..quadraticBezierTo(w * 0.44, h * 0.56, 0, h / 2)
      ..quadraticBezierTo(w * 0.44, h * 0.44, w / 2, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}

/// Coretan krayon bergelombang, dipakai sebagai garis bawah kata kunci.
class CrayonUnderline extends StatelessWidget {
  const CrayonUnderline({super.key, this.color = AppColors.secondary, this.width = 140, this.height = 10});

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(child: CustomPaint(size: Size(width, height), painter: _CrayonPainter(color)));
  }
}

class _CrayonPainter extends CustomPainter {
  _CrayonPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final path = Path()..moveTo(0, s.height * 0.7);
    const waves = 6;
    for (var i = 0; i < waves; i++) {
      final x0 = s.width * i / waves;
      final x1 = s.width * (i + 1) / waves;
      path.quadraticBezierTo((x0 + x1) / 2, i.isEven ? 0 : s.height, x1, s.height * 0.5);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.height * 0.45
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CrayonPainter old) => old.color != color;
}

/// Garis putus-putus horizontal (penghubung langkah pendaftaran).
class DashedLine extends StatelessWidget {
  const DashedLine({super.key, this.color = AppColors.primary, this.thickness = 2});

  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: Size(double.infinity, thickness), painter: _DashPainter(color, thickness)),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.thickness);

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    const dash = 6.0, gap = 6.0;
    for (var x = 0.0; x < s.width; x += dash + gap) {
      canvas.drawLine(Offset(x, s.height / 2), Offset(math.min(x + dash, s.width), s.height / 2), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

/// Ikon WhatsApp sederhana: gelembung chat + gagang telepon (Material Icons
/// tidak punya logo WhatsApp).
class WhatsAppIcon extends StatelessWidget {
  const WhatsAppIcon({super.key, this.size = 22, this.color = Colors.white, this.phoneColor = AppColors.whatsappDark});

  final double size;
  final Color color;
  final Color phoneColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(alignment: Alignment.center, children: [
        Icon(Icons.chat_bubble_rounded, size: size, color: color),
        Padding(
          padding: EdgeInsets.only(bottom: size * 0.1),
          child: Icon(Icons.phone_rounded, size: size * 0.5, color: phoneColor),
        ),
      ]),
    );
  }
}

/// Ilustrasi pengganti foto karya: kartu berwarna dengan ikon seni.
class ArtPlaceholder extends StatelessWidget {
  const ArtPlaceholder({super.key, required this.icon, required this.color, required this.background, this.radius = 24});

  final IconData icon;
  final Color color;
  final Color background;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius)),
        child: Stack(children: [
          Positioned(right: -18, bottom: -18, child: Blob(color: color.withValues(alpha: 0.25), size: 90, seed: icon.codePoint)),
          Center(child: Icon(icon, size: 42, color: color)),
        ]),
      ),
    );
  }
}
