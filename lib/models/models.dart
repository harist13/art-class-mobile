// Model respons /api/mobile/v1 — lihat mobile.md §5 di repo tarakan-art-class.

typedef Json = Map<String, dynamic>;

List<T> _list<T>(Object? raw, T Function(Json) f) =>
    raw is List ? raw.whereType<Map>().map((e) => f(e.cast<String, dynamic>())).toList() : <T>[];

List<String> _strings(Object? raw) => raw is List ? raw.map((e) => '$e').toList() : const [];

int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

// ─── Publik ────────────────────────────────────────────────────────────

class HolidayClass {
  HolidayClass.fromJson(Json j)
      : id = _int(j['id']),
        name = j['name'] as String,
        startsAt = j['starts_at'] as String,
        capacity = _int(j['capacity']),
        price = j['price'] == null ? null : _int(j['price']);

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
        summary = j['summary'] as String?,
        highlights = _strings(j['highlights']),
        isLive = j['is_live'] == true,
        isHoliday = j['is_holiday'] == true,
        canRegister = j['can_register'] == true,
        nextHoliday = j['next_holiday'] is Map ? HolidayClass.fromJson((j['next_holiday'] as Map).cast()) : null;

  final String slug;
  final String name;
  final String? age;
  final String? duration;
  final String? capacity;
  final String? price;
  final String? visitPrice;
  final String? scheduleSummary;
  final String? schedule;
  final String? color;
  final String? summary;
  final List<String> highlights;
  final bool isLive;
  final bool isHoliday;
  final bool canRegister;
  final HolidayClass? nextHoliday;
}

class GalleryItem {
  GalleryItem.fromJson(Json j)
      : url = j['url'] as String,
        category = j['category'] as String?;

  final String url;
  final String? category;
}

class Contact {
  Contact.fromJson(Json j)
      : whatsappDisplay = j['whatsapp_display'] as String?,
        whatsappUrl = j['whatsapp_url'] as String?,
        email = j['email'] as String?,
        instagram = j['instagram'] as String?,
        instagramUrl = j['instagram_url'] as String?,
        address = j['address'] as String?;

  final String? whatsappDisplay;
  final String? whatsappUrl;
  final String? email;
  final String? instagram;
  final String? instagramUrl;
  final String? address;
}

class Site {
  Site.fromJson(Json j)
      : name = j['name'] as String,
        tagline = j['tagline'] as String? ?? '',
        description = j['description'] as String? ?? '',
        contact = Contact.fromJson((j['contact'] as Map).cast()),
        hours = _list(j['hours'], (h) => (day: h['day'] as String, time: h['time'] as String)),
        story = (j['about'] as Map?)?['story'] as String?,
        vision = (j['about'] as Map?)?['vision'] as String?,
        mission = _strings((j['about'] as Map?)?['mission']),
        methods = _list((j['about'] as Map?)?['methods'], (m) => (title: m['title'] as String, body: m['body'] as String)),
        stats = _list((j['about'] as Map?)?['stats'], (s) => (value: '${s['value']}', label: s['label'] as String)),
        testimonials = _list(
            j['testimonials'], (t) => (name: t['name'] as String, role: t['role'] as String, quote: t['quote'] as String)),
        faq = _list(j['faq'], (f) => (q: f['q'] as String, a: f['a'] as String)),
        programs = _list(j['programs'], Program.fromJson),
        holidayClasses = _list(j['holiday_classes'], HolidayClass.fromJson),
        galleryPreview = _list(j['gallery_preview'], GalleryItem.fromJson);

  final String name;
  final String tagline;
  final String description;
  final Contact contact;
  final List<({String day, String time})> hours;
  final String? story;
  final String? vision;
  final List<String> mission;
  final List<({String title, String body})> methods;
  final List<({String value, String label})> stats;
  final List<({String name, String role, String quote})> testimonials;
  final List<({String q, String a})> faq;
  final List<Program> programs;
  final List<HolidayClass> holidayClasses;
  final List<GalleryItem> galleryPreview;
}

