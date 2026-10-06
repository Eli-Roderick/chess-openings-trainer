import 'package:go_router/go_router.dart';
import 'package:repertoire_trainer/features/home/home_screen.dart';

/// Route paths. Later phases add routes here.
abstract final class Routes {
  static const home = '/';
}

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
  ],
);
