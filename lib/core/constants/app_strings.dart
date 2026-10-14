/// Teks & konstanta milik aplikasi.
///
/// Data operasional (program, harga, jadwal, kontak, testimoni, FAQ) tetap
/// diambil dari API supaya selalu sama dengan website. Yang di sini hanya
/// copy pemasaran khusus app dan nilai cadangan bila API belum termuat.
abstract final class AppStrings {
  static const appName = 'Tarakan Art Class';

  // ─── Kontak cadangan (nilai sebenarnya datang dari /api/mobile/v1/site) ──
  static const whatsappNumber = '6285217423987';
  static const whatsappUrl = 'https://wa.me/$whatsappNumber';
  static const address =
      'Jalan Gajah Mada No. 31, Tarakan, Kalimantan Utara (sebelum Mangrove, ruko 2 pintu warna kuning cokelat)';
  static const mapsUrl = 'https://www.google.com/maps/search/?api=1&query=Tarakan%20Art%20Class%20Tarakan';

  // ─── Hero ───────────────────────────────────────────────────────────
  static const heroTitleStart = 'Kelas seni yang bikin anak Anda ';
  static const heroTitleHighlight = 'berani berkarya';
  static const heroSubtitle = 'Kelas kecil 3–4 anak per tutor, dari dasar, tanpa takut salah.';

  // ─── Tentang (ringkas, sudut pandang orang tua) ─────────────────────
  static const aboutIntro =
      'Tarakan Art Class adalah ruang belajar seni dari dasar untuk anak Anda. '
      'Kami memberi ruang berkreasi, bereksplorasi, dan berkarya tanpa takut salah.';

  // ─── Alur pendaftaran ───────────────────────────────────────────────
  static const steps = [
    (title: 'Pilih program', body: 'Sesuaikan dengan usia & minat anak Anda.'),
    (title: 'Jadwal trial', body: 'Admin menghubungi Anda untuk sesi percobaan.'),
    (title: 'Mulai berkarya', body: 'Anak Anda belajar di kelas kecil yang hangat.'),
  ];

  // ─── CTA penutup ────────────────────────────────────────────────────
  static const closingTitle = 'Coba kelas trial hari ini';
  static const closingBody = 'Satu sesi percobaan untuk melihat apakah anak Anda cocok dengan kelasnya.';

  /// Pesan pembuka chat WhatsApp dari tombol mengambang.
  static const whatsappGreeting = 'Halo Tarakan Art Class, saya ingin bertanya tentang kelas untuk anak saya.';
}

/// Gambar placeholder hero. Kosong = kolase memakai foto karya terbaru dari
/// galeri; bila galeri juga kosong, tampil ilustrasi bentuk (tanpa aset).
/// Untuk memakai foto sendiri: taruh berkas di assets/images/hero/ lalu
/// daftarkan path-nya di sini, mis. 'assets/images/hero/karya-1.jpg'.
abstract final class AppAssets {
  static const logo = 'assets/images/logo.jpg';
  static const heroImages = <String>[];
}
