import 'dart:async';

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/audio/sound_service.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_appearance.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Italian Game after 3.Bc4, for the preview.
const _previewFen =
    'r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3';

/// Settings → Board and sound (01-product-spec §10) with a live preview.
class BoardSettingsPage extends ConsumerWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider).value ?? const AppSettings();
    void update(AppSettings Function(AppSettings) change) =>
        unawaited(ref.read(settingsRepositoryProvider).update(change));
    final showHaptics = defaultTargetPlatform == TargetPlatform.android;
    return ListView(
      key: const Key('board-settings'),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: AspectRatio(
                aspectRatio: 1,
                child: RepertoireBoard(
                  key: const Key('board-preview'),
                  state: const BoardViewState(
                    fen: _previewFen,
                    orientation: Side.white,
                    lastMove: NormalMove(from: Square.f1, to: Square.c4),
                  ),
                  settingsOverride: chessboardSettings(s),
                ),
              ),
            ),
          ),
        ),
        ListTile(
          title: Text(l10n.boardTheme),
          trailing: DropdownButton<String>(
            key: const Key('board-theme'),
            value: boardColorSchemes.containsKey(s.boardTheme)
                ? s.boardTheme
                : 'brown',
            onChanged: (v) {
              if (v != null) update((s) => s.copyWith(boardTheme: v));
            },
            items: [
              for (final name in boardColorSchemes.keys)
                DropdownMenuItem(value: name, child: Text(name)),
            ],
          ),
        ),
        ListTile(
          title: Text(l10n.pieceSet),
          trailing: DropdownButton<String>(
            key: const Key('piece-set'),
            value: pieceSetNamed(s.pieceSet).name,
            onChanged: (v) {
              if (v != null) update((s) => s.copyWith(pieceSet: v));
            },
            items: [
              for (final set in PieceSet.values)
                DropdownMenuItem(value: set.name, child: Text(set.label)),
            ],
          ),
        ),
        SwitchListTile(
          key: const Key('show-coordinates'),
          title: Text(l10n.showCoordinates),
          value: s.showCoordinates,
          onChanged: (v) => update((s) => s.copyWith(showCoordinates: v)),
        ),
        SwitchListTile(
          key: const Key('show-legal-moves'),
          title: Text(l10n.showLegalMoves),
          value: s.showLegalMoves,
          onChanged: (v) => update((s) => s.copyWith(showLegalMoves: v)),
        ),
        SwitchListTile(
          key: const Key('highlight-last-move'),
          title: Text(l10n.highlightLastMove),
          value: s.highlightLastMove,
          onChanged: (v) => update((s) => s.copyWith(highlightLastMove: v)),
        ),
        ListTile(title: Text(l10n.animationSpeed)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<AnimationSpeed>(
            key: const Key('animation-speed'),
            segments: [
              for (final (speed, label) in [
                (AnimationSpeed.slow, l10n.animationSlow),
                (AnimationSpeed.normal, l10n.animationNormal),
                (AnimationSpeed.fast, l10n.animationFast),
                (AnimationSpeed.off, l10n.animationOff),
              ])
                ButtonSegment(value: speed, label: Text(label)),
            ],
            selected: {s.animationSpeed},
            onSelectionChanged: (v) =>
                update((s) => s.copyWith(animationSpeed: v.single)),
          ),
        ),
        SwitchListTile(
          key: const Key('sounds-enabled'),
          title: Text(l10n.soundsEnabled),
          value: s.soundsEnabled,
          onChanged: (v) => update((s) => s.copyWith(soundsEnabled: v)),
        ),
        ListTile(
          title: Text(l10n.soundVolume),
          subtitle: Slider(
            key: const Key('sound-volume'),
            value: s.soundVolumePercent.toDouble(),
            max: 100,
            divisions: 20,
            label: '${s.soundVolumePercent} %',
            onChanged: s.soundsEnabled
                ? (v) =>
                      update((s) => s.copyWith(soundVolumePercent: v.round()))
                : null,
            onChangeEnd: (_) =>
                ref.read(soundServiceProvider).play(SoundType.move),
          ),
        ),
        if (showHaptics)
          SwitchListTile(
            key: const Key('haptics-enabled'),
            title: Text(l10n.hapticsEnabled),
            value: s.hapticsEnabled,
            onChanged: (v) => update((s) => s.copyWith(hapticsEnabled: v)),
          ),
      ],
    );
  }
}
