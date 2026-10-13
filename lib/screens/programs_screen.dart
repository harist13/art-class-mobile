import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import '../widgets/program_card.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<Repository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Program')),
      body: AsyncList<List<Program>>(
        load: repo.programs,
        builder: (context, programs, _) => [
          const Text('Biaya, kapasitas, dan jadwal diambil langsung dari kelas yang sedang dibuka.',
              style: mutedStyle),
          for (final p in programs) ProgramCard(p),
        ],
      ),
    );
  }
}
