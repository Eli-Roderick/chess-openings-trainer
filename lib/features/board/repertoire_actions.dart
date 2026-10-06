import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/core/files/providers.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

// Repertoire management shared by Home and Repertoire detail
// (docs/plan/01-product-spec.md §4, §6, §14).

/// Maximum name length (01 §5).
const maxRepertoireNameLength = 60;

/// Asks for a new name and renames [id]. Returns true if renamed.
Future<bool> renameRepertoire(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required String currentName,
}) async {
  final name = await showDialog<String>(
    context: context,
    builder: (context) => _RenameDialog(initial: currentName),
  );
  if (name == null || name == currentName) return false;
  await ref.read(repertoireRepositoryProvider).rename(id, name);
  return true;
}

/// Owns its text controller so it outlives the dialog's exit animation.
class _RenameDialog extends StatefulWidget {
  const new({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.renameTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('rename-field'),
          controller: _controller,
          autofocus: true,
          maxLength: maxRepertoireNameLength,
          decoration: InputDecoration(labelText: l10n.nameLabel),
          validator: (v) =>
              (v ?? '').trim().isEmpty ? l10n.errorNameRequired : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}

/// Confirms, soft-deletes [id] and offers Undo for 6 s in a SnackBar of
/// [messenger]. Returns true if deleted.
Future<bool> deleteRepertoire(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required String name,
  required ScaffoldMessengerState messenger,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deleteTitle(name)),
      content: Text(l10n.deleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('confirm-delete'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;
  final repo = ref.read(repertoireRepositoryProvider);
  await repo.softDelete(id);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.deletedSnack(name)),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => repo.undoDelete(id),
        ),
      ),
    );
  return true;
}

/// Saves the stored PGN of [id] through a save dialog (01 §14).
Future<void> exportRepertoirePgn(
  BuildContext context,
  WidgetRef ref, {
  required String id,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final row = await ref.read(repertoireRepositoryProvider).get(id);
  if (row == null) return;
  try {
    final where = await ref
        .read(fileServiceProvider)
        .saveText(fileName: pgnFileName(row.name), text: row.pgn);
    if (where != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.exportedSnack(where))),
      );
    }
  } on Object catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportFailed('$e'))));
  }
}
