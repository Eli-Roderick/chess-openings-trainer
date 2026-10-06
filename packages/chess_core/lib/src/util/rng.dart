import 'dart:math';

/// Source of randomness. Logic takes an [Rng] instead of creating `Random`,
/// so tests and benchmarks are deterministic.
abstract interface class Rng {
  /// A double in [0, 1).
  double nextDouble();

  /// An int in [0, max).
  int nextInt(int max);
}

/// A deterministic [Rng] for a given seed.
final class SeededRng implements Rng {
  /// Creates a generator seeded with [seed].
  new(int seed) : _random = Random(seed);

  final Random _random;

  @override
  double nextDouble() => _random.nextDouble();

  @override
  int nextInt(int max) => _random.nextInt(max);
}

/// The app's [Rng]: unseeded, different on every start.
final class SystemRng implements Rng {
  /// Creates an unseeded generator.
  new() : _random = Random();

  final Random _random;

  @override
  double nextDouble() => _random.nextDouble();

  @override
  int nextInt(int max) => _random.nextInt(max);
}
