import 'json.dart';
import 'program.dart';

class ScheduleSession {
  ScheduleSession.fromJson(Json j)
      : time = j['time'] as String,
        timeRange = j['time_range'] as String? ?? j['time'] as String,
        category = j['category'] as String? ?? '-',
        typeLabel = j['type_label'] as String? ?? '',
        tutor = j['tutor'] as String?,
        remainingSeats = jsonInt(j['remaining_seats']),
        availability = j['availability'] as String;

  final String time;
  final String timeRange;
  final String category;
  final String typeLabel;
  final String? tutor;
  final int remainingSeats;

  /// available | full | closed
  final String availability;
}

class Schedule {
  Schedule.fromJson(Json j)
      : until = j['until'] as String,
        programs = jsonList(j['programs'], Program.fromJson),
        days = jsonList(j['days'],
            (d) => (date: d['date'] as String, classes: jsonList(d['classes'], ScheduleSession.fromJson))),
        holidayClasses = jsonList(j['holiday_classes'], HolidayClass.fromJson);

  final String until;
  final List<Program> programs;
  final List<({String date, List<ScheduleSession> classes})> days;
  final List<HolidayClass> holidayClasses;
}
