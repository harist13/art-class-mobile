// Format tanggal & rupiah ditulis manual supaya tidak perlu paket intl dan
// data locale tambahan hanya untuk bahasa Indonesia.

const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// "2026-10-13" atau ISO lengkap → waktu lokal.
DateTime parseDate(String value) {
  if (value.length <= 10) {
    final p = value.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1], p[2]);
  }
  return DateTime.parse(value).toLocal();
}

/// "13 Okt 2026"
String formatDate(String? value) {
  if (value == null || value.isEmpty) return '-';
  final d = parseDate(value);
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// "Selasa, 13 Okt"
String formatDayDate(String value) {
  final d = parseDate(value);
  return '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';
}

/// "Sabtu, 18 Okt 2026, 09.00 WITA"
String formatDateTime(String value) {
  final d = parseDate(value);
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}, $hh.$mm WITA';
}

/// 350000 → "Rp350.000"
String rupiah(num value) {
  final digits = value.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return 'Rp$buf';
}

/// DateTime → "2018-03-01" (format yang diterima API).
String isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Usia penuh dalam tahun.
int ageFrom(DateTime born) {
  final now = DateTime.now();
  var age = now.year - born.year;
  if (now.month < born.month || (now.month == born.month && now.day < born.day)) age--;
  return age;
}
