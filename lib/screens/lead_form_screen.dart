import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api.dart';
import '../core/format.dart';
import '../core/repository.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/common.dart';

/// Form minat/daftar — sama dengan form Kontak di website. Datanya diteruskan
/// ke admin sebagai lead, bukan pendaftaran langsung.
class LeadFormScreen extends StatefulWidget {
  const LeadFormScreen({super.key, this.initialProgram});

  final String? initialProgram;

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
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
  String _classType = 'regular';
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
    try {
      final options = await context.read<Repository>().leadOptions();
      if (!mounted) return;
      setState(() {
        _options = options;
        _loadError = null;
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
          title: const Text('Terkirim'),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
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
      appBar: AppBar(title: const Text('Daftar / Tanya Kelas')),
      body: options == null
          ? Center(
              child: _loadError == null
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: MessageState(
                        icon: Icons.cloud_off_outlined,
                        title: 'Gagal memuat',
                        body: _loadError,
                        action: OutlinedButton(onPressed: _loadOptions, child: const Text('Coba lagi')),
                      ),
                    ),
            )
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  const Text(
                    'Isi data berikut, admin kami akan menghubungi Anda lewat WhatsApp untuk jadwal dan info kelas.',
                    style: mutedStyle,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _child,
                    decoration: InputDecoration(labelText: 'Nama anak', errorText: _err('child_name')),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => _required(v, 'Nama anak'),
                  ),
                  const SizedBox(height: 12),
                  FormField<DateTime>(
                    validator: (_) => _dob == null ? 'Tanggal lahir wajib diisi.' : null,
                    builder: (state) => InkWell(
                      onTap: _pickDob,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Tanggal lahir anak',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                          errorText: state.errorText ?? _err('date_of_birth'),
                        ),
                        child: Text(
                          _dob == null ? 'Pilih tanggal' : '${formatDate(isoDate(_dob!))} (${ageFrom(_dob!)} tahun)',
                          style: TextStyle(color: _dob == null ? TacColors.inkSoft : TacColors.ink),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _program,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: 'Program', errorText: _err('program')),
                    items: [
                      for (final p in options.programs) DropdownMenuItem(value: p.value, child: Text(p.label)),
                    ],
                    onChanged: (v) => setState(() => _program = v),
                    validator: (v) => v == null ? 'Pilih program.' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Tipe kelas', style: labelStyle),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, children: [
                    for (final t in options.classTypes)
                      ChoiceChip(
                        label: Text(t.label,
                            style: TextStyle(
                                color: _classType == t.value ? Colors.white : TacColors.ink,
                                fontWeight: FontWeight.w600)),
                        selected: _classType == t.value,
                        onSelected: (_) => setState(() => _classType = t.value),
                      ),
                  ]),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _parent,
                    decoration: InputDecoration(labelText: 'Nama orang tua / wali', errorText: _err('parent_name')),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => _required(v, 'Nama orang tua'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    decoration: InputDecoration(
                        labelText: 'Nomor WhatsApp', hintText: '08xx xxxx xxxx', errorText: _err('parent_phone')),
                    keyboardType: TextInputType.phone,
                    validator: (v) => _required(v, 'Nomor WhatsApp'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    decoration: InputDecoration(labelText: 'Alamat', errorText: _err('address')),
                    maxLines: 2,
                    validator: (v) => _required(v, 'Alamat'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _message,
                    decoration: InputDecoration(labelText: 'Pesan (opsional)', errorText: _err('message')),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _sending ? null : _submit,
                    child: _sending
                        ? const SizedBox(
                            width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Kirim'),
                  ),
                ],
              ),
            ),
    );
  }
}
