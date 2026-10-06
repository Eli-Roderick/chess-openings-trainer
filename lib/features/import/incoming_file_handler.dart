import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/core/files/incoming_files.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Opens PGN files handed over by other apps (P13): a new repertoire, or
/// a re-import into an existing one.
class IncomingFileHandler extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<IncomingFileHandler> createState() => _IncomingState();
}

class _IncomingState extends ConsumerState<IncomingFileHandler> {
  StreamSubscription<PickedFile>? _sub;

  @override
  void initState() {
    super.initState();
    final incoming = ref.read(incomingFilesProvider);
    _sub = incoming.opened.listen((f) => unawaited(_open(f)));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final file = await incoming.initialFile();
      if (file != null && mounted) await _open(file);
    });
  }

  Future<void> _open(PickedFile file) async {
    final router = ref.read(routerProvider);
    final repertoires = await ref.read(repertoireSummariesProvider.future);
    final context = router.routerDelegate.navigatorKey.currentContext;
    if (!mounted || context == null || !context.mounted) return;
    if (repertoires.isEmpty) {
      unawaited(router.push(Routes.newRepertoire, extra: file));
      return;
    }
    final l10n = AppLocalizations.of(context);
    final target = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          key: const Key('incoming-file'),
          shrinkWrap: true,
          children: [
            ListTile(title: Text(l10n.openFileTitle(file.name))),
            ListTile(
              key: const Key('incoming-new'),
              leading: const Icon(Icons.add),
              title: Text(l10n.newRepertoire),
              onTap: () => Navigator.of(context).pop(''),
            ),
            for (final r in repertoires)
              ListTile(
                key: Key('incoming-${r.id}'),
                leading: const Icon(Icons.upload_file_outlined),
                title: Text(l10n.reimportInto(r.name)),
                onTap: () => Navigator.of(context).pop(r.id),
              ),
          ],
        ),
      ),
    );
    if (target == null) return;
    unawaited(
      router.push(
        target.isEmpty ? Routes.newRepertoire : Routes.reimport(target),
        extra: file,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
