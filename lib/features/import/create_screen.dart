import 'package:dartchess/dartchess.dart' show Side;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/features/board/repertoire_actions.dart';
import 'package:repertoire_trainer/features/import/annotation_prompt.dart';
import 'package:repertoire_trainer/features/import/import_controller.dart';
import 'package:repertoire_trainer/features/import/report_view.dart';
import 'package:repertoire_trainer/features/import/source_picker.dart';
import 'package:repertoire_trainer/features/import/stage_names.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Create a repertoire (docs/plan/01-product-spec.md §5): name, colour,
/// file or pasted PGN, Validate only / Validate and import, Copy annotation
/// prompt; then the progress and report views.
class CreateRepertoireScreen extends ConsumerStatefulWidget {
  /// Creates the screen, with [initialFile] chosen (a PGN opened from
  /// another app).
  const new({super.key, this.initialFile});

  /// The file to import, if one was handed over.
  final PickedFile? initialFile;

  @override
  ConsumerState<CreateRepertoireScreen> createState() => _CreateState();
}

class _CreateState extends ConsumerState<CreateRepertoireScreen> {
  final _name = TextEditingController();
  final _source = PgnSourceController();
  Side? _side;
  bool _submitted = false;
  bool _dryRun = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFile case final file?) {
      _source.file = file;
      _name.text = p.basenameWithoutExtension(file.name);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _source.dispose();
    super.dispose();
  }

  String? _nameError(AppLocalizations l10n) {
    final name = _name.text.trim();
    if (name.isEmpty) return l10n.errorNameRequired;
    if (name.length > maxRepertoireNameLength) return l10n.errorNameTooLong;
    return null;
  }

  void _validate({required bool dryRun}) {
    final l10n = AppLocalizations.of(context);
    setState(() => _submitted = true);
    final bytes = _source.bytes;
    if (_nameError(l10n) != null || _side == null || bytes == null) return;
    _dryRun = dryRun;
    ref.read(importControllerProvider.notifier).run(bytes, _side!);
  }

  Future<void> _import(ImportDone done) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(repertoireRepositoryProvider)
          .create(
            name: _name.text,
            color: done.side,
            pgn: done.text!,
            result: done.result,
          );
      if (mounted) context.go(Routes.repertoire(id));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _copyPrompt() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final side = _side;
    if (side == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.chooseColourFirst)));
      return;
    }
    await Clipboard.setData(
      ClipboardData(
        text: annotationPrompt(side == Side.white ? 'WHITE' : 'BLACK'),
      ),
    );
    messenger.showSnackBar(SnackBar(content: Text(l10n.promptCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(importControllerProvider);
    final controller = ref.read(importControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          state is ImportDone ? l10n.importReportTitle : l10n.createTitle,
        ),
      ),
      body: switch (state) {
        ImportIdle() => _form(l10n),
        ImportRunning(:final stage) => ImportProgressView(
          stage: stageName(l10n, stage),
          onCancel: controller.reset,
        ),
        ImportDone() => ImportReportView(
          result: state.result,
          side: state.side,
          onCancel: controller.reset,
          onImport: _dryRun || _saving ? null : () => _import(state),
        ),
        ImportFailed(:final message) => _failed(l10n, message, controller),
      },
    );
  }

  Widget _failed(
    AppLocalizations l10n,
    String message,
    ImportController controller,
  ) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.importFailed(message)),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: controller.reset, child: Text(l10n.close)),
        ],
      ),
    ),
  );

  Widget _form(AppLocalizations l10n) {
    final summaries = ref.watch(repertoireSummariesProvider).value ?? const [];
    final nameTaken = summaries.any(
      (s) => s.name.toLowerCase() == _name.text.trim().toLowerCase(),
    );
    return AdaptiveLayout(
      phone: ListView(
        padding: const EdgeInsets.all(AdaptiveLayout.gutter),
        children: [
          TextField(
            key: const Key('name-field'),
            controller: _name,
            maxLength: maxRepertoireNameLength,
            decoration: InputDecoration(
              labelText: l10n.nameLabel,
              errorText: _submitted ? _nameError(l10n) : null,
              helperText: nameTaken ? l10n.warningNameExists : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Text(l10n.colourLabel, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<Side>(
            key: const Key('colour-picker'),
            emptySelectionAllowed: true,
            segments: [
              ButtonSegment(value: Side.white, label: Text(l10n.colorWhite)),
              ButtonSegment(value: Side.black, label: Text(l10n.colorBlack)),
            ],
            selected: {?_side},
            onSelectionChanged: (s) =>
                setState(() => _side = s.isEmpty ? null : s.first),
          ),
          if (_submitted && _side == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.errorColourRequired,
                key: const Key('colour-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          PgnSourcePicker(
            controller: _source,
            errorText: _submitted && _source.bytes == null
                ? l10n.errorSourceRequired
                : null,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                key: const Key('validate-and-import'),
                onPressed: () => _validate(dryRun: false),
                child: Text(l10n.validateAndImport),
              ),
              OutlinedButton(
                key: const Key('validate-only'),
                onPressed: () => _validate(dryRun: true),
                child: Text(l10n.validateOnly),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('copy-prompt'),
              icon: const Icon(Icons.auto_awesome_outlined),
              label: Text(l10n.copyPrompt),
              onPressed: _copyPrompt,
            ),
          ),
        ],
      ),
    );
  }
}