class ScheduleSession {
  ScheduleSession.fromJson(Json j)
      : time = j['time'] as String,
        category = j['category'] as String? ?? '-',
        typeLabel = j['type_label'] as String? ?? '',
        tutor = j['tutor'] as String?,
        remainingSeats = _int(j['remaining_seats']),
        availability = j['availability'] as String;

  final String time;
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
        programs = _list(j['programs'], Program.fromJson),
        days = _list(j['days'],
            (d) => (date: d['date'] as String, classes: _list(d['classes'], ScheduleSession.fromJson))),
        holidayClasses = _list(j['holiday_classes'], HolidayClass.fromJson);

  final String until;
  final List<Program> programs;
  final List<({String date, List<ScheduleSession> classes})> days;
  final List<HolidayClass> holidayClasses;
}

class PageMeta {
  PageMeta.fromJson(Json j)
      : currentPage = _int(j['current_page']),
        lastPage = _int(j['last_page']),
        total = _int(j['total']);

  final int currentPage;
  final int lastPage;
  final int total;
}

class GalleryPage {
  GalleryPage.fromJson(Json j)
      : items = _list(j['data'], GalleryItem.fromJson),
        categories = _list(j['categories'], (c) => (slug: c['slug'] as String, label: c['label'] as String)),
        meta = PageMeta.fromJson((j['meta'] as Map).cast());

  final List<GalleryItem> items;
  final List<({String slug, String label})> categories;
  final PageMeta meta;
}

typedef Option = ({String value, String label});

class LeadOptions {
  LeadOptions.fromJson(Json j)
      : programs = _list(j['programs'], (o) => (value: o['value'] as String, label: o['label'] as String)),
        classTypes = _list(j['class_types'], (o) => (value: o['value'] as String, label: o['label'] as String)),
        ageSuggestions = _list(j['age_suggestions'], (a) => (min: _int(a['min']), value: a['value'] as String));

  final List<Option> programs;
  final List<Option> classTypes;

  /// Urut menaik menurut usia minimum.
  final List<({int min, String value})> ageSuggestions;
}

// ─── Orang tua ─────────────────────────────────────────────────────────

class StudentSummary {
  StudentSummary.fromJson(Json j)
      : id = _int(j['id']),
        studentId = j['student_id'] as String? ?? '',
        name = j['name'] as String,
        classType = j['class_type'] as String?,
        status = j['status'] as String? ?? '',
        isSuspended = j['is_suspended'] == true,
        hasArrears = j['has_arrears'] == true,
        outstandingCount = j['outstanding_count'] == null ? null : _int(j['outstanding_count']),
        outstandingTotal = j['outstanding_total'] == null ? null : _int(j['outstanding_total']);

  final int id;
  final String studentId;
  final String name;
  final String? classType;
  final String status;
  final bool isSuspended;
  final bool hasArrears;
  final int? outstandingCount;
  final int? outstandingTotal;
}

class Me {
  Me.fromJson(Json j)
      : guardianName = (j['guardian'] as Map)['name'] as String?,
        phone = (j['guardian'] as Map)['phone'] as String,
        students = _list(j['students'], StudentSummary.fromJson),
        outstandingTotal = _int((j['summary'] as Map)['outstanding_total']),
        overdueCount = _int((j['summary'] as Map)['overdue_count']);

  final String? guardianName;
  final String phone;
  final List<StudentSummary> students;
  final int outstandingTotal;
  final int overdueCount;
}

class StudentDetail {
  StudentDetail.fromJson(Json j)
      : summary = StudentSummary.fromJson(j),
        dateOfBirth = j['date_of_birth'] as String?,
        age = j['age'] == null ? null : _int(j['age']),
        joinDate = j['join_date'] as String?,
        classes = _list(
          j['classes'],
          (c) => (
            category: c['category'] as String? ?? '-',
            day: c['day'] as String? ?? '-',
            timeRange: c['time_range'] as String? ?? '',
            typeLabel: c['type_label'] as String? ?? '',
            tutor: c['tutor'] as String?,
          ),
        );

