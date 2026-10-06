import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/app/shortcuts.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// `?` lists the keyboard shortcuts, Ctrl+, opens Settings (P13).
class AppShortcuts extends ConsumerWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    BuildContext? navigator() =>
        router.routerDelegate.navigatorKey.currentContext;
    return Shortcuts(
      shortcuts: appShortcuts,
      child: Actions(
        actions: {
          ShowShortcutsIntent: _NotWhileTyping<ShowShortcutsIntent>((_) {
            final context = navigator();
            if (context != null) unawaited(showShortcutList(context));
          }),
          OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
            onInvoke: (_) => unawaited(router.push(Routes.settings)),
          ),
        },
        child: child,
      ),
    );
  }
}

/// An action that steps aside while a text field has the focus, so the
/// key (`?`) is typed instead.
final class _NotWhileTyping<T extends Intent> extends Action<T> {
  new(this._onInvoke);

  final void Function(T intent) _onInvoke;

  @override
  bool isEnabled(T intent) =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorStateOfType<EditableTextState>() ==
      null;

  @override
  Object? invoke(T intent) {
    _onInvoke(intent);
    return null;
  }
}

/// The shortcut list (01-product-spec §15).
Future<void> showShortcutList(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final groups = [
    (
      l10n.shortcutsAnywhere,
      [
        ('?', l10n.shortcutList),
        ('Ctrl+,', l10n.settings),
        ('Esc', l10n.shortcutLeave),
      ],
    ),
    (
      l10n.shortcutsDrill,
      [
        ('H', l10n.shortcutHint),
        ('F', l10n.flipBoard),
        ('Space / Enter', l10n.nextLine),
      ],
    ),
    (
      l10n.shortcutsBrowse,
      [
        ('← / →', l10n.shortcutBackForward),
        ('Space / Enter', l10n.shortcutForward),
        ('Home / End', l10n.shortcutStartEnd),
        ('↑ / ↓', l10n.shortcutSiblings),
        ('F', l10n.flipBoard),
      ],
    ),
  ];
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      key: const Key('shortcut-list'),
      title: Text(l10n.shortcutList),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (title, keys) in groups) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              for (final (key, what) in keys)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(child: Text(what)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}
