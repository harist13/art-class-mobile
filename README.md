# Tarakan Art Class — Aplikasi Orang Tua (Flutter)

Aplikasi Android & iOS untuk orang tua dan calon orang tua murid:

- **Publik:** beranda, program, jadwal, galeri karya, kontak, form daftar/tanya kelas.
- **Orang tua** (masuk dengan nomor HP wali + credential key raport): daftar anak,
  raport bulanan, tagihan, dan tombol bayar (halaman Midtrans di website).

Datanya diambil dari API `/api/mobile/v1` di proyek Laravel `tarakan-art-class`.
Rencana lengkap dan kontrak API ada di `tarakan-art-class/mobile.md`.

## Menjalankan

1. Jalankan backend Laravel dan pastikan migrasinya sudah dijalankan
   (`php artisan migrate` di folder `tarakan-art-class`).
2. Jalankan server Laravel agar bisa diakses dari HP/emulator:

   ```
   php artisan serve --host=0.0.0.0 --port=8000
   ```

3. Jalankan app. Bawaannya memakai server production (`https://tarakan-art-class.id`);
   untuk server lokal, timpa alamatnya:

   ```
   # Production (bawaan)
   flutter run

   # Emulator Android ke Laragon (10.0.2.2 = komputer host)
   flutter run --dart-define=API_URL=http://10.0.2.2:8000

   # HP sungguhan di Wi-Fi yang sama — pakai IP komputer
   flutter run --dart-define=API_URL=http://192.168.1.10:8000
   ```

Build debug Android mengizinkan `http://`; build rilis wajib `https://`.

### Foto tidak muncul?

URL foto dibuat server dari `APP_URL` di `.env` Laravel. Saat diuji dari HP,
isi `APP_URL` dengan alamat yang bisa dijangkau HP (mis. `http://192.168.1.10:8000`),
dan pastikan `php artisan storage:link` sudah dijalankan.

## Build rilis

```
flutter build apk --release        # APK untuk dibagikan langsung
flutter build appbundle --release  # untuk Play Store
flutter build ipa --release        # butuh Mac + Xcode
```

Sebelum rilis:

- Ikon app dibuat dari logo navbar website (`public/images/ogo.jpg`), yang aslinya
  hanya 225×225 lalu diperbesar ke 1024×1024 sehingga sedikit buram. Untuk rilis
  store, ganti `assets/icon/icon.png` (logo penuh) dan `assets/icon/icon_foreground.png`
  (logo di ~64% tengah, untuk adaptive icon Android) dengan versi resolusi tinggi,
  lalu jalankan `dart run flutter_launcher_icons`.
- Atur signing Android (`android/key.properties`) dan Apple Developer team di Xcode.
- Siapkan kebijakan privasi dan akun demo untuk review store (lihat `mobile.md` §9).

## Struktur

```
lib/
  main.dart                     # tema, provider, 5 tab bawah, tombol WhatsApp mengambang
  core/
    api.dart, auth.dart, config.dart, format.dart
    constants/app_strings.dart  # copy khusus app, kontak cadangan, AppAssets
    theme/                      # app_colors, app_text_styles (Baloo 2 + Nunito), app_theme
  data/
    models/                     # program, testimonial, artwork, site, schedule, lead, parent
    repository.dart             # semua panggilan API + SiteController
  features/
    home/                       # home_page + widgets/ (hero, stats, galeri, program, langkah,
                                #   testimoni, tentang, lokasi, FAQ, CTA penutup)
    programs/ schedule/ gallery/ lead/
    parent/                     # login, dasbor, profil anak, raport, tagihan
  shared/widgets/               # tombol, kartu, badge, header seksi, foto + shimmer,
                                #   penampil foto, pemuat halaman, ornamen, navigasi
```

Data selalu dari API (sama dengan website). Hanya copy pemasaran khusus app
(judul hero, langkah pendaftaran, CTA) yang ada di `app_strings.dart`.

### Paket tampilan

| Paket | Versi | Untuk |
|---|---|---|
| google_fonts | ^8.2.1 | Baloo 2 (judul) & Nunito (isi), diunduh saat pertama dibuka |
| flutter_animate | ^4.5.2 | Animasi masuk tiap seksi |
| shimmer | ^4.0.0 | Skeleton saat memuat |
| smooth_page_indicator | ^3.0.0 | Titik indikator testimoni |
| cached_network_image | ^4.0.3 | Foto karya & raport |
| url_launcher | ^6.3.3 | WhatsApp, Maps, Instagram, halaman bayar |

### Mengganti gambar placeholder di hero

Kolase hero memakai, berurutan: gambar di `AppAssets.heroImages` → 3 foto karya
terbaru dari galeri → ilustrasi bentuk (tanpa aset). Untuk memakai foto sendiri:

1. Taruh berkas di `assets/images/hero/` (mis. `karya-1.jpg` … `karya-3.jpg`, persegi).
2. Daftarkan folder itu di `pubspec.yaml` → `flutter: assets:` (`- assets/images/hero/`).
3. Isi `AppAssets.heroImages` di `lib/core/constants/app_strings.dart`.

## Tes

```
flutter analyze
flutter test
```

`test/ui_layout_test.dart` merender setiap halaman dengan data berbentuk respons
API production (`test/fixtures/`) di lebar 360dp & 430dp, skala teks 1.0× & 1.3×,
lalu menggulir sampai bawah. Tes gagal bila ada overflow atau halaman tidak tampil.

## Hak cipta

Copyright (c) 2026 Tarakan Art Class. All Rights Reserved.

This source code is proprietary and confidential. No part of this
software may be copied, modified, distributed, or used without
prior written permission from the copyright holder.
