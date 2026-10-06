import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/layout/adaptive_layout.dart';
import 'package:repertoire_trainer/app/routes.dart';
import 'package:repertoire_trainer/app/version.dart';
import 'package:repertoire_trainer/core/db/providers.dart';
import 'package:repertoire_trainer/core/settings/app_settings.dart';
import 'package:repertoire_trainer/features/settings/board_settings_page.dart';
import 'package:repertoire_trainer/l10n/gen/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings sections (01-product-spec §10).
enum SettingsSection {
  /// Training settings (P07+).
  training(Icons.school_outlined),

  /// Board and sound (P05).
  board(Icons.grid_on_outlined),

  /// Engine (P06).
  engine(Icons.memory_outlined),

  /// Theme.
  appearance(Icons.palette_outlined),

  /// Sync and backup (P11-P12).
  sync(Icons.cloud_sync_outlined),

  /// Version, licences, Diagnostics.
  about(Icons.info_outline);

  new(this.icon);

  /// Leading icon.
  final IconData icon;

  /// Localized title.
  String title(AppLocalizations l10n) => switch (this) {
    training => l10n.settingsTraining,
    board => l10n.settingsBoard,
    engine => l10n.settingsEngine,
    appearance => l10n.settingsAppearance,
    sync => l10n.settingsSync,
    about => l10n.settingsAbout,
  };
}

/// Settings: one entry per section.
class SettingsScreen extends StatelessWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: AdaptiveLayout(
        phone: ListView(
          children: [
            for (final s in SettingsSection.values)
              ListTile(
                key: Key('section-${s.name}'),
                leading: Icon(s.icon),
                title: Text(s.title(l10n)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.settingsSection(s.name)),
              ),
          ],
        ),
      ),
    );
  }
}

/// One settings section. Only Appearance and About work in P04.
class SettingsSectionScreen extends StatelessWidget {
  /// Shows [section].
  const new({required this.section, super.key});

  /// The section.
  final SettingsSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(section.title(l10n))),
      body: AdaptiveLayout(
        phone: switch (section) {
          SettingsSection.appearance => const _Appearance(),
          SettingsSection.board => const BoardSettingsPage(),
          SettingsSection.about => const _About(),
          _ => Padding(
            padding: const EdgeInsets.all(AdaptiveLayout.gutter),
            child: Text(l10n.settingsLater),
          ),
        },
      ),
    );
  }
}

class _Appearance extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode =
        (ref.watch(settingsProvider).value ?? const AppSettings()).themeMode;
    return RadioGroup<AppThemeMode>(
      groupValue: mode,
      onChanged: (m) {
        if (m == null) return;
        unawaited(
          ref
              .read(settingsRepositoryProvider)
              .update((s) => s.copyWith(themeMode: m)),
        );
      },
      child: ListView(
        children: [
          ListTile(title: Text(l10n.themeLabel)),
          for (final (m, label) in [
            (AppThemeMode.dark, l10n.themeDark),
            (AppThemeMode.light, l10n.themeLight),
            (AppThemeMode.system, l10n.themeSystem),
          ])
            RadioListTile<AppThemeMode>(
              key: Key('theme-${m.name}'),
              value: m,
              title: Text(label),
            ),
        ],
      ),
    );
  }
}

class _About extends StatefulWidget {
  const new();

  @override
  State<_About> createState() => _AboutState();
}

class _AboutState extends State<_About> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        ListTile(
          key: const Key('about-version'),
          title: Text(l10n.appTitle),
          subtitle: Text(l10n.aboutVersion(appVersion, appBuildNumber)),
          onTap: () {
            // Seven taps open the hidden Diagnostics screen (10 §6).
            if (++_taps >= 7) {
              _taps = 0;
              unawaited(context.push(Routes.diagnostics));
            }
          },
        ),
        ListTile(title: Text(l10n.aboutLicense)),
        ListTile(title: Text(l10n.aboutStockfish(stockfishTag))),
        ListTile(
          leading: const Icon(Icons.gavel_outlined),
          title: Text(l10n.aboutLicenses),
          onTap: () => showLicensePage(
            context: context,
            applicationName: l10n.appTitle,
            applicationVersion: '$appVersion ($appBuildNumber)',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: Text(l10n.aboutSource),
          subtitle: const Text(sourceRepositoryUrl),
          onTap: () => launchUrl(Uri.parse(sourceRepositoryUrl)),
        ),
        ListTile(
          leading: const Icon(Icons.memory_outlined),
          title: Text(l10n.aboutStockfishSource),
          subtitle: const Text(stockfishSourceUrl),
          onTap: () => launchUrl(Uri.parse(stockfishSourceUrl)),
        ),
      ],
    );
  }
}
