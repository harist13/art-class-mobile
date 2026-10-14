import 'json.dart';

typedef Option = ({String value, String label});

/// Pilihan untuk form daftar/tanya kelas (GET /lead-options).
class LeadOptions {
  LeadOptions.fromJson(Json j)
      : programs = jsonList(j['programs'], (o) => (value: o['value'] as String, label: o['label'] as String)),
        classTypes = jsonList(j['class_types'], (o) => (value: o['value'] as String, label: o['label'] as String)),
        ageSuggestions = jsonList(j['age_suggestions'], (a) => (min: jsonInt(a['min']), value: a['value'] as String));

  final List<Option> programs;
  final List<Option> classTypes;

  /// Urut menaik menurut usia minimum.
  final List<({int min, String value})> ageSuggestions;
}
