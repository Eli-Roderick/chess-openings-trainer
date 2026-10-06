import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repertoire_trainer/core/files/file_service.dart';

/// Open/save dialogs; tests override with a fake.
final fileServiceProvider = Provider<FileService>(
  (ref) => const PlatformFileService(),
);

/// Path of the bundled demo repertoire (01-product-spec §4).
const demoPgnAsset = 'assets/demo/italian_white.pgn';

/// Loads the demo PGN text; tests may override.
final demoPgnProvider = FutureProvider<String>(
  (ref) => rootBundle.loadString(demoPgnAsset),
);