  final StudentSummary summary;
  final String? dateOfBirth;
  final int? age;
  final String? joinDate;
  final List<({String category, String day, String timeRange, String typeLabel, String? tutor})> classes;
}

class ReportSummary {
  ReportSummary.fromJson(Json j)
      : id = _int(j['id']),
        periodLabel = j['period_label'] as String,
        periodStart = j['period_start'] as String,
        periodEnd = j['period_end'] as String,
        locked = j['locked'] == true;

  final int id;
  final String periodLabel;
  final String periodStart;
  final String periodEnd;
  final bool locked;
}

class ReportList {
  ReportList.fromJson(Json j)
      : locked = j['locked'] == true,
        lockedMessage = j['locked_message'] as String?,
        reports = _list(j['data'], ReportSummary.fromJson);

  final bool locked;
  final String? lockedMessage;
  final List<ReportSummary> reports;
}

class ReportDetail {
  ReportDetail.fromJson(Json j)
      : summary = ReportSummary.fromJson(j),
        studentName = (j['student'] as Map)['name'] as String,
        activityNotes = j['activity_notes'] as String?,
        tutorNotes = j['tutor_notes'] as String?,
        progressPhotos = _list(j['progress_photos'],
            (p) => (label: p['label'] as String, url: p['url'] as String, caption: p['caption'] as String?)),
        artworks = _list(j['artworks'],
            (a) => (url: a['url'] as String, takenOn: a['taken_on'] as String?, description: a['description'] as String?));

  final ReportSummary summary;
  final String studentName;
  final String? activityNotes;
  final String? tutorNotes;
  final List<({String label, String url, String? caption})> progressPhotos;
  final List<({String url, String? takenOn, String? description})> artworks;
}

class Payment {
  Payment.fromJson(Json j)
      : id = _int(j['id']),
        invoiceNumber = j['invoice_number'] as String? ?? '-',
        studentName = (j['student'] as Map)['name'] as String,
        periodLabel = j['period_label'] as String?,
        amount = _int(j['amount']),
        paymentDate = j['payment_date'] as String?,
        dueDate = j['due_date'] as String?,
        status = j['status'] as String,
        isOverdue = j['is_overdue'] == true,
        daysOverdue = _int(j['days_overdue']),
        paidAt = j['paid_at'] as String?,
        methodLabel = j['method_label'] as String?,
        payUrl = j['pay_url'] as String?,
        bundle = j['bundle'] is Map
            ? (
                code: (j['bundle'] as Map)['code'] as String,
                students: (j['bundle'] as Map)['students'] as String? ?? '',
                totalDue: _int((j['bundle'] as Map)['total_due']),
                payUrl: (j['bundle'] as Map)['pay_url'] as String,
              )
            : null;

  final int id;
  final String invoiceNumber;
  final String studentName;
  final String? periodLabel;
  final int amount;
  final String? paymentDate;
  final String? dueDate;

  /// paid | unpaid
  final String status;
  final bool isOverdue;
  final int daysOverdue;
  final String? paidAt;
  final String? methodLabel;
  final String? payUrl;
  final ({String code, String students, int totalDue, String payUrl})? bundle;

  bool get isPaid => status == 'paid';
}

class PaymentList {
  PaymentList.fromJson(Json j)
      : payments = _list(j['data'], Payment.fromJson),
        outstandingTotal = _int((j['summary'] as Map)['outstanding_total']),
        overdueCount = _int((j['summary'] as Map)['overdue_count']),
        meta = PageMeta.fromJson((j['meta'] as Map).cast());

  final List<Payment> payments;
  final int outstandingTotal;
  final int overdueCount;
  final PageMeta meta;
}
