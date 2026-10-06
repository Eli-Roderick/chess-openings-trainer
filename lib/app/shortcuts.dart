import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Keyboard shortcuts (01-product-spec §15). Screens wrap their body in
// `Shortcuts(shortcuts: ..., child: Actions(actions: {...}, child: ...))`
// with the intents they support.

/// F: flip the board.
final class FlipBoardIntent extends Intent {
  /// Creates the intent.
  const new();
}

/// ←: back one move.
final class BackIntent extends Intent {
  /// Creates the intent.
  const new();
}

/// → / Space / Enter: forward one move.
final class ForwardIntent extends Intent {
  /// Creates the intent.
  const new();
}

/// Home: start position.
final class FirstIntent extends Intent {
  /// Creates the intent.
  const new();
}

/// End: end of the current line.
final class LastIntent extends Intent {
  /// Creates the intent.
  const new();
}

/// ↑ / ↓: previous / next sibling move.
final class SiblingIntent extends Intent {
  /// Creates the intent; [delta] is -1 (↑) or +1 (↓).
  const new(this.delta);

  /// Direction.
  final int delta;
}

/// Esc: leave the screen.
final class LeaveIntent extends Intent {
  /// Creates the intent.
  const new();
}

/// H: hint (drill).
final class HintIntent extends Intent {
  /// Creates the intent.
  const new();
}

/// Space / Enter: next line (drill end bar).
final class NextLineIntent extends Intent {
  /// Creates the intent.
  const new();
}

/// The drill key map (01-product-spec §15).
const drillShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.keyF): FlipBoardIntent(),
  SingleActivator(LogicalKeyboardKey.keyH): HintIntent(),
  SingleActivator(LogicalKeyboardKey.space): NextLineIntent(),
  SingleActivator(LogicalKeyboardKey.enter): NextLineIntent(),
  SingleActivator(LogicalKeyboardKey.escape): LeaveIntent(),
};

/// The Browse key map.
const browseShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.keyF): FlipBoardIntent(),
  SingleActivator(LogicalKeyboardKey.arrowLeft): BackIntent(),
  SingleActivator(LogicalKeyboardKey.arrowRight): ForwardIntent(),
  SingleActivator(LogicalKeyboardKey.space): ForwardIntent(),
  SingleActivator(LogicalKeyboardKey.enter): ForwardIntent(),
  SingleActivator(LogicalKeyboardKey.home): FirstIntent(),
  SingleActivator(LogicalKeyboardKey.end): LastIntent(),
  SingleActivator(LogicalKeyboardKey.arrowUp): SiblingIntent(-1),
  SingleActivator(LogicalKeyboardKey.arrowDown): SiblingIntent(1),
  SingleActivator(LogicalKeyboardKey.escape): LeaveIntent(),
};
