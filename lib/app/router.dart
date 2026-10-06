import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/app/placeholder_screen.dart';
import 'package:repertoire_trainer/features/browse/browse_screen.dart';
import 'package:repertoire_trainer/features/home/home_screen.dart';
import 'package:repertoire_trainer/features/import/create_screen.dart';
import 'package:repertoire_trainer/features/import/reimport_screen.dart';
import 'package:repertoire_trainer/features/import/validate_stored_screen.dart';
import 'package:repertoire_trainer/features/repertoire/detail_screen.dart';
import 'package:repertoire_trainer/features/settings/diagnostics_screen.dart';
import 'package:repertoire_trainer/features/settings/settings_screen.dart';

/// Every route of docs/plan/01-product-spec.md §2 (see `routes.dart`);
/// screens of later phases are placeholders.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'repertoire/new',
            builder: (context, state) => const CreateRepertoireScreen(),
          ),
          GoRoute(
            path: 'repertoire/:id',
            builder: (context, state) =>
                RepertoireDetailScreen(id: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'train',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Train'),
              ),
              GoRoute(
                path: 'browse',
                builder: (context, state) => BrowseScreen(
                  id: state.pathParameters['id']!,
                  initialNode: int.tryParse(
                    state.uri.queryParameters['node'] ?? '',
                  ),
                ),
              ),
              GoRoute(
                path: 'stats',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Stats'),
                routes: [
                  GoRoute(
                    path: 'line/:lineKey',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Line'),
                  ),
                ],
              ),
              GoRoute(
                path: 'reimport',
                builder: (context, state) =>
                    ReimportScreen(id: state.pathParameters['id']!),
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
                builder: (context, state) => SettingsSectionScreen(
                  section: SettingsSection.values.byName(
                    state.pathParameters['section']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'play-engine',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Play on'),
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
