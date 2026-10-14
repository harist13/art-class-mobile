import 'package:flutter/foundation.dart';

import '../core/api.dart';
import 'models/models.dart';

/// Semua panggilan API yang dipakai layar, dalam bentuk model.
class Repository {
  Repository(this.api);

  final ApiClient api;

  // ─── Publik ──────────────────────────────────────────────────────────

  Future<Site> site() async => Site.fromJson(await api.get('/site'));

  Future<List<Program>> programs() async => jsonList((await api.get('/programs'))['data'], Program.fromJson);

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
      StudentDetail.fromJson(jsonMap((await api.get('/students/$id', auth: true))['data']));

  Future<ReportList> reports(int studentId) async =>
      ReportList.fromJson(await api.get('/students/$studentId/reports', auth: true));

  /// Melempar ApiException 423 bila raport ditahan karena tunggakan.
  Future<ReportDetail> report(int studentId, int reportId) async =>
      ReportDetail.fromJson(jsonMap((await api.get('/students/$studentId/reports/$reportId', auth: true))['data']));

  Future<PaymentList> payments({required String status, int page = 1}) async =>
      PaymentList.fromJson(await api.get('/payments?status=$status&page=$page', auth: true));
}

/// Data website (kontak, program, dll.) yang dipakai lintas layar — mis. tombol
/// WhatsApp mengambang. Dimuat sekali oleh Beranda, lalu dibagikan.
class SiteController extends ChangeNotifier {
  SiteController(this._repo);

  final Repository _repo;
  Site? site;

  Future<Site> fetch() async {
    site = await _repo.site();
    notifyListeners();
    return site!;
  }
}
