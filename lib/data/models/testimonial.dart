import 'json.dart';

class Testimonial {
  Testimonial.fromJson(Json j)
      : name = j['name'] as String? ?? '',
        role = j['role'] as String? ?? '',
        quote = j['quote'] as String? ?? '';

  final String name;
  final String role;
  final String quote;

  /// Inisial untuk avatar, mis. "Bu Sari" → "S" (sapaan diabaikan).
  String get initial {
    final words = name.split(' ').where((w) => w.isNotEmpty && !const {'Bu', 'Pak', 'Ibu', 'Bapak'}.contains(w));
    final word = words.isEmpty ? name : words.first;
    return word.isEmpty ? '?' : String.fromCharCode(word.runes.first).toUpperCase();
  }
}
