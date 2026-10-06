/// Source of the current time. Logic takes a [Clock] instead of calling
/// `DateTime.now()`, so tests are deterministic.
abstract interface class Clock {
  /// The current instant.
  DateTime now();
}

/// The real wall clock.
final class SystemClock implements Clock {
  /// Creates the system clock.
  const new();

  @override
  DateTime now() => DateTime.now();
}

/// A clock for tests that only moves when told to.
final class FakeClock implements Clock {
  /// Starts at [current].
  new(this.current);

  /// The instant the clock shows; assign to jump.
  DateTime current;

  @override
  DateTime now() => current;

  /// Moves the clock forward by [d].
  void advance(Duration d) => current = current.add(d);
}
