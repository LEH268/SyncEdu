import 'dart:math';

class WeaknessObservation {
  const WeaknessObservation({required this.isCorrect, required this.at});

  final bool isCorrect;
  final DateTime at;
}

/// An exponentially-decayed error rate for one micro-skill.
///
/// Must stay identical to `public.recompute_weaknesses` in migration
/// `0013_activity.sql`:
/// the client computes it so a student's own view updates instantly offline,
/// and the server recomputes it authoritatively on sync. Because both read the
/// same rows and apply the same arithmetic they agree, which is what removes
/// any need to reconcile them.
double weaknessWeight({
  required List<WeaknessObservation> observations,
  required DateTime now,
  double halfLifeDays = 14,
}) {
  if (observations.isEmpty) return 0;

  double weighted = 0;
  double total = 0;

  for (final WeaknessObservation observation in observations) {
    final double days =
        now.difference(observation.at).inSeconds / Duration.secondsPerDay;
    final double decay = pow(0.5, days / halfLifeDays).toDouble();
    total += decay;
    if (!observation.isCorrect) weighted += decay;
  }

  if (total == 0) return 0;
  return (weighted / total).clamp(0.0, 1.0);
}
