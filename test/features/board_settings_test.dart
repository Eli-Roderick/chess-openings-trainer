import 'package:chessground/chessground.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/haptics/haptics_service.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/board/board_appearance.dart';
import 'package:repertoire_trainer/features/board/repertoire_board.dart';

import '../app_harness.dart';

ChessboardSettings preview(WidgetTester tester) => tester
    .widget<RepertoireBoard>(find.byKey(const Key('board-preview')))
    .settingsOverride!;

Future<AppSettings> stored(AppHarness h) async => (await h.tester.runAsync(
  () => h.container.read(settingsRepositoryProvider).load(),
))!;

void main() {
  // flutter_test runs as Android by default.
  testWidgets('board settings update the preview immediately', (tester) async {
    final h = await AppHarness.pump(tester, size: const Size(400, 1400));
    h.container.read(routerProvider).go(Routes.settingsSection('board'));
    await h.settle();
    expect(preview(tester).colorScheme, ChessboardColorScheme.brown);
    expect(preview(tester).pieceAssets, PieceSet.cburnett.assets);

    await tester.tap(find.byKey(const Key('board-theme')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('blue').last);
    await h.settle();
    expect(preview(tester).colorScheme, ChessboardColorScheme.blue);

    await tester.tap(find.byKey(const Key('piece-set')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Merida').last);
    await h.settle();
    expect(preview(tester).pieceAssets, PieceSet.merida.assets);
    // The new set is decoded into chessground's cache.
    for (var i = 0; i < 20; i++) {
      if (ChessgroundImages.instance.isAllLoaded(PieceSet.merida.assets)) {
        break;
      }
      await h.settle();
    }
    expect(
      ChessgroundImages.instance.isAllLoaded(PieceSet.merida.assets),
      isTrue,
    );

    await tester.tap(find.byKey(const Key('show-coordinates')));
    await h.settle();
    expect(preview(tester).enableCoordinates, isFalse);
    await tester.tap(find.text('Fast'));
    await h.settle();
    expect(
      preview(tester).animationDuration,
      const Duration(milliseconds: 120),
    );
    await tester.tap(find.byKey(const Key('haptics-enabled')));
    await h.settle();

    final s = await stored(h);
    expect(s.boardTheme, 'blue');
    expect(s.pieceSet, 'merida');
    expect(s.showCoordinates, isFalse);
    expect(s.animationSpeed, AnimationSpeed.fast);
    expect(s.hapticsEnabled, isFalse);
  });

  testWidgets(
    'volume slider stores the volume and plays a sample',
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
    (tester) async {
      final h = await AppHarness.pump(tester, size: const Size(400, 1400));
      h.container.read(routerProvider).go(Routes.settingsSection('board'));
      await h.settle();
      // Haptics are Android only.
      expect(find.byKey(const Key('haptics-enabled')), findsNothing);
      final slider = find.byKey(const Key('sound-volume'));
      await tester.tapAt(tester.getTopLeft(slider) + const Offset(30, 24));
      await h.settle();
      expect((await stored(h)).soundVolumePercent, lessThan(80));
      expect(h.sounds.played, ['assets/sounds/move.ogg']);
      await tester.tap(find.byKey(const Key('sounds-enabled')));
      await h.settle();
      expect((await stored(h)).soundsEnabled, isFalse);
    },
  );

  test('unknown theme and piece names fall back to the defaults', () {
    expect(boardColorScheme('nope'), ChessboardColorScheme.brown);
    expect(pieceSetNamed('nope'), PieceSet.cburnett);
    expect(
      chessboardSettings(
        const AppSettings(showLegalMoves: false, highlightLastMove: false),
      ),
      isA<ChessboardSettings>()
          .having((s) => s.showValidMoves, 'dots', isFalse)
          .having((s) => s.showLastMove, 'last move', isFalse)
          .having((s) => s.enablePremoves, 'premoves', isFalse),
    );
  });

  group('haptics', () {
    test('light and medium when on; nothing when off or on Windows', () {
      final fired = <HapticKind>[];
      var settings = const AppSettings();
      final haptics = HapticsService(
        () => settings,
        perform: (k) async => fired.add(k),
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      haptics
        ..light()
        ..medium();
      expect(fired, [HapticKind.light, HapticKind.medium]);
      settings = const AppSettings(hapticsEnabled: false);
      haptics.light();
      settings = const AppSettings();
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      haptics.medium();
      expect(fired, hasLength(2));
    });
  });
}
