import 'package:flutter/material.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Stand-in for screens built in later phases.
class PlaceholderScreen extends StatelessWidget {
  /// Creates a placeholder titled [title].
  const new({required this.title, super.key});

  /// App bar title.
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.placeholderTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(l10n.placeholderBody, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
