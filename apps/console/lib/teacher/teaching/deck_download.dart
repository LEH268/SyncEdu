/// Hands finished bytes to the browser as a file the teacher saves.
///
/// The console is a web build, but its widget tests run on the VM, so the
/// browser-only implementation is reached through a conditional export rather
/// than imported directly -- the same shape `syncedu_local` uses for its
/// testing connection.
library;

export 'deck_download_stub.dart'
    if (dart.library.js_interop) 'deck_download_web.dart';
