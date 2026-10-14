import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/async_page.dart';
import '../../shared/widgets/info_row.dart';
import '../../shared/widgets/message_state.dart';
import '../../shared/widgets/open_link.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/status_badge.dart';

/// Tagihan seluruh anak: belum dibayar & riwayat lunas.
///
/// Tombol Bayar membuka halaman /bayar/{token} yang sudah ada di website
/// (Midtrans Snap). Status lunas ditentukan webhook Midtrans di server, jadi
/// daftar dimuat ulang begitu orang tua kembali ke app.
class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _unpaidKey = GlobalKey<AsyncSliverPageState<PaymentList>>();
  final _paidKey = GlobalKey<AsyncSliverPageState<PaymentList>>();
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
          title: Text('Tagihan', style: AppTextStyles.h2),
          bottom: const TabBar(tabs: [Tab(text: 'Belum dibayar'), Tab(text: 'Riwayat lunas')]),
        ),
        body: TabBarView(children: [
          AsyncSliverPage<PaymentList>(
            key: _unpaidKey,
            load: () => repo.payments(status: 'unpaid'),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            spacing: 14,
            builder: (context, list, _) => [
              _TotalCard(list: list),
              if (list.payments.isEmpty)
                const MessageState(
                  icon: Icons.verified_rounded,
                  title: 'Tidak ada tagihan',
                  body: 'Semua tagihan sudah lunas. Terima kasih!',
                  color: AppColors.success,
                )
              else
                for (final p in list.payments) _PaymentCard(p),
            ],
          ),
          AsyncSliverPage<PaymentList>(
            key: _paidKey,
            load: () => repo.payments(status: 'paid'),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            spacing: 14,
            builder: (context, list, _) => [
              if (list.payments.isEmpty)
                const MessageState(icon: Icons.receipt_long_rounded, title: 'Belum ada riwayat pembayaran')
              else ...[
                for (final p in list.payments) _PaymentCard(p),
                if (list.meta.total > list.payments.length)
                  Text('Menampilkan ${list.payments.length} pembayaran terbaru dari ${list.meta.total}.',
                      textAlign: TextAlign.center, style: AppTextStyles.small),
              ],
            ],
          ),
        ]),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.list});

  final PaymentList list;

  @override
  Widget build(BuildContext context) {
    final overdue = list.overdueCount > 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: overdue
              ? const LinearGradient(colors: [Color(0xFFE5534B), Color(0xFFC0392B)])
              : AppColors.primaryGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TOTAL BELUM DIBAYAR', style: AppTextStyles.label.copyWith(color: Colors.white)),
            const SizedBox(height: 2),
            Text(rupiah(list.outstandingTotal), style: AppTextStyles.hero.copyWith(color: Colors.white)),
            if (overdue)
              Text('${list.overdueCount} tagihan lewat jatuh tempo — raport anak ditahan sampai lunas.',
                  style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          ]),
        ),
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
    final accent = p.isPaid ? AppColors.success : (p.isOverdue ? AppColors.danger : AppColors.secondary);

    return AppCard(
      accent: accent,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.periodLabel ?? 'Tagihan', style: AppTextStyles.h3),
              Text('${p.studentName} · ${p.invoiceNumber}', style: AppTextStyles.small),
            ]),
          ),
          const SizedBox(width: 8),
          if (p.isPaid)
            const StatusBadge('Lunas', tone: Tone.success, icon: Icons.check_rounded)
          else if (p.isOverdue)
            StatusBadge('Telat ${p.daysOverdue} hari', tone: Tone.danger)
          else
            const StatusBadge('Belum dibayar', tone: Tone.warning),
        ]),
        const SizedBox(height: 8),
        Text(rupiah(p.amount), style: AppTextStyles.number.copyWith(fontSize: 26)),
        if (!p.isPaid) InfoRow(icon: Icons.event_rounded, label: 'Jatuh tempo', value: formatDate(p.dueDate)),
        if (p.isPaid) ...[
          InfoRow(icon: Icons.event_available_rounded, label: 'Dibayar', value: formatDate(p.paidAt ?? p.paymentDate)),
          if (p.methodLabel != null) InfoRow(icon: Icons.account_balance_wallet_outlined, label: 'Metode', value: p.methodLabel!),
        ],
        if (!p.isPaid && bundle != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.skySoft, borderRadius: BorderRadius.circular(16)),
            child: Text('Termasuk tagihan gabungan ${bundle.code} (${bundle.students}).',
                style: AppTextStyles.small.copyWith(color: AppColors.skyDark, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Bayar gabungan ${rupiah(bundle.totalDue)}',
            icon: Icons.payments_rounded,
            expand: true,
            onPressed: () => openLink(context, bundle.payUrl, inApp: true),
          ),
        ] else if (!p.isPaid && p.payUrl != null) ...[
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Bayar sekarang',
            icon: Icons.payments_rounded,
            expand: true,
            onPressed: () => openLink(context, p.payUrl!, inApp: true),
          ),
        ],
      ]),
    );
  }
}
