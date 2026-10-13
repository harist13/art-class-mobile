import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api.dart';

/// Sesi login orang tua (nomor HP + credential key raport).
///
/// Token disimpan di Keychain/Keystore lewat flutter_secure_storage, jadi orang
/// tua tidak perlu masuk ulang setiap membuka app.
class AuthController extends ChangeNotifier {
  AuthController(this.api, {FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage() {
    api.onUnauthorized = () => _clear();
  }

  static const _tokenKey = 'parent_token';

  final ApiClient api;
  final FlutterSecureStorage _storage;

  bool _ready = false;
  bool get ready => _ready;
  bool get signedIn => api.token != null;

  Future<void> restore() async {
    try {
      api.token = await _storage.read(key: _tokenKey);
    } on Exception {
      api.token = null;
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> login(String phone, String credentialKey) async {
    final res = await api.post('/auth/login', body: {
      'phone': phone,
      'credential_key': credentialKey,
      'device_name': '${defaultTargetPlatform.name} app',
    });
    final token = res['token'] as String;
    await _storage.write(key: _tokenKey, value: token);
    api.token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await api.post('/auth/logout', auth: true);
    } on ApiException {
      // Tetap keluar secara lokal walau server tidak terjangkau.
    }
    await _clear();
  }

  Future<void> _clear() async {
    await _storage.delete(key: _tokenKey);
    api.token = null;
    notifyListeners();
  }
}
