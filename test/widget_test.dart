import 'package:art_class_mobile/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rupiah memakai titik sebagai pemisah ribuan', () {
    expect(rupiah(0), 'Rp0');
    expect(rupiah(950), 'Rp950');
    expect(rupiah(275000), 'Rp275.000');
    expect(rupiah(1250000), 'Rp1.250.000');
  });

  test('tanggal ditulis dalam bahasa Indonesia', () {
    expect(formatDate('2026-10-13'), '13 Okt 2026');
    expect(formatDate(null), '-');
    expect(formatDayDate('2026-10-13'), 'Selasa, 13 Okt');
  });

  test('usia dihitung dari tanggal lahir', () {
    final now = DateTime.now();
    expect(ageFrom(DateTime(now.year - 7, now.month, now.day)), 7);
    expect(ageFrom(DateTime(now.year - 7, now.month, now.day).add(const Duration(days: 1))), 6);
  });
}
