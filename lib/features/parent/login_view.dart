import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api.dart';
import '../../core/auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/decorations.dart';
import '../../shared/widgets/entrance.dart';
import '../../shared/widgets/open_link.dart';
import '../../shared/widgets/page_app_bar.dart';
import '../../shared/widgets/primary_button.dart';

/// Masuk dengan nomor HP wali + credential key salah satu raport anak.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _key = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _key.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthController>().login(_phone.text.trim(), _key.text.trim());
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _Illustration(),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Lihat raport & tagihan anak Anda', style: AppTextStyles.h1),
        const SizedBox(height: 6),
        Text(
          'Masukkan nomor HP wali yang terdaftar dan credential key yang tercantum di raport anak.',
          style: AppTextStyles.bodySecondary,
        ),
      ]),
      AppCard(
        child: Form(
          key: _form,
          child: AutofillGroup(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nomor HP wali',
                  hintText: '08xx xxxx xxxx',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor HP wajib diisi.' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _key,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Credential key raport',
                  hintText: 'Contoh: TAC-012',
                  prefixIcon: Icon(Icons.key_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Credential key wajib diisi.' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.danger),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_error!, style: AppTextStyles.body.copyWith(color: AppColors.danger, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 18),
              PrimaryButton(label: 'Masuk', icon: Icons.login_rounded, expand: true, loading: _busy, onPressed: _submit),
            ]),
          ),
        ),
      ),
      AppCard(
        color: AppColors.secondarySoft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const IconBubble(Icons.help_outline_rounded, color: AppColors.secondaryDark, background: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Belum punya raport?', style: AppTextStyles.h3)),
          ]),
          const SizedBox(height: 8),
          Text(
            'Credential key ada di raport bulanan anak. Bila anak baru mendaftar dan belum menerima raport, '
            'tagihan pertama tetap bisa dibayar lewat tautan WhatsApp dari admin.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Hubungi admin',
            iconWidget: const WhatsAppIcon(size: 20, color: AppColors.whatsappDark, phoneColor: Colors.white),
            color: AppColors.whatsappDark,
            expand: true,
            onPressed: () => openWhatsApp(context, message: 'Halo admin, saya ingin menanyakan credential key raport anak saya.'),
          ),
        ]),
      ),
    ];

    return CustomScrollView(slivers: [
      const PageAppBar(title: 'Info Ortu', showBack: false),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        sliver: SliverList.list(children: [
          for (var i = 0; i < sections.length; i++)
            Padding(padding: EdgeInsets.only(bottom: i == sections.length - 1 ? 0 : 18), child: sections[i].entrance(i)),
        ]),
      ),
    ]);
  }
}

/// Ilustrasi ringan dari bentuk: blob + ikon raport & keluarga.
class _Illustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: 150,
        child: Stack(alignment: Alignment.center, children: [
          Blob(color: AppColors.primarySoft, size: 170, seed: 2),
          Positioned(left: 40, top: 6, child: Blob(color: AppColors.secondary.withValues(alpha: 0.4), size: 60, seed: 6)),
          const Positioned(right: 70, top: 18, child: Sparkle(color: AppColors.primary, size: 18)),
          const Positioned(left: 80, bottom: 18, child: Sparkle(color: AppColors.tertiary, size: 14)),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.cardShadow),
            child: const Icon(Icons.auto_stories_rounded, size: 46, color: AppColors.primary),
          ),
        ]),
      ),
    );
  }
}
