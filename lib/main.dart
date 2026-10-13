import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api.dart';
import 'core/auth.dart';
import 'core/repository.dart';
import 'core/theme.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/parent/parent_tab.dart';
import 'screens/programs_screen.dart';
import 'screens/schedule_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiClient();
  final auth = AuthController(api)..restore();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: Repository(api)),
        ChangeNotifierProvider.value(value: auth),
      ],
      child: const ArtClassApp(),
    ),
  );
}

class ArtClassApp extends StatelessWidget {
  const ArtClassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarakan Art Class',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeShell(),
    );
  }
}

/// Indeks tab, dipakai tombol "Lihat semua" di Beranda.
abstract final class Tabs {
  static const programs = 1;
  static const gallery = 3;
}

/// Lima tab utama. IndexedStack menjaga posisi gulir & data tiap tab saat
/// berpindah.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final ready = context.select<AuthController, bool>((a) => a.ready);
    if (!ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenTab: _goTo),
          const ProgramsScreen(),
          const ScheduleScreen(),
          const GalleryScreen(),
          const ParentTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.palette_outlined), selectedIcon: Icon(Icons.palette), label: 'Program'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Jadwal'),
          NavigationDestination(
              icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: 'Galeri'),
          NavigationDestination(
              icon: Icon(Icons.family_restroom_outlined),
              selectedIcon: Icon(Icons.family_restroom),
              label: 'Orang Tua'),
        ],
      ),
    );
  }
}
