import 'package:chess_core/chess_core.dart' show RunMode;
import 'package:flutter/widgets.dart' show ValueKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';
import 'package:repertoire_trainer/features/backup/sync_backup_screen.dart';
import 'package:repertoire_trainer/features/board/free_move.dart';
import 'package:repertoire_trainer/features/browse/browse_screen.dart';
import 'package:repertoire_trainer/features/drill/drill_screen.dart';
import 'package:repertoire_trainer/features/games/games_screen.dart';
import 'package:repertoire_trainer/features/home/home_screen.dart';
import 'package:repertoire_trainer/features/import/create_screen.dart';
import 'package:repertoire_trainer/features/import/reimport_screen.dart';
import 'package:repertoire_trainer/features/import/validate_stored_screen.dart';
import 'package:repertoire_trainer/features/play/play_on_screen.dart';
import 'package:repertoire_trainer/features/repertoire/detail_screen.dart';
import 'package:repertoire_trainer/features/settings/diagnostics_screen.dart';
import 'package:repertoire_trainer/features/settings/settings_screen.dart';
import 'package:repertoire_trainer/features/stats/line_detail_screen.dart';
import 'package:repertoire_trainer/features/stats/stats_screen.dart';

/// Every route of docs/plan/01-product-spec.md §2 (see `routes.dart`).
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'repertoire/new',
            builder: (context, state) => CreateRepertoireScreen(
              initialFile: switch (state.extra) {
                final PickedFile file => file,
                _ => null,
              },
            ),
          ),
          GoRoute(
            path: 'repertoire/:id',
            builder: (context, state) =>
                RepertoireDetailScreen(id: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'train',
                builder: (context, state) {
                  final q = state.uri.queryParameters;
                  return DrillScreen(
                    // Same path, other mode or line: a new drill, not an
                    // update of the running one.
                    key: ValueKey(state.uri.toString()),
                    id: state.pathParameters['id']!,
                    mode: RunMode.values
                        .where((m) => m.name == q['mode'])
                        .firstOrNull,
                    lineKey: q['line'],
                    fromBranch: switch (q['from']) {
                      'branch' => true,
                      'move1' => false,
                      _ => null,
                    },
                    deviations: switch (q['dev']) {
                      'on' => true,
                      'off' => false,
                      _ => null,
                    },
                  );
                },
              ),
              GoRoute(
                path: 'browse',
                builder: (context, state) => BrowseScreen(
                  id: state.pathParameters['id']!,
                  initialNode: int.tryParse(
                    state.uri.queryParameters['node'] ?? '',
                  ),
                  initialFree: switch (state.extra) {
                    final List<FreeMove> moves => moves,
                    _ => const [],
                  },
                  analysis: state.uri.queryParameters['analyse'] == '1',
                ),
              ),
              GoRoute(
                path: 'stats',
                builder: (context, state) =>
                    StatsScreen(id: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'lines',
                    builder: (context, state) =>
                        LineListScreen(id: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'line/:lineKey',
                    builder: (context, state) => LineDetailScreen(
                      id: state.pathParameters['id']!,
                      lineKey: state.pathParameters['lineKey']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'reimport',
                builder: (context, state) => ReimportScreen(
                  id: state.pathParameters['id']!,
                  initialFile: switch (state.extra) {
                    final PickedFile file => file,
                    _ => null,
                  },
                ),
              ),
              GoRoute(
                path: 'validate',
                builder: (context, state) =>
                    ValidateStoredScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: ':section',
                builder: (context, state) => switch (SettingsSection.values
                    .byName(state.pathParameters['section']!)) {
                  // Lives in its own feature (backup, then sync in P12).
                  SettingsSection.sync => const SyncBackupScreen(),
                  final section => SettingsSectionScreen(section: section),
                },
              ),
            ],
          ),
          GoRoute(
            path: 'play-engine',
            builder: (context, state) => switch (state.extra) {
              final PlayOnArgs args => PlayOnScreen(args: args),
              // Opened without a position (a restored deep link).
              _ => const HomeScreen(),
            },
          ),
          GoRoute(
            path: 'games',
            builder: (context, state) => const GamesScreen(),
          ),
          GoRoute(
            path: 'diagnostics',
            builder: (context, state) => const DiagnosticsScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
