import 'dart:typed_data';

/// Off the web there is no browser to hand a download to. Reaching this is a
/// composition mistake rather than a runtime condition to recover from, so it
/// throws instead of failing silently.
Future<void> downloadBytes(
  Uint8List bytes,
  String filename,
  String mimeType,
) async {
  throw UnsupportedError(
    'downloadBytes is only implemented for the web build of the console',
  );
}
