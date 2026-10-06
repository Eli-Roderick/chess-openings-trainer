import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/app/router.dart';
import 'package:repertoire_trainer/app/theme/app_theme.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/engine/engine_lifecycle.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/core/sync/sync_lifecycle.dart';
import 'package:repertoire_trainer/features/board/board_appearance.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';

/// SnackBars shown outside a screen (sync results).
final appMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// The app: router, themes and localizations. The theme follows the
/// Appearance setting (dark by default, D-25).
class RepertoireTrainerApp extends ConsumerWidget {
  /// Creates the app.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      settingsProvider.select(
        (s) => (s.value ?? const AppSettings()).themeMode,
      ),
    );
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (mode) {
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.system => ThemeMode.system,
      },
      routerConfig: ref.watch(routerProvider),
      scaffoldMessengerKey: appMessengerKey,
      builder: (context, child) => EngineLifecycle(
        child: SyncLifecycle(
          messenger: appMessengerKey,
          child: PieceSetPrecacher(child: child ?? const SizedBox.shrink()),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
