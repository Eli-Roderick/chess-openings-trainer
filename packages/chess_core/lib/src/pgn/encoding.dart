import 'dart:convert';

/// Largest accepted PGN file (E-SIZE above this).
const int maxPgnBytes = 10 * 1024 * 1024;

/// Decodes PGN file bytes: UTF-8 (BOM stripped), falling back to Latin-1
/// when the bytes are not valid UTF-8; line endings normalized to `\n`.
String decodePgnBytes(List<int> bytes) {
  var start = 0;
  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    start = 3;
  }
  final body = start == 0 ? bytes : bytes.sublist(start);
  String text;
  try {
    text = utf8.decode(body);
  } on FormatException {
    text = latin1.decode(body);
  }
  return normalizePgnText(text);
}

/// Strips a leading BOM and normalizes CRLF / CR to `\n`.
String normalizePgnText(String text) {
  final noBom = text.startsWith('﻿') ? text.substring(1) : text;
  return noBom.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
}

/// True if [text] encodes to more than [maxPgnBytes] UTF-8 bytes.
bool exceedsPgnSize(String text) {
  if (text.length > maxPgnBytes) return true;
  if (text.length * 3 <= maxPgnBytes) return false;
  return utf8.encode(text).length > maxPgnBytes;
}
