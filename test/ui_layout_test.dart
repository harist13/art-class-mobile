// Uji tata letak: setiap halaman dirender dengan data berbentuk respons API
// production, di lebar 360dp & 430dp, skala teks 1.0 & 1.3, lalu digulir
// sampai bawah. Gagal bila ada overflow atau galat render apa pun.
//
// Foto & font tidak bisa dimuat di lingkungan tes (tanpa jaringan/plugin);
// galat dari keduanya diabaikan, galat lain tidak.

import 'dart:convert';
import 'dart:io';

import 'package:art_class_mobile/core/api.dart';
import 'package:art_class_mobile/core/auth.dart';
import 'package:art_class_mobile/core/theme/app_theme.dart';
import 'package:art_class_mobile/data/repository.dart';
import 'package:art_class_mobile/features/gallery/gallery_page.dart';
import 'package:art_class_mobile/features/lead/lead_form_page.dart';
import 'package:art_class_mobile/features/parent/parent_page.dart';
import 'package:art_class_mobile/features/parent/payments_page.dart';
import 'package:art_class_mobile/features/parent/report_detail_page.dart';
import 'package:art_class_mobile/features/parent/student_page.dart';
import 'package:art_class_mobile/features/programs/programs_page.dart';
import 'package:art_class_mobile/features/schedule/schedule_page.dart';
import 'package:art_class_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

String _fixture(String name) => File('test/fixtures/$name.json').readAsStringSync();

/// Tambahkan foto karya tiruan supaya galeri & kolase ikut teruji.
String _withArtworks(String json, String key) {
  final data = jsonDecode(json) as Map<String, dynamic>;
  data[key] = [
    for (var i = 0; i < 5; i++)
      {'url': 'https://example.test/karya-$i.jpg', 'category': i.isEven ? 'coloring' : 'sketching'},
  ];
  if (key == 'data') {
    data['categories'] = [
      {'slug': 'coloring', 'label': 'Coloring'},
      {'slug': 'sketching', 'label': 'Sketching'},
    ];
  }
  return jsonEncode(data);
}

const _me = '''
{"guardian":{"name":"Ibu Ani Rahmawati Kusumaningrum","phone":"62812****7890"},
 "students":[
  {"id":1,"student_id":"STD001","name":"Alya Putri Ramadhani Kusuma","class_type":"coloring","status":"active","is_suspended":false,"has_arrears":true,"outstanding_count":2,"outstanding_total":550000},
  {"id":2,"student_id":"STD002","name":"Bima","class_type":"sketching","status":"inactive","is_suspended":true,"has_arrears":false,"outstanding_count":0,"outstanding_total":0}],
 "summary":{"outstanding_total":550000,"overdue_count":1}}''';

const _student = '''
{"data":{"id":1,"student_id":"STD001","name":"Alya Putri Ramadhani Kusuma","class_type":"coloring","status":"active",
 "is_suspended":false,"has_arrears":true,"outstanding_count":null,"outstanding_total":null,
 "date_of_birth":"2018-05-10","age":8,"parent_name":"Ibu Ani","join_date":"2026-01-15",
 "classes":[{"category":"Basic Mewarnai","day":"Rabu","time_range":"13:30–15:00","type_label":"Reguler","tutor":"Ms Annisa"}]}}''';

const _reports = '''
{"locked":true,"locked_message":"Raport belum dapat dibuka karena ada tagihan yang lewat jatuh tempo. Silakan lunasi tagihan atau hubungi admin.",
 "data":[{"id":1,"period_label":"Oktober 2026","period_start":"2026-10-01","period_end":"2026-10-31","locked":true},
         {"id":2,"period_label":"September 2026","period_start":"2026-09-01","period_end":"2026-09-30","locked":true}]}''';

const _report = '''
{"data":{"id":1,"period_label":"Oktober 2026","period_start":"2026-10-01","period_end":"2026-10-31",
 "student":{"id":1,"name":"Alya Putri Ramadhani Kusuma"},
 "activity_notes":"Belajar gradasi warna dengan krayon dan mencampur warna primer menjadi warna sekunder.",
 "tutor_notes":"Alya makin rapi dan berani mencoba kombinasi warna baru. Pertahankan!",
 "progress_photos":[{"label":"Minggu pertama","url":"https://example.test/p1.jpg","caption":"Masih ragu memilih warna"},
                    {"label":"Minggu terakhir","url":"https://example.test/p2.jpg","caption":null}],
 "artworks":[{"url":"https://example.test/a1.jpg","taken_on":"2026-10-03","description":"Pemandangan"},
             {"url":"https://example.test/a2.jpg","taken_on":"2026-10-10","description":null},
             {"url":"https://example.test/a3.jpg","taken_on":null,"description":"Kucing"},
             {"url":"https://example.test/a4.jpg","taken_on":"2026-10-24","description":"Bunga"}]}}''';

