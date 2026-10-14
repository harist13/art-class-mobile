import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/models.dart';
import '../../data/repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/entrance.dart';
import '../../shared/widgets/message_state.dart';
import '../../shared/widgets/page_app_bar.dart';
import '../../shared/widgets/primary_button.dart';

/// Buka form daftar/tanya kelas. [program] = slug program terpilih,
/// [classType] = 'regular' atau 'visit' (trial / per pertemuan).
void openLeadForm(BuildContext context, {String? program, String? classType}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => LeadFormPage(initialProgram: program, initialClassType: classType)),
  );
}

/// Form minat/daftar — sama dengan form Kontak di website. Datanya diteruskan
/// ke admin sebagai lead, bukan pendaftaran langsung.
class LeadFormPage extends StatefulWidget {
  const LeadFormPage({super.key, this.initialProgram, this.initialClassType});

  final String? initialProgram;
  final String? initialClassType;

  @override
  State<LeadFormPage> createState() => _LeadFormPageState();
}

class _LeadFormPageState extends State<LeadFormPage> {
  final _form = GlobalKey<FormState>();
  final _child = TextEditingController();
  final _parent = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _message = TextEditingController();

  LeadOptions? _options;
  String? _loadError;
  DateTime? _dob;
  String? _program;
  late String _classType = widget.initialClassType ?? 'regular';
  bool _sending = false;
  Map<String, List<String>> _errors = {};

  @override
  void initState() {
    super.initState();
    _program = widget.initialProgram;
    _loadOptions();
  }

  @override
  void dispose() {
    for (final c in [_child, _parent, _phone, _address, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() => _loadError = null);
    try {
      final options = await context.read<Repository>().leadOptions();
      if (!mounted) return;
      setState(() {
        _options = options;
        if (!options.programs.any((p) => p.value == _program)) _program = null;
        if (options.classTypes.isNotEmpty && !options.classTypes.any((t) => t.value == _classType)) {
          _classType = options.classTypes.first.value;
        }
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _loadError = e.message);
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 6, now.month, now.day),
      firstDate: DateTime(now.year - 20),
      lastDate: now.subtract(const Duration(days: 1)),
      helpText: 'Tanggal lahir anak',
    );
    if (picked == null) return;

    setState(() {
      _dob = picked;
      // Pilih program otomatis dari usia, seperti di website — bila belum dipilih.
      if (_program == null && _options != null) {
        final age = ageFrom(picked);
        final fit = _options!.ageSuggestions.where((s) => s.min <= age).toList();
        if (fit.isNotEmpty) _program = fit.last.value;
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _errors = {});
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _sending = true);
    try {
      final message = await context.read<Repository>().submitLead({
        'child_name': _child.text.trim(),
        'child_age': _dob == null ? null : ageFrom(_dob!),
        'date_of_birth': _dob == null ? null : isoDate(_dob!),
        'class_type': _classType,
        'parent_name': _parent.text.trim(),
        'parent_phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'program': _program,
        'message': _message.text.trim().isEmpty ? null : _message.text.trim(),
      });
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.celebration_rounded, color: AppColors.primary, size: 40),
          title: Text('Terima kasih!', style: AppTextStyles.h2, textAlign: TextAlign.center),
          content: Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          actions: [PrimaryButton(label: 'Selesai', expand: true, onPressed: () => Navigator.pop(ctx))],
        ),
      );
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errors = e.errors);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String? _err(String field) => _errors[field]?.first;

  String? _required(String? v, String label) => (v == null || v.trim().isEmpty) ? '$label wajib diisi.' : null;

