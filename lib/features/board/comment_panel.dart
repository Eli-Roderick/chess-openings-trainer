import 'package:chess_core/chess_core.dart';
import 'package:flutter/material.dart';
import 'package:repertoire_trainer/app/theme/colors.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// The structured comment of one user move (01-product-spec §7.6): SAN
/// heading, Why, Plan, Watch out (amber), Alternatives (collapsed). Scrolls
/// internally; [maxHeight] caps it on phones (35 % of the screen). Fades
/// (150 ms) when the move changes.
class CommentPanel extends StatelessWidget {
  /// Creates the panel for [node] (null: nothing selected yet).
  const new({required this.node, super.key, this.maxHeight, this.placeholder});

  /// The move whose comment is shown.
  final TreeNode? node;

  /// Height cap, or null for the available height.
  final double? maxHeight;

  /// Shown when [node] is null (for example "Your move").
  final String? placeholder;

  /// The fade duration.
  static const fade = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final content = AnimatedSwitcher(
      duration: fade,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topLeft,
        children: [...previous, ?current],
      ),
      child: _Content(
        key: ValueKey(node?.id),
        node: node,
        placeholder: placeholder,
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
      child: content,
    );
  }
}

class _Content extends StatelessWidget {
  const new({required this.node, required this.placeholder, super.key});

  final TreeNode? node;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final node = this.node;
    if (node == null || node.san == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(placeholder ?? '', key: const Key('comment-placeholder')),
      );
    }
    final comment = node.comment;
    final heading = formatSanMoves([node.san!], firstPly: node.ply);
    final hasText =
        comment != null &&
        [
          comment.why,
          comment.plan,
          comment.watch,
          comment.alt,
        ].any((t) => t != null && t.isNotEmpty);
    return SingleChildScrollView(
      key: const Key('comment-panel'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            heading,
            key: const Key('comment-heading'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          if (!hasText)
            Text(l10n.noComment, key: const Key('no-comment'), style: muted)
          else ...[
            if (comment.why case final why? when why.isNotEmpty)
              _Section(label: l10n.commentWhy, text: why),
            if (comment.plan case final plan? when plan.isNotEmpty)
              _Section(label: l10n.commentPlan, text: plan),
            if (comment.watch case final watch? when watch.isNotEmpty)
              _Section(
                label: l10n.commentWatch,
                text: watch,
                accent: AppColors.text(context).warning,
              ),
            if (comment.alt case final alt? when alt.isNotEmpty)
              _Alternatives(text: alt),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({required this.label, required this.text, this.accent});

  final String label;
  final String text;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label  ',
            style: TextStyle(fontWeight: FontWeight.w700, color: accent),
          ),
          TextSpan(text: text),
        ],
      ),
      style: theme.textTheme.bodyMedium,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: accent == null
          ? body
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: accent!, width: 3)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: body,
              ),
            ),
    );
  }
}

class _Alternatives extends StatefulWidget {
  const new({required this.text});

  final String text;

  @override
  State<_Alternatives> createState() => _AlternativesState();
}

class _AlternativesState extends State<_Alternatives> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          key: const Key('toggle-alternatives'),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => setState(() => _open = !_open),
          child: Text(_open ? l10n.hideAlternatives : l10n.showAlternatives),
        ),
        if (_open) _Section(label: l10n.commentAlternatives, text: widget.text),
      ],
    );
  }
}
