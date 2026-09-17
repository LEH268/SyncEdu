import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Saves [bytes] to the teacher's machine as [filename].
///
/// An object URL rather than a data: URI: a deck runs to hundreds of
/// kilobytes, and base64 in an href hits browser URL length limits.
Future<void> downloadBytes(
  Uint8List bytes,
  String filename,
  String mimeType,
) async {
  final web.Blob blob = web.Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final String url = web.URL.createObjectURL(blob);
  final web.HTMLAnchorElement anchor =
      web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  // The click has already handed the blob to the download manager, so the
  // handle can go immediately; holding it would leak the buffer for the life
  // of the tab.
  web.URL.revokeObjectURL(url);
}
