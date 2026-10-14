import 'json.dart';

class StudentSummary {
  StudentSummary.fromJson(Json j)
      : id = jsonInt(j['id']),
        studentId = j['student_id'] as String? ?? '',
        name = j['name'] as String,
        status = j['status'] as String? ?? '',
        isSuspended = j['is_suspended'] == true,
        hasArrears = j['has_arrears'] == true,
        outstandingCount = jsonIntOrNull(j['outstanding_count']);

  final int id;
  final String studentId;
  final String name;
  final String status;
  final bool isSuspended;
  final bool hasArrears;
  final int? outstandingCount;
}

class Me {
  Me.fromJson(Json j)
      : guardianName = jsonMap(j['guardian'])['name'] as String?,
        phone = jsonMap(j['guardian'])['phone'] as String? ?? '',
        students = jsonList(j['students'], StudentSummary.fromJson),
        outstandingTotal = jsonInt(jsonMap(j['summary'])['outstanding_total']),
        overdueCount = jsonInt(jsonMap(j['summary'])['overdue_count']);

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
        age = jsonIntOrNull(j['age']),
        joinDate = j['join_date'] as String?,
        classes = jsonList(
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
      : id = jsonInt(j['id']),
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
        reports = jsonList(j['data'], ReportSummary.fromJson);

  final bool locked;
  final String? lockedMessage;
  final List<ReportSummary> reports;
}

class ReportDetail {
  ReportDetail.fromJson(Json j)
      : summary = ReportSummary.fromJson(j),
        studentName = jsonMap(j['student'])['name'] as String? ?? '',
        activityNotes = j['activity_notes'] as String?,
        tutorNotes = j['tutor_notes'] as String?,
        progressPhotos = jsonList(j['progress_photos'],
            (p) => (label: p['label'] as String, url: p['url'] as String, caption: p['caption'] as String?)),
        artworks = jsonList(j['artworks'],
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
      : id = jsonInt(j['id']),
        invoiceNumber = j['invoice_number'] as String? ?? '-',
        studentName = jsonMap(j['student'])['name'] as String? ?? '',
        periodLabel = j['period_label'] as String?,
        amount = jsonInt(j['amount']),
        paymentDate = j['payment_date'] as String?,
        dueDate = j['due_date'] as String?,
        status = j['status'] as String,
        isOverdue = j['is_overdue'] == true,
        daysOverdue = jsonInt(j['days_overdue']),
        paidAt = j['paid_at'] as String?,
        methodLabel = j['method_label'] as String?,
        payUrl = j['pay_url'] as String?,
        bundle = j['bundle'] is Map
            ? (
                code: jsonMap(j['bundle'])['code'] as String,
                students: jsonMap(j['bundle'])['students'] as String? ?? '',
                totalDue: jsonInt(jsonMap(j['bundle'])['total_due']),
                payUrl: jsonMap(j['bundle'])['pay_url'] as String,
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
      : payments = jsonList(j['data'], Payment.fromJson),
        outstandingTotal = jsonInt(jsonMap(j['summary'])['outstanding_total']),
        overdueCount = jsonInt(jsonMap(j['summary'])['overdue_count']),
        meta = PageMeta.fromJson(jsonMap(j['meta']));

  final List<Payment> payments;
  final int outstandingTotal;
  final int overdueCount;
  final PageMeta meta;
}
