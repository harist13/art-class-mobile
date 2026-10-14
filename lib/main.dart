import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/api.dart';
import 'core/auth.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/repository.dart';
import 'features/gallery/gallery_page.dart';
import 'features/home/home_page.dart';
import 'features/parent/parent_page.dart';
import 'features/programs/programs_page.dart';
import 'features/schedule/schedule_page.dart';
import 'shared/widgets/app_bottom_nav.dart';
import 'shared/widgets/whatsapp_fab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
  );

  final api = ApiClient();
  final repo = Repository(api);
  final auth = AuthController(api)..restore();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: repo),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => SiteController(repo)),
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
      theme: AppTheme.light(),
      // Teks boleh diperbesar sampai 1.3× — tata letak sudah diuji sampai batas itu.
      builder: (context, child) => MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: child!),
      home: const HomeShell(),
    );
  }
}

/// Lima tab utama. IndexedStack menjaga posisi gulir & data tiap tab.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = AppTab.home;

  /// Tombol WA di Beranda berlabel hanya selama halaman belum digulir jauh.
  bool _homeAtTop = true;

  bool _onScroll(ScrollUpdateNotification n) {
    // depth 0 = daftar utama halaman, bukan carousel horizontal di dalamnya.
    if (_index == AppTab.home && n.depth == 0 && n.metrics.axis == Axis.vertical) {
      final atTop = n.metrics.pixels < 240;
      if (atTop != _homeAtTop) setState(() => _homeAtTop = atTop);
    }
    return false;
  }

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final ready = context.select<AuthController, bool>((a) => a.ready);
    if (!ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: _onScroll,
        child: IndexedStack(
          index: _index,
          children: [
            HomePage(onOpenTab: _goTo),
            const ProgramsPage(),
            const SchedulePage(),
            const GalleryPage(),
            const ParentPage(),
          ],
        ),
      ),
      // WhatsApp mengambang di tab publik; Info Ortu sudah punya tombol bantuan sendiri.
      floatingActionButton: switch (_index) {
        AppTab.home => WhatsAppFab(compact: !_homeAtTop),
        AppTab.parent => null,
        _ => const WhatsAppFab(compact: true),
      },
      bottomNavigationBar: AppBottomNav(index: _index, onSelect: _goTo),
    );
  }
}
