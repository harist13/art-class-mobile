import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

/// Galat dari API. [status] 0 berarti tidak terhubung ke server sama sekali.
class ApiException implements Exception {
  ApiException(this.status, this.message, [this.errors = const {}]);

  final int status;
  final String message;

  /// Galat validasi per field (respons 422).
  final Map<String, List<String>> errors;

  String? fieldError(String field) => errors[field]?.first;

  @override
  String toString() => message;
}

/// Klien HTTP ke /api/mobile/v1. Kontraknya ada di mobile.md §5 (repo
/// tarakan-art-class).
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Token login orang tua; diatur oleh AuthController.
  String? token;

  /// Dipanggil saat endpoint orang tua menjawab 401 (sesi berakhir di server).
  void Function()? onUnauthorized;

  Future<Map<String, dynamic>> get(String path, {bool auth = false}) => _send('GET', path, auth: auth);

  Future<Map<String, dynamic>> post(String path, {Object? body, bool auth = false}) =>
      _send('POST', path, body: body, auth: auth);

  Future<Map<String, dynamic>> _send(String method, String path, {Object? body, bool auth = false}) async {
    final uri = Uri.parse('$apiBaseUrl/api/mobile/v1$path');
    final headers = {
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (auth && token != null) 'Authorization': 'Bearer $token',
    };

    http.Response res;
    try {
      res = await (method == 'GET'
              ? _client.get(uri, headers: headers)
              : _client.post(uri, headers: headers, body: body == null ? null : jsonEncode(body)))
          .timeout(const Duration(seconds: 20));
    } on Exception {
      throw ApiException(0, 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }

    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      json = decoded is Map<String, dynamic> ? decoded : {};
    } on FormatException {
      json = {};
    }

    if (res.statusCode >= 400) {
      if (res.statusCode == 401 && auth) onUnauthorized?.call();
      final errors = <String, List<String>>{};
      final raw = json['errors'];
      if (raw is Map) {
        raw.forEach((k, v) => errors['$k'] = (v as List).map((e) => '$e').toList());
      }
      throw ApiException(
        res.statusCode,
        json['message'] as String? ?? 'Terjadi kesalahan (${res.statusCode}). Silakan coba lagi.',
        errors,
      );
    }

    return json;
  }
}
