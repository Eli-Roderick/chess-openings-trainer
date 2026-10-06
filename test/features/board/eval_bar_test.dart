import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repertoire_trainer/features/board/eval_bar.dart';
import 'package:uci_engine/uci_engine.dart';

void main() {
  test('fraction: even, sigmoid in centipawns, mate fills the bar', () {
    expect(evalFraction(null), 0.5);
    expect(evalFraction(const EngineScore.cp(0)), 0.5);
    expect(evalFraction(const EngineScore.cp(100)), closeTo(0.5987, 1e-4));
    expect(evalFraction(const EngineScore.cp(-100)), closeTo(0.4013, 1e-4));
    expect(evalFraction(const EngineScore.cp(2000)), greaterThan(0.99));
    expect(evalFraction(const EngineScore.mate(3)), 1);
    expect(evalFraction(const EngineScore.mate(-1)), 0);
  });

  test('labels', () {
    expect(evalLabel(const EngineScore.cp(35)), '+0.35');
    expect(evalLabel(const EngineScore.cp(0)), '+0.00');
    expect(evalLabel(const EngineScore.cp(-120)), '-1.20');
    expect(evalLabel(const EngineScore.mate(3)), 'M3');
    expect(evalLabel(const EngineScore.mate(-2)), '-M2');
  });

  testWidgets('animates to the new score in 250 ms', (tester) async {
    Future<void> pump(EngineScore? s) => tester.pumpWidget(
      Center(
        child: SizedBox(height: 200, child: EvalBar(score: s)),
      ),
    );
    await pump(null);
    await pump(const EngineScore.mate(2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.getSize(find.byType(EvalBar)), const Size(14, 200));
  });
}
