import 'package:flutter/material.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// Placeholder Home. The real screen arrives in P04.
class HomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(child: Text(l10n.homePlaceholder)),
    );
  }
}