const _unpaid = '''
{"data":[
  {"id":10,"invoice_number":"INV-2026-10-0042","student":{"id":1,"name":"Alya Putri Ramadhani Kusuma"},"billing_period":"2026-10","period_label":"Oktober 2026",
   "amount":275000,"payment_date":"2026-10-01","due_date":"2026-10-08","status":"unpaid","is_overdue":true,"days_overdue":6,"paid_at":null,"method_label":null,
   "pay_url":"https://tarakan-art-class.id/bayar/abc","bundle":{"code":"Gabungan-003","students":"Alya Putri Ramadhani Kusuma & Bima","total_due":1275000,"pay_url":"https://tarakan-art-class.id/bayar/gabungan/xyz"}},
  {"id":11,"invoice_number":"INV-2026-10-0043","student":{"id":1,"name":"Alya"},"billing_period":null,"period_label":null,
   "amount":275000,"payment_date":"2026-10-10","due_date":"2026-10-17","status":"unpaid","is_overdue":false,"days_overdue":0,"paid_at":null,"method_label":null,
   "pay_url":"https://tarakan-art-class.id/bayar/def","bundle":null}],
 "summary":{"outstanding_total":550000,"overdue_count":1},"meta":{"current_page":1,"last_page":1,"per_page":20,"total":2}}''';

const _paid = '''
{"data":[{"id":9,"invoice_number":"INV-2026-09-0011","student":{"id":1,"name":"Alya"},"billing_period":"2026-09","period_label":"September 2026",
  "amount":1250000,"payment_date":"2026-09-01","due_date":"2026-09-08","status":"paid","is_overdue":false,"days_overdue":0,
  "paid_at":"2026-09-05T03:12:00+00:00","method_label":"Transfer bank (Midtrans)","pay_url":null,"bundle":null}],
 "summary":{"outstanding_total":550000,"overdue_count":1},"meta":{"current_page":1,"last_page":3,"per_page":20,"total":45}}''';

/// Mock API yang menjawab dengan fixture.
MockClient mockApi({required bool artworks}) => MockClient((req) async {
  final path = req.url.path.replaceFirst('/api/mobile/v1', '');
  final status = req.url.queryParameters['status'];

  final (int code, String body) = switch (path) {
    '/site' => (200, artworks ? _withArtworks(_fixture('site'), 'gallery_preview') : _fixture('site')),
    '/programs' => (200, _fixture('programs')),
    '/schedule' => (200, _fixture('schedule')),
    '/gallery' => (200, artworks ? _withArtworks(_fixture('gallery'), 'data') : _fixture('gallery')),
    '/lead-options' => (200, _fixture('lead-options')),
    '/me' => (200, _me),
    '/students/1' => (200, _student),
    '/students/1/reports' => (200, _reports),
    '/students/1/reports/1' => (200, _report),
    '/students/1/reports/2' => (
      423,
      '{"message":"Raport belum dapat dibuka karena ada tagihan yang lewat jatuh tempo."}',
    ),
    '/payments' => (200, status == 'paid' ? _paid : _unpaid),
    _ => (404, '{"message":"Not found"}'),
  };
  return http.Response.bytes(utf8.encode(body), code, headers: {'content-type': 'application/json'});
});

/// Galat yang wajar di lingkungan tes: memuat gambar jaringan & font.
bool _ignorable(FlutterErrorDetails d) {
  final text = '${d.exception}\n${d.library}\n${d.context}';
  return RegExp(
    r'image|Image|HTTP request failed|SocketException|MissingPluginException|google_fonts|GoogleFonts|font|path_provider',
    caseSensitive: false,
  ).hasMatch(text);
}

