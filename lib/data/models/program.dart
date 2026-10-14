import 'json.dart';

class HolidayClass {
  HolidayClass.fromJson(Json j)
      : id = jsonInt(j['id']),
        name = j['name'] as String,
        startsAt = j['starts_at'] as String,
        capacity = jsonInt(j['capacity']),
        price = jsonIntOrNull(j['price']);

  final int id;
  final String name;
  final String startsAt;
  final int capacity;
  final int? price;
}

class Program {
  Program.fromJson(Json j)
      : slug = j['slug'] as String,
        name = j['name'] as String,
        age = j['age'] as String?,
        duration = j['duration'] as String?,
        capacity = j['capacity'] as String?,
        price = j['price'] as String?,
        visitPrice = j['visit_price'] as String?,
        scheduleSummary = j['schedule_summary'] as String?,
        schedule = j['schedule'] as String?,
        color = j['color'] as String?,
        icon = j['icon'] as String?,
        summary = (j['summary'] as String?)?.replaceAll(RegExp(r'\s*\n\s*'), ' '),
        highlights = jsonStrings(j['highlights']),
        isLive = j['is_live'] == true,
        isHoliday = j['is_holiday'] == true,
        canRegister = j['can_register'] == true,
        nextHoliday = j['next_holiday'] is Map ? HolidayClass.fromJson(jsonMap(j['next_holiday'])) : null;

  final String slug;
  final String name;
  final String? age;
  final String? duration;
  final String? capacity;
  final String? price;

  /// Tarif sekali datang. Di layar disebut "Per pertemuan" (API: visit_price).
  final String? visitPrice;
  final String? scheduleSummary;
  final String? schedule;
  final String? color;
  final String? icon;
  final String? summary;
  final List<String> highlights;
  final bool isLive;
  final bool isHoliday;
  final bool canRegister;
  final HolidayClass? nextHoliday;
}
