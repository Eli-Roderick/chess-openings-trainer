import 'package:flutter/material.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/theme/app_theme.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

class RepertoireTrainerApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
