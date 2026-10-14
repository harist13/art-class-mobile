import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Indeks tab bawah, dipakai tombol "Lihat semua" untuk berpindah tab.
abstract final class AppTab {
  static const home = 0;
  static const programs = 1;
  static const schedule = 2;
  static const gallery = 3;
  static const parent = 4;
}

/// Navigasi bawah Material 3 dengan indikator pill.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: Color(0x142B2420), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onSelect,
        backgroundColor: AppColors.surface,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.palette_outlined), selectedIcon: Icon(Icons.palette_rounded), label: 'Program'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Jadwal'),
          NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library_rounded),
              label: 'Galeri'),
          // "Info Ortu", bukan "Orang Tua": label dua kata lebih pendek muat di
          // layar 360dp dengan teks diperbesar, dan langsung menjelaskan isinya
          // (raport & tagihan) tanpa terdengar seperti halaman akun umum.
          NavigationDestination(
              icon: Icon(Icons.family_restroom_outlined),
              selectedIcon: Icon(Icons.family_restroom_rounded),
              label: 'Info Ortu'),
        ],
      ),
    );
  }
}
