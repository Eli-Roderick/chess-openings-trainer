import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/errors/describe_error.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/core/files/providers.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// The PGN source of an import: a chosen file or pasted text.
final class PgnSourceController extends ChangeNotifier {
  PickedFile? _file;
  bool _paste = false;

  /// Pasted text.
  final TextEditingController text = TextEditingController();

  /// The chosen file, if any.
  PickedFile? get file => _file;

  /// True when the paste field is shown.
  bool get pasteMode => _paste;

  /// The bytes to import, or null if nothing was given.
  Uint8List? get bytes {
    if (_paste) {
      return text.text.trim().isEmpty
          ? null
          : Uint8List.fromList(utf8.encode(text.text));
    }
    return _file?.bytes;
  }

  set file(PickedFile? f) {
    _file = f;
    _paste = false;
    notifyListeners();
  }

  set pasteMode(bool v) {
    _paste = v;
    notifyListeners();
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }
}

/// Choose file / Paste text (01-product-spec §5).
class PgnSourcePicker extends ConsumerWidget {
  /// Creates the picker for [controller]; [errorText] shows below it.
  const new({required this.controller, this.errorText, super.key});

  /// Holds the choice.
  final PgnSourceController controller;

  /// Validation message.
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.sourceLabel, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const Key('choose-file'),
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.chooseFile),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final f = await ref.read(fileServiceProvider).pickPgn();
                    if (f != null) controller.file = f;
                  } on Object catch (e, st) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.fileReadError(
                            reportError('File read failed', e, st),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              OutlinedButton.icon(
                key: const Key('paste-text'),
                icon: const Icon(Icons.content_paste),
                label: Text(l10n.pasteText),
                onPressed: () => controller.pasteMode = true,
              ),
            ],
          ),
          if (!controller.pasteMode && controller.file != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.file!.name,
                      key: const Key('chosen-file'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (controller.pasteMode)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                key: const Key('paste-field'),
                controller: controller.text,
                minLines: 4,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: l10n.pasteHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}

/// Progress of a running import with a Cancel button.
class ImportProgressView extends StatelessWidget {
  /// Shows [stage] (a localized name).
  const new({required this.stage, required this.onCancel, super.key});

  /// Localized stage name.
  final String stage;

  /// Cancels the import.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 240, child: LinearProgressIndicator()),
          const SizedBox(height: 16),
          Text(stage, key: const Key('import-stage')),
          const SizedBox(height: 16),
          OutlinedButton(
            key: const Key('cancel-import'),
            onPressed: onCancel,
            child: Text(AppLocalizations.of(context).cancel),
          ),
        ],
      ),
    ),
  );
}
