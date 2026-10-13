import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/repository.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';

/// Tagihan seluruh anak: belum dibayar & riwayat lunas.
///
/// Tombol Bayar membuka halaman /bayar/{token} yang sudah ada di website
/// (Midtrans Snap). Status lunas ditentukan webhook Midtrans di server, jadi
/// daftar dimuat ulang begitu orang tua kembali ke app.
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _unpaidKey = GlobalKey<AsyncListState<PaymentList>>();
  final _paidKey = GlobalKey<AsyncListState<PaymentList>>();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _reloadAll);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _reloadAll() {
    _unpaidKey.currentState?.reload();
    _paidKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tagihan'),
          bottom: const TabBar(
            labelColor: TacColors.coralDark,
            indicatorColor: TacColors.coral,
            unselectedLabelColor: TacColors.inkSoft,
            tabs: [Tab(text: 'Belum dibayar'), Tab(text: 'Riwayat lunas')],
          ),
        ),
        body: TabBarView(children: [
          AsyncList<PaymentList>(
            key: _unpaidKey,
            load: () => repo.payments(status: 'unpaid'),
            builder: (context, list, _) => [
              TacCard(
                topColor: list.overdueCount > 0 ? TacColors.coral : TacColors.sun,
                children: [
                  const Text('TOTAL BELUM DIBAYAR', style: labelStyle),
                  Text(rupiah(list.outstandingTotal),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  if (list.overdueCount > 0)
                    Text('${list.overdueCount} tagihan lewat jatuh tempo.',
                        style: const TextStyle(color: TacColors.coralDark, fontWeight: FontWeight.w600)),
                ],
              ),
              if (list.payments.isEmpty)
                const MessageState(
                  icon: Icons.check_circle_outline,
                  title: 'Tidak ada tagihan',
                  body: 'Semua tagihan sudah lunas. Terima kasih!',
                )
              else
                for (final p in list.payments) _PaymentCard(p),
            ],
          ),
          AsyncList<PaymentList>(
            key: _paidKey,
            load: () => repo.payments(status: 'paid'),
            builder: (context, list, _) => [
              if (list.payments.isEmpty)
                const MessageState(icon: Icons.receipt_long_outlined, title: 'Belum ada riwayat pembayaran')
              else ...[
                for (final p in list.payments) _PaymentCard(p),
                if (list.meta.total > list.payments.length)
                  Text('Menampilkan ${list.payments.length} pembayaran terbaru dari ${list.meta.total}.',
                      textAlign: TextAlign.center, style: mutedStyle),
              ],
            ],
          ),
        ]),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard(this.p);

  final Payment p;

  @override
  Widget build(BuildContext context) {
    final bundle = p.bundle;

    return TacCard(
      topColor: p.isPaid ? TacColors.leaf : (p.isOverdue ? TacColors.coral : TacColors.sun),
      children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.periodLabel ?? p.invoiceNumber, style: headingStyle),
              Text('${p.studentName} · ${p.invoiceNumber}', style: mutedStyle),
            ]),
          ),
          if (p.isPaid)
            const StatusBadge('Lunas', tone: Tone.good)
          else if (p.isOverdue)
            StatusBadge('Telat ${p.daysOverdue} hari', tone: Tone.bad)
          else
            const StatusBadge('Belum dibayar', tone: Tone.warn),
        ]),
        Text(rupiah(p.amount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        if (!p.isPaid) InfoRow('Jatuh tempo', formatDate(p.dueDate)),
        if (p.isPaid) ...[
          InfoRow('Dibayar', formatDate(p.paidAt ?? p.paymentDate)),
          if (p.methodLabel != null) InfoRow('Metode', p.methodLabel!),
        ],
        if (!p.isPaid && bundle != null) ...[
          const SizedBox(height: 4),
          Text('Tagihan ini termasuk tagihan gabungan ${bundle.code} (${bundle.students}).', style: mutedStyle),
          FilledButton.icon(
            onPressed: () => openLink(context, bundle.payUrl, inApp: true),
            icon: const Icon(Icons.payments_outlined),
            label: Text('Bayar gabungan ${rupiah(bundle.totalDue)}'),
          ),
        ] else if (!p.isPaid && p.payUrl != null) ...[
          const SizedBox(height: 4),
          FilledButton.icon(
            onPressed: () => openLink(context, p.payUrl!, inApp: true),
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Bayar'),
          ),
        ],
      ],
    );
  }
}
