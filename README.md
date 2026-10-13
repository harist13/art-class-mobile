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

3. Jalankan app dengan alamat server:

   ```
   # Emulator Android (10.0.2.2 = komputer host) — ini nilai bawaan
   flutter run

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
flutter build appbundle --release --dart-define=API_URL=https://domain-anda
flutter build ipa --release --dart-define=API_URL=https://domain-anda   # butuh Mac + Xcode
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
  main.dart            # tema, provider, 5 tab bawah
  core/                # config, klien API, login, repository, format, tema
  models/models.dart   # model respons API
  widgets/             # komponen bersama
  screens/             # layar publik + screens/parent/ untuk orang tua
```

## Tes

```
flutter analyze
flutter test
```

## Hak cipta

Copyright (c) 2026 Tarakan Art Class. All Rights Reserved.

This source code is proprietary and confidential. No part of this
software may be copied, modified, distributed, or used without
prior written permission from the copyright holder.