  @override
  Widget build(BuildContext context) {
    final options = _options;

    return Scaffold(
      body: CustomScrollView(slivers: [
        const PageAppBar(title: 'Daftar / Tanya Kelas'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
          sliver: SliverToBoxAdapter(
            child: options == null
                ? (_loadError == null
                    ? const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: CircularProgressIndicator()))
                    : MessageState(
                        icon: Icons.wifi_off_rounded,
                        title: 'Gagal memuat',
                        body: _loadError,
                        action: PrimaryButton(label: 'Coba lagi', onPressed: _loadOptions),
                      ))
                : _buildForm(options),
          ),
        ),
      ]),
    );
  }

  Widget _buildForm(LeadOptions options) {
    final sections = <Widget>[
      Text(
        'Isi data singkat berikut. Admin kami akan menghubungi Anda lewat WhatsApp untuk jadwal trial & info kelas.',
        style: AppTextStyles.bodySecondary,
      ),
      _FormCard(
        icon: Icons.child_care_rounded,
        title: 'Data anak',
        children: [
          TextFormField(
            controller: _child,
            decoration: InputDecoration(labelText: 'Nama anak', errorText: _err('child_name')),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => _required(v, 'Nama anak'),
          ),
          FormField<DateTime>(
            validator: (_) => _dob == null ? 'Tanggal lahir wajib diisi.' : null,
            builder: (state) => InkWell(
              onTap: _pickDob,
              borderRadius: BorderRadius.circular(18),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tanggal lahir anak',
                  suffixIcon: const Icon(Icons.calendar_today_rounded),
                  errorText: state.errorText ?? _err('date_of_birth'),
                ),
                child: Text(
                  _dob == null ? 'Pilih tanggal' : '${formatDate(isoDate(_dob!))} · ${ageFrom(_dob!)} tahun',
                  style: _dob == null ? AppTextStyles.bodySecondary : AppTextStyles.body,
                ),
              ),
            ),
          ),
        ],
      ),
      _FormCard(
        icon: Icons.palette_rounded,
        title: 'Program & tipe kelas',
        children: [
          FormField<String>(
            validator: (_) => _program == null ? 'Pilih salah satu program.' : null,
            builder: (state) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final p in options.programs) _choice(p.label, _program == p.value, () => setState(() => _program = p.value)),
              ]),
              if (state.errorText ?? _err('program') case final e?)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(e, style: AppTextStyles.small.copyWith(color: AppColors.danger)),
                ),
              if (_dob != null && _program != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Disarankan sesuai usia anak Anda.', style: AppTextStyles.small),
                ),
            ]),
          ),
          Text('TIPE KELAS', style: AppTextStyles.label),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in options.classTypes)
              _choice(_classTypeLabel(t), _classType == t.value, () => setState(() => _classType = t.value)),
          ]),
        ],
      ),
      _FormCard(
        icon: Icons.family_restroom_rounded,
        title: 'Data orang tua',
        children: [
          TextFormField(
            controller: _parent,
            decoration: InputDecoration(labelText: 'Nama orang tua / wali', errorText: _err('parent_name')),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => _required(v, 'Nama orang tua'),
          ),
          TextFormField(
            controller: _phone,
            decoration: InputDecoration(
              labelText: 'Nomor WhatsApp',
              hintText: '08xx xxxx xxxx',
              prefixIcon: const Icon(Icons.phone_rounded),
              errorText: _err('parent_phone'),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (v) => _required(v, 'Nomor WhatsApp'),
          ),
          TextFormField(
            controller: _address,
            decoration: InputDecoration(labelText: 'Alamat', errorText: _err('address')),
            maxLines: 2,
            validator: (v) => _required(v, 'Alamat'),
          ),
          TextFormField(
            controller: _message,
            decoration: InputDecoration(labelText: 'Pesan (opsional)', errorText: _err('message')),
            maxLines: 3,
          ),
        ],
      ),
      PrimaryButton(label: 'Kirim', icon: Icons.send_rounded, expand: true, loading: _sending, onPressed: _submit),
    ];

    return Form(
      key: _form,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          sections[i].entrance(i),
        ],
      ]),
    );
  }

  /// "Visit" di website disebut "Trial / per pertemuan" di app — istilah yang
  /// lebih dikenal orang tua. Nilai yang dikirim tetap 'visit'.
  String _classTypeLabel(Option t) => switch (t.value) {
        'visit' => 'Trial / per pertemuan',
        'regular' => 'Reguler (bulanan)',
        _ => t.label,
      };

  Widget _choice(String label, bool active, VoidCallback onTap) => ChoiceChip(
        label: Text(label),
        labelStyle: AppTextStyles.bodyStrong.copyWith(color: active ? Colors.white : AppColors.text),
        selected: active,
        onSelected: (_) => onTap(),
      );
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.icon, required this.title, required this.children});

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          IconBubble(icon, color: AppColors.primaryDark, background: AppColors.primarySoft, size: 38),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTextStyles.h3)),
        ]),
        for (final c in children) ...[const SizedBox(height: 14), c],
      ]),
    );
  }
}