Future<void> _render(
  WidgetTester tester, {
  required Widget page,
  required Size size,
  required double textScale,
  bool signedIn = false,
  bool artworks = false,
  Future<void> Function(WidgetTester)? interact,
  required String expectText,
}) async {
  final errors = <FlutterErrorDetails>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (d) {
    if (!_ignorable(d)) {
      errors.add(d);
      if (const bool.fromEnvironment("DUMP")) debugPrint(d.toString());
    }
  };

  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;

  final api = ApiClient(client: mockApi(artworks: artworks));
  if (signedIn) api.token = 'token-uji';
  final repo = Repository(api);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider.value(value: repo),
        ChangeNotifierProvider(create: (_) => signedIn ? AuthController(api) : (AuthController(api)..restore())),
        ChangeNotifierProvider(create: (_) => SiteController(repo)),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: child!),
        home: page,
      ),
    ),
  );

  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }

  // Pastikan halamannya benar-benar tampil, bukan tertahan di spinner/galat.
  // Diperiksa setelah FlutterError.onError dikembalikan (lihat akhir fungsi).
  final rendered = find.textContaining(expectText, findRichText: true, skipOffstage: false).evaluate().isNotEmpty;

  // Gulir sampai bawah supaya semua item lazy ikut dibangun.
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    for (var i = 0; i < 30; i++) {
      await tester.drag(scrollables.first, const Offset(0, -400), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  if (interact != null) await interact(tester);

  // Bongkar widget supaya timer (carousel, animasi) berhenti.
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));

  FlutterError.onError = previous;
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
  tester.platformDispatcher.clearTextScaleFactorTestValue();

  expect(rendered, isTrue, reason: 'Teks "$expectText" tidak ditemukan — halaman tidak tampil');
  expect(errors.map((e) => e.exceptionAsString()).toList(), isEmpty);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    // Penyimpanan token tiruan; tanpa ini restore() tidak pernah selesai di tes.
    FlutterSecureStorage.setMockInitialValues({});
  });

  final pages =
      <
        String,
        ({Widget page, bool signedIn, bool artworks, Future<void> Function(WidgetTester)? interact, String expectText})
      >{
        'Beranda (galeri kosong)': (
          expectText: 'Daftar Sekarang',
          page: const HomeShell(),
          signedIn: false,
          artworks: false,
          interact: null,
        ),
        'Beranda (dengan karya)': (
          expectText: 'Daftar Sekarang',
          page: const HomeShell(),
          signedIn: false,
          artworks: true,
          interact: null,
        ),
        'Program + detail': (
          expectText: 'Lihat Detail',
          page: const Scaffold(body: ProgramsPage()),
          signedIn: false,
          artworks: false,
          interact: (t) async {
            await t.drag(find.byType(Scrollable).first, const Offset(0, 4000), warnIfMissed: false);
            await t.pump(const Duration(milliseconds: 300));
            await t.tap(find.text('Lihat Detail').first, warnIfMissed: false);
            for (var i = 0; i < 6; i++) {
              await t.pump(const Duration(milliseconds: 200));
            }
          },
        ),
        'Jadwal': (
          expectText: 'Sesi terdekat',
          page: const Scaffold(body: SchedulePage()),
          signedIn: false,
          artworks: false,
          interact: null,
        ),
        'Galeri (kosong)': (
          expectText: 'Galeri segera hadir',
          page: const Scaffold(body: GalleryPage()),
          signedIn: false,
          artworks: false,
          interact: null,
        ),
        'Galeri (dengan karya)': (
          expectText: 'Coloring',
          page: const Scaffold(body: GalleryPage()),
          signedIn: false,
          artworks: true,
          interact: null,
        ),
        'Form daftar': (
          expectText: 'Data anak',
          page: const LeadFormPage(),
          signedIn: false,
          artworks: false,
          interact: null,
        ),
        'Info Ortu (login)': (
          expectText: 'Lihat raport & tagihan',
          page: const Scaffold(body: ParentPage()),
          signedIn: false,
          artworks: false,
          interact: null,
        ),
        'Info Ortu (dasbor)': (
          expectText: 'TAGIHAN BELUM DIBAYAR',
          page: const Scaffold(body: ParentPage()),
          signedIn: true,
          artworks: false,
          interact: null,
        ),
        'Profil anak': (
          expectText: 'ID murid',
          page: const StudentPage(studentId: 1, name: 'Alya Putri Ramadhani Kusuma'),
          signedIn: true,
          artworks: false,
          interact: null,
        ),
        'Raport': (
          expectText: 'Kegiatan bulan ini',
          page: const ReportDetailPage(studentId: 1, reportId: 1, title: 'Oktober 2026'),
          signedIn: true,
          artworks: false,
          interact: null,
        ),
        'Raport terkunci': (
          expectText: 'Raport ditahan',
          page: const ReportDetailPage(studentId: 1, reportId: 2, title: 'September 2026'),
          signedIn: true,
          artworks: false,
          interact: null,
        ),
        'Tagihan': (
          expectText: 'TOTAL BELUM DIBAYAR',
          page: const PaymentsPage(),
          signedIn: true,
          artworks: false,
          interact: (t) async {
            await t.tap(find.text('Riwayat lunas'));
            for (var i = 0; i < 6; i++) {
              await t.pump(const Duration(milliseconds: 250));
            }
          },
        ),
      };

  const sizes = {'360dp': Size(360, 780), '430dp': Size(430, 932)};
  const scales = [1.0, 1.3];

  for (final entry in pages.entries) {
    for (final size in sizes.entries) {
      for (final scale in scales) {
        testWidgets('${entry.key} · ${size.key} · teks ${scale}x', (tester) async {
          final p = entry.value;
          await _render(
            tester,
            page: p.page,
            size: size.value,
            textScale: scale,
            signedIn: p.signedIn,
            artworks: p.artworks,
            interact: p.interact,
            expectText: p.expectText,
          );
        });
      }
    }
  }
}
