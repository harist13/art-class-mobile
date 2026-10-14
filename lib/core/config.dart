/// Alamat backend Laravel (repo tarakan-art-class).
///
/// Bawaannya server production. Untuk mencoba dengan server lokal, timpa saat build:
///
///   flutter run --dart-define=API_URL=http://10.0.2.2:8000      (emulator Android)
///   flutter run --dart-define=API_URL=http://192.168.1.10:8000  (HP di Wi-Fi yang sama)
const apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'https://tarakan-art-class.id');
