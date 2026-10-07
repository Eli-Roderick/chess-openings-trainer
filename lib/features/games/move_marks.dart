import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Colour of each classification (the app's own palette).
Color labelColor(MoveLabel label) => switch (label) {
  MoveLabel.book => const Color(0xFFA88B6A),
  MoveLabel.forced => const Color(0xFF8C9A8E),
  MoveLabel.brilliant => const Color(0xFF1FB5A0),
  MoveLabel.great => const Color(0xFF4F86C6),
  MoveLabel.best => const Color(0xFF6BAE3E),
  MoveLabel.excellent => const Color(0xFF86B84E),
  MoveLabel.good => const Color(0xFF9AAE7E),
  MoveLabel.inaccuracy => const Color(0xFFE8B730),
  MoveLabel.mistake => const Color(0xFFF08A3C),
  MoveLabel.blunder => const Color(0xFFE5452F),
  MoveLabel.miss => const Color(0xFFE0645A),
};

/// Localized name of [label].
String labelName(AppLocalizations l10n, MoveLabel label) => switch (label) {
  MoveLabel.book => l10n.moveLabelBook,
  MoveLabel.forced => l10n.moveLabelForced,
  MoveLabel.brilliant => l10n.moveLabelBrilliant,
  MoveLabel.great => l10n.moveLabelGreat,
  MoveLabel.best => l10n.moveLabelBest,
  MoveLabel.excellent => l10n.moveLabelExcellent,
  MoveLabel.good => l10n.moveLabelGood,
  MoveLabel.inaccuracy => l10n.moveLabelInaccuracy,
  MoveLabel.mistake => l10n.moveLabelMistake,
  MoveLabel.blunder => l10n.moveLabelBlunder,
  MoveLabel.miss => l10n.moveLabelMiss,
};

/// Glyph or icon inside the mark.
Widget _glyph(MoveLabel label, double size) {
  final icon = switch (label) {
    MoveLabel.book => Icons.menu_book,
    MoveLabel.forced => Icons.arrow_forward,
    MoveLabel.best => Icons.star,
    MoveLabel.excellent => Icons.thumb_up,
    MoveLabel.good => Icons.check,
    MoveLabel.miss => Icons.close,
    _ => null,
  };
  if (icon != null) {
    return Icon(icon, size: size * 0.7, color: Colors.white);
  }
  final text = switch (label) {
    MoveLabel.brilliant => '!!',
    MoveLabel.great => '!',
    MoveLabel.inaccuracy => '?!',
    MoveLabel.mistake => '?',
    _ => '??',
  };
  return Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontSize: size * 0.55,
      fontWeight: FontWeight.w800,
      height: 1,
    ),
  );
}

/// Small round classification mark.
class MoveMark extends StatelessWidget {
  /// Creates the mark.
  const new(this.label, {super.key, this.size = 16});

  /// The classification.
  final MoveLabel label;

  /// Diameter.
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: labelName(AppLocalizations.of(context), label),
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: labelColor(label),
        shape: BoxShape.circle,
      ),
      child: ExcludeSemantics(child: _glyph(label, size)),
    ),
  );
}
