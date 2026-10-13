import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api.dart';
import '../../core/auth.dart';
import '../../core/repository.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

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

  Future<void> _askAdmin() async {
    try {
      final site = await context.read<Repository>().site();
      final url = site.contact.whatsappUrl;
      if (url != null && mounted) await openLink(context, url);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const Text('Lihat raport & tagihan anak',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 6),
          const Text(
            'Masukkan nomor HP wali yang terdaftar di Tarakan Art Class dan credential key '
            'yang tercantum di raport anak (contoh: TAC-012).',
            style: mutedStyle,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            decoration: const InputDecoration(
              labelText: 'Nomor HP wali',
              hintText: '08xx xxxx xxxx',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor HP wajib diisi.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _key,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Credential key raport',
              hintText: 'TAC-012',
              prefixIcon: Icon(Icons.key_outlined),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Credential key wajib diisi.' : null,
            onFieldSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TacColors.coralLight.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!, style: const TextStyle(color: TacColors.coralDark, fontWeight: FontWeight.w600)),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text('Masuk'),
          ),
          const SizedBox(height: 24),
          const TacCard(children: [
            Text('Belum punya raport?', style: headingStyle),
            Text(
              'Credential key ada di raport bulanan anak. Bila anak baru mendaftar dan belum '
              'menerima raport, tagihan pertama tetap bisa dibayar lewat tautan WhatsApp dari admin.',
              style: mutedStyle,
            ),
          ]),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _askAdmin,
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Hubungi admin via WhatsApp'),
          ),
        ],
      ),
    );
  }
}
