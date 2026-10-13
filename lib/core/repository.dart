import '../models/models.dart';
import 'api.dart';

/// Semua panggilan API yang dipakai layar, dalam bentuk model.
class Repository {
  Repository(this.api);

  final ApiClient api;

  // ─── Publik ──────────────────────────────────────────────────────────

  Future<Site> site() async => Site.fromJson(await api.get('/site'));

  Future<List<Program>> programs() async =>
      ((await api.get('/programs'))['data'] as List).map((e) => Program.fromJson((e as Map).cast())).toList();

  Future<Schedule> schedule() async => Schedule.fromJson(await api.get('/schedule'));

  Future<GalleryPage> gallery({String? category, int page = 1}) async {
    final q = category == null ? '' : '&kategori=${Uri.encodeQueryComponent(category)}';
    return GalleryPage.fromJson(await api.get('/gallery?page=$page$q'));
  }

  Future<LeadOptions> leadOptions() async => LeadOptions.fromJson(await api.get('/lead-options'));

  /// Mengembalikan pesan terima kasih dari server.
  Future<String> submitLead(Map<String, Object?> data) async =>
      (await api.post('/leads', body: data))['message'] as String;

  // ─── Orang tua ───────────────────────────────────────────────────────

  Future<Me> me() async => Me.fromJson(await api.get('/me', auth: true));

  Future<StudentDetail> student(int id) async =>
      StudentDetail.fromJson(((await api.get('/students/$id', auth: true))['data'] as Map).cast());

  Future<ReportList> reports(int studentId) async =>
      ReportList.fromJson(await api.get('/students/$studentId/reports', auth: true));

  /// Melempar ApiException 423 bila raport ditahan karena tunggakan.
  Future<ReportDetail> report(int studentId, int reportId) async => ReportDetail.fromJson(
      ((await api.get('/students/$studentId/reports/$reportId', auth: true))['data'] as Map).cast());

  Future<PaymentList> payments({required String status, int page = 1}) async =>
      PaymentList.fromJson(await api.get('/payments?status=$status&page=$page', auth: true));
}
