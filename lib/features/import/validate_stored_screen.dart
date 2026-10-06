import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/db/repositories/mappers.dart';
import 'package:repertoire_trainer/features/import/import_controller.dart';
import 'package:repertoire_trainer/features/import/report_view.dart';
import 'package:repertoire_trainer/features/import/source_picker.dart';
import 'package:repertoire_trainer/features/import/stage_names.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// "Validate stored PGN" (01-product-spec §6): the report of the PGN the
/// repertoire was last imported from.
class ValidateStoredScreen extends ConsumerStatefulWidget {
  /// Validates repertoire [id].
  const new({required this.id, super.key});

  /// Repertoire id.
  final String id;

  @override
  ConsumerState<ValidateStoredScreen> createState() => _ValidateState();
}

class _ValidateState extends ConsumerState<ValidateStoredScreen> {
  String? _name;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    // Not in initState itself: the controller cannot change state while the
    // tree is building.
    await Future<void>.value();
    final rep = await ref.read(repertoireRepositoryProvider).get(widget.id);
    if (rep == null || !mounted) return;
    setState(() => _name = rep.name);
    ref
        .read(importControllerProvider.notifier)
        .run(Uint8List.fromList(utf8.encode(rep.pgn)), sideFromDb(rep.color));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(importControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_name ?? l10n.importReportTitle)),
      body: switch (state) {
        ImportIdle() => const Center(child: CircularProgressIndicator()),
        ImportRunning(:final stage) => ImportProgressView(
          stage: stageName(l10n, stage),
          onCancel: () => context.pop(),
        ),
        ImportDone() => ImportReportView(
          result: state.result,
          side: state.side,
          onCancel: () => context.pop(),
        ),
        ImportFailed(:final message) => Center(
          child: Text(l10n.importFailed(message)),
        ),
      },
    );
  }
}
