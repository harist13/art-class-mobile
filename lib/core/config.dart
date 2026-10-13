/// Alamat backend Laravel (repo tarakan-art-class), diisi saat build:
///
///   flutter run --dart-define=API_URL=http://192.168.1.10:8000
///
/// Bawaannya 10.0.2.2 — alamat komputer host bila dijalankan di emulator Android.
const apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000');
