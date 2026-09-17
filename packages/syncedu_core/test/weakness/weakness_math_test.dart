import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

final DateTime now = DateTime.utc(2026, 9, 5, 12);

WeaknessObservation obs(bool correct, {int daysAgo = 0}) =>
    WeaknessObservation(
      isCorrect: correct,
      at: now.subtract(Duration(days: daysAgo)),
    );

void main() {
  test('all wrong gives a weight of 1', () {
    expect(
      weaknessWeight(
        observations: <WeaknessObservation>[obs(false), obs(false)],
        now: now,
      ),
      closeTo(1.0, 0.001),
    );
  });

  test('all correct gives a weight of 0', () {
    expect(
      weaknessWeight(
        observations: <WeaknessObservation>[obs(true), obs(true)],
        now: now,
      ),
      closeTo(0.0, 0.001),
    );
  });

  test('half wrong gives roughly a half', () {
    expect(
      weaknessWeight(
        observations: <WeaknessObservation>[obs(false), obs(true)],
        now: now,
      ),
      closeTo(0.5, 0.001),
    );
  });

  test('an old mistake counts less than a recent one', () {
    final old = weaknessWeight(
      observations: <WeaknessObservation>[obs(false, daysAgo: 28), obs(true)],
      now: now,
    );
    final recent = weaknessWeight(
      observations: <WeaknessObservation>[obs(false), obs(true, daysAgo: 28)],
      now: now,
    );

    // Otherwise a student who fixed a gap a month ago is still fed questions
    // about it forever.
    expect(old, lessThan(recent));
  });

  test('a mistake one half-life old carries half the influence', () {
    final weight = weaknessWeight(
      observations: <WeaknessObservation>[obs(false, daysAgo: 14), obs(true)],
      now: now,
    );
    // decayed wrong = 0.5, fresh right = 1.0 -> 0.5 / 1.5
    expect(weight, closeTo(1 / 3, 0.01));
  });

  test('no observations gives zero, not an error', () {
    // A brand-new student must produce ordinary unbiased content.
    expect(
      weaknessWeight(observations: const <WeaknessObservation>[], now: now),
      0.0,
    );
  });

  test('the result is always within [0, 1]', () {
    for (final int wrong in <int>[0, 1, 5, 50]) {
      for (final int right in <int>[0, 1, 5, 50]) {
        final weight = weaknessWeight(
          observations: <WeaknessObservation>[
            for (int i = 0; i < wrong; i++) obs(false, daysAgo: i),
            for (int i = 0; i < right; i++) obs(true, daysAgo: i),
          ],
          now: now,
        );
        expect(weight, inInclusiveRange(0.0, 1.0));
      }
    }
  });
}
