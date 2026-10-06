import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/engine/engine_providers.dart';

/// Pauses the engine when the app goes to the background (stops searches,
/// quits the process after 60 s) and resumes it in the foreground
/// (docs/plan/05-engine.md §4 Lifecycle).
class EngineLifecycle extends ConsumerStatefulWidget {
  /// Wraps [child].
  const new({required this.child, super.key});

  /// The app content.
  final Widget child;

  @override
  ConsumerState<EngineLifecycle> createState() => _EngineLifecycleState();
}

class _EngineLifecycleState extends ConsumerState<EngineLifecycle> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onPause: () => ref.read(engineServiceProvider).pause(),
      onHide: () => ref.read(engineServiceProvider).pause(),
      onResume: () => ref.read(engineServiceProvider).resume(),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
