import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/repository.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';
import 'login_view.dart';
import 'payments_screen.dart';
import 'student_screen.dart';

/// Tab "Orang Tua": form masuk bila belum login, daftar anak bila sudah.
class ParentTab extends StatelessWidget {
  const ParentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final signedIn = context.select<AuthController, bool>((a) => a.signedIn);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orang Tua'),
        actions: [
          if (signedIn)
            IconButton(
              tooltip: 'Keluar',
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmLogout(context),
            ),
        ],
      ),
      // Key baru setiap status login berubah, supaya data anak dimuat ulang.
      body: signedIn ? const _Dashboard(key: ValueKey('dashboard')) : const LoginView(),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Anda perlu memasukkan nomor HP dan credential key lagi untuk masuk.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (yes == true && context.mounted) await context.read<AuthController>().logout();
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return AsyncList<Me>(
      load: repo.me,
      builder: (context, me, reload) => [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${me.guardianName ?? 'Orang Tua'}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            Text(me.phone, style: mutedStyle),
          ],
        ),
        _BillingSummary(me: me, onReturn: reload),
        Section(title: 'Anak', children: [
          for (final s in me.students)
            TacCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => StudentScreen(studentId: s.id, name: s.name)),
              ).then((_) => reload()),
              children: [
                Row(children: [
                  CircleAvatar(
                    backgroundColor: TacColors.sunLight,
                    child: Text(s.name.characters.first,
                        style: const TextStyle(color: TacColors.sunDark, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.name, style: headingStyle),
                      Text(s.studentId, style: mutedStyle),
                    ]),
                  ),
                  const Icon(Icons.chevron_right, color: TacColors.inkSoft),
                ]),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  if (s.status != 'active') const StatusBadge('Tidak aktif'),
                  if (s.isSuspended) const StatusBadge('Ditangguhkan', tone: Tone.bad),
                  if (s.hasArrears)
                    const StatusBadge('Ada tagihan lewat jatuh tempo', tone: Tone.bad)
                  else if ((s.outstandingCount ?? 0) > 0)
                    StatusBadge('${s.outstandingCount} tagihan berjalan', tone: Tone.warn)
                  else
                    const StatusBadge('Tidak ada tagihan', tone: Tone.good),
                ]),
              ],
            ),
        ]),
      ],
    );
  }
}

class _BillingSummary extends StatelessWidget {
  const _BillingSummary({required this.me, required this.onReturn});

  final Me me;
  final Future<void> Function() onReturn;

  @override
  Widget build(BuildContext context) {
    final hasBills = me.outstandingTotal > 0;

    return TacCard(
      topColor: me.overdueCount > 0 ? TacColors.coral : (hasBills ? TacColors.sun : TacColors.leaf),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PaymentsScreen()))
          .then((_) => onReturn()),
      children: [
        const Text('TAGIHAN BELUM DIBAYAR', style: labelStyle),
        Text(rupiah(me.outstandingTotal), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        if (me.overdueCount > 0)
          Text('${me.overdueCount} tagihan lewat jatuh tempo. Raport anak ditahan sampai tagihan dilunasi.',
              style: const TextStyle(color: TacColors.coralDark, fontWeight: FontWeight.w600))
        else if (!hasBills)
          const Text('Semua tagihan sudah lunas. Terima kasih!', style: mutedStyle),
        const SizedBox(height: 4),
        const Row(children: [
          Text('Lihat & bayar tagihan',
              style: TextStyle(color: TacColors.coralDark, fontWeight: FontWeight.w700)),
          Icon(Icons.chevron_right, color: TacColors.coralDark),
        ]),
      ],
    );
  }
}
