// Helper kecil untuk membaca JSON API dengan aman.

typedef Json = Map<String, dynamic>;

List<T> jsonList<T>(Object? raw, T Function(Json) f) =>
    raw is List ? raw.whereType<Map>().map((e) => f(e.cast<String, dynamic>())).toList() : <T>[];

List<String> jsonStrings(Object? raw) => raw is List ? raw.map((e) => '$e').toList() : const [];

int jsonInt(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

int? jsonIntOrNull(Object? v) => v == null ? null : jsonInt(v);

Json jsonMap(Object? raw) => raw is Map ? raw.cast<String, dynamic>() : <String, dynamic>{};

class PageMeta {
  PageMeta.fromJson(Json j)
      : currentPage = jsonInt(j['current_page']),
        lastPage = jsonInt(j['last_page']),
        total = jsonInt(j['total']);

  final int currentPage;
  final int lastPage;
  final int total;
}
