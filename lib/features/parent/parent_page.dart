import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/async_page.dart';
import '../../shared/widgets/decorations.dart';
import '../../shared/widgets/open_link.dart';
import '../../shared/widgets/page_app_bar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_badge.dart';
import 'login_view.dart';
import 'payments_page.dart';
import 'student_page.dart';

/// Tab "Info Ortu": form masuk bila belum login, dasbor anak bila sudah.
class ParentPage extends StatelessWidget {
  const ParentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final signedIn = context.select<AuthController, bool>((a) => a.signedIn);
    // Key berbeda per status login supaya data dimuat ulang setelah masuk/keluar.
    return signedIn ? const _Dashboard(key: ValueKey('dashboard')) : const LoginView(key: ValueKey('login'));
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Keluar?', style: AppTextStyles.h2),
        content: Text('Anda perlu memasukkan nomor HP dan credential key lagi untuk masuk.', style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (yes == true && context.mounted) await context.read<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return AsyncSliverPage<Me>(
      load: repo.me,
      appBar: PageAppBar(
        title: 'Info Ortu',
        showBack: false,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      builder: (context, me, reload) => [
        _GreetingCard(me: me),
        _BillingCard(
          me: me,
          onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PaymentsPage()))
              .then((_) => reload()),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeader(title: 'Anak Anda', subtitle: '${me.students.length} anak terdaftar'),
          for (var i = 0; i < me.students.length; i++) ...[
            _ChildCard(
              student: me.students[i],
              colorIndex: i,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => StudentPage(studentId: me.students[i].id, name: me.students[i].name)),
              ).then((_) => reload()),
            ),
            const SizedBox(height: 12),
          ],
        ]),
        AppCard(
          onTap: () => openWhatsApp(context, message: 'Halo admin, saya orang tua murid dan ingin bertanya.'),
          semanticLabel: 'Hubungi admin lewat WhatsApp',
          child: Row(children: [
            const IconBubble(Icons.support_agent_rounded, color: AppColors.tertiaryDark, background: AppColors.tertiarySoft),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Butuh bantuan?', style: AppTextStyles.bodyStrong),
                Text('Chat admin lewat WhatsApp', style: AppTextStyles.small),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ]),
        ),
      ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.me});

  final Me me;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(children: [
          Positioned(right: -30, top: -40, child: Blob(color: Colors.white.withValues(alpha: 0.15), size: 150, seed: 4)),
          const Positioned(right: 26, bottom: 22, child: Sparkle(color: AppColors.secondary, size: 18)),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Halo, ${me.guardianName ?? 'Ayah & Bunda'} 👋', style: AppTextStyles.h1.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('Pantau raport & tagihan anak Anda di sini.', style: AppTextStyles.body.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.phone_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(me.phone, style: AppTextStyles.smallStrong.copyWith(color: Colors.white)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _BillingCard extends StatelessWidget {
  const _BillingCard({required this.me, required this.onTap});

  final Me me;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final overdue = me.overdueCount > 0;
    final hasBills = me.outstandingTotal > 0;
    final (accent, icon, bg) = overdue
        ? (AppColors.danger, Icons.warning_amber_rounded, AppColors.dangerSoft)
        : hasBills
            ? (AppColors.secondaryDark, Icons.receipt_long_rounded, AppColors.secondarySoft)
            : (AppColors.success, Icons.verified_rounded, AppColors.successSoft);

    return AppCard(
      onTap: onTap,
      semanticLabel: 'Lihat dan bayar tagihan',
      accent: accent,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          IconBubble(icon, color: accent, background: bg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TAGIHAN BELUM DIBAYAR', style: AppTextStyles.label),
              Text(rupiah(me.outstandingTotal), style: AppTextStyles.number.copyWith(fontSize: 28)),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        if (overdue)
          Text(
            '${me.overdueCount} tagihan lewat jatuh tempo. Raport anak ditahan sampai tagihan dilunasi.',
            style: AppTextStyles.body.copyWith(color: AppColors.danger, fontWeight: FontWeight.w700),
          )
        else if (!hasBills)
          Text('Semua tagihan sudah lunas. Terima kasih!', style: AppTextStyles.bodySecondary),
        const SizedBox(height: 6),
        Row(children: [
          Flexible(
            child: Text('Lihat & bayar tagihan', style: AppTextStyles.bodyStrong.copyWith(color: AppColors.primaryDark)),
          ),
          const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.primaryDark),
        ]),
      ]),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.student, required this.colorIndex, required this.onTap});

  final StudentSummary student;
  final int colorIndex;
  final VoidCallback onTap;

  static const _colors = [
    (AppColors.secondarySoft, AppColors.secondaryDark),
    (AppColors.tertiarySoft, AppColors.tertiaryDark),
    (AppColors.skySoft, AppColors.skyDark),
  ];

  @override
  Widget build(BuildContext context) {
    final s = student;
    final c = _colors[colorIndex % _colors.length];

    return AppCard(
      onTap: onTap,
      semanticLabel: 'Buka profil & raport ${s.name}',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: c.$1,
            child: Text(s.name.isEmpty ? '?' : s.name[0].toUpperCase(), style: AppTextStyles.h2.copyWith(color: c.$2)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: AppTextStyles.h3),
              Text(s.studentId, style: AppTextStyles.small),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 6, children: [
          if (s.status != 'active') const StatusBadge('Tidak aktif'),
          if (s.isSuspended) const StatusBadge('Ditangguhkan', tone: Tone.danger),
          if (s.hasArrears)
            const StatusBadge('Tagihan lewat jatuh tempo', tone: Tone.danger, icon: Icons.warning_amber_rounded)
          else if ((s.outstandingCount ?? 0) > 0)
            StatusBadge('${s.outstandingCount} tagihan berjalan', tone: Tone.warning)
          else
            const StatusBadge('Tidak ada tagihan', tone: Tone.success, icon: Icons.check_rounded),
        ]),
      ]),
    );
  }
}
