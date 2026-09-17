import 'package:connectivity_plus/connectivity_plus.dart';

/// True when the device has *a* network interface.
///
/// This is a hint, not a guarantee: a captive portal or a dead backend still
/// looks connected. The engine therefore treats a failed request as its real
/// signal and uses this only to avoid trying when there is obviously no point.
///
/// Emits the current connectivity state immediately on subscription, then
/// every subsequent change. `Connectivity().onConnectivityChanged` on its own
/// only fires on a *change*, so a listener that only used that stream would
/// have no idea whether it started online or offline until the next flip —
/// connectivity must be observed, never assumed.
Stream<bool> connectivityStream() async* {
  final List<ConnectivityResult> initial = await Connectivity().checkConnectivity();
  yield initial.any((ConnectivityResult r) => r != ConnectivityResult.none);
  yield* Connectivity()
      .onConnectivityChanged
      .map((List<ConnectivityResult> results) =>
          results.any((ConnectivityResult r) => r != ConnectivityResult.none));
}
