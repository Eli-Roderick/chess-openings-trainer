import 'dart:io' as io;

import 'package:chess_core/chess_core.dart';

/// chess_core's [GzipCodec] on `dart:io` (chess_core itself stays free of
/// `dart:io`).
final class IoGzip implements GzipCodec {
  /// Creates it.
  const new();

  @override
  List<int> encode(List<int> bytes) => io.gzip.encode(bytes);

  @override
  List<int> decode(List<int> bytes) => io.gzip.decode(bytes);
}

/// The sync / backup codec used by the app.
const syncCodec = SyncCodec(IoGzip());
