import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A line-based connection to a UCI engine.
abstract interface class UciTransport {
  /// Lines the engine writes (without line endings). Single subscription;
  /// closes when the engine exits.
  Stream<String> get lines;

  /// Writes [command] and a newline.
  void send(String command);

  /// Completes with the exit code when the engine process ends.
  Future<int> get exitCode;

  /// Terminates the engine.
  Future<void> kill();
}

/// A Stockfish process started with `dart:io` `Process.start`.
final class ProcessTransport implements UciTransport {
  new _(this._process, this._lines, this._onStderr);

  /// Starts [executable]. Lines on stderr go to [onStderr].
  static Future<ProcessTransport> start(
    String executable, {
    void Function(String line)? onStderr,
  }) async {
    final process = await Process.start(executable, const []);
    final lines = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    final transport = ProcessTransport._(process, lines, onStderr);
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((l) => transport._onStderr?.call(l));
    return transport;
  }

  final Process _process;
  final Stream<String> _lines;
  final void Function(String)? _onStderr;
  bool _closed = false;

  @override
  Stream<String> get lines => _lines;

  @override
  Future<int> get exitCode => _process.exitCode;

  @override
  void send(String command) {
    if (_closed) return;
    try {
      _process.stdin.writeln(command);
    } on Object {
      // Broken pipe: the exit code reports the crash.
      _closed = true;
    }
  }

  @override
  Future<void> kill() async {
    _closed = true;
    _process.kill();
    await _process.exitCode;
  }
}

/// A scripted engine for tests: `onCommand` receives every command and may
/// answer with [emit].
final class FakeTransport implements UciTransport {
  /// Creates the fake.
  new({this._onCommand});

  final void Function(FakeTransport, String)? _onCommand;
  final _out = StreamController<String>();
  final _exit = Completer<int>();

  /// Every command received, in order.
  final List<String> commands = [];

  /// Whether the engine has exited.
  bool get exited => _exit.isCompleted;

  @override
  Stream<String> get lines => _out.stream;

  @override
  Future<int> get exitCode => _exit.future;

  @override
  void send(String command) {
    if (exited) return;
    commands.add(command);
    _onCommand?.call(this, command);
  }

  /// Writes [line] as the engine.
  void emit(String line) {
    if (!exited) _out.add(line);
  }

  /// Simulates the process ending with [code] (a crash when non-zero).
  void exit([int code = 0]) {
    if (exited) return;
    _exit.complete(code);
    unawaited(_out.close());
  }

  @override
  Future<void> kill() async => exit(-9);
}
