import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

void main() {
  test('a spring at its target does not move', () {
    final spring = Spring(value: 1.0)..target = 1.0;
    for (int i = 0; i < 100; i++) {
      spring.step(kFixedSubstep);
    }
    expect(spring.value, closeTo(1.0, 0.0001));
    expect(spring.velocity, closeTo(0.0, 0.0001));
  });

  test('a spring converges on a moved target', () {
    final spring = Spring(value: 0.0)..target = 1.0;
    for (int i = 0; i < 600; i++) {
      spring.step(kFixedSubstep);
    }
    expect(spring.value, closeTo(1.0, 0.01));
  });

  test('convergence is monotone at critical damping -- no oscillation', () {
    final spring = Spring(value: 0.0)..target = 1.0;
    double previous = 0.0;
    for (int i = 0; i < 600; i++) {
      spring.step(kFixedSubstep);
      expect(spring.value, greaterThanOrEqualTo(previous - 1e-9));
      expect(spring.value, lessThanOrEqualTo(1.0 + 1e-6));
      previous = spring.value;
    }
  });

  test('an underdamped spring does overshoot', () {
    final spring = Spring(value: 0.0, damping: 0.35)..target = 1.0;
    double peak = 0.0;
    for (int i = 0; i < 600; i++) {
      spring.step(kFixedSubstep);
      peak = peak > spring.value ? peak : spring.value;
    }
    expect(peak, greaterThan(1.0));
  });

  test('an impulse moves velocity, not position', () {
    final spring = Spring(value: 0.5)..target = 0.5;
    spring.impulse(2.0);
    expect(spring.value, 0.5);
    expect(spring.velocity, 2.0);
  });

  test('a non-finite state snaps to target instead of propagating NaN', () {
    final spring = Spring(value: 0.0)..target = 1.0;
    spring.impulse(double.infinity);
    spring.step(kFixedSubstep);
    expect(spring.value.isFinite, isTrue);
    expect(spring.value, 1.0);
    expect(spring.velocity, 0.0);
  });

  test('a very large dt is subdivided rather than exploding', () {
    final spring = Spring(value: 0.0)..target = 1.0;
    spring.step(0.5);
    expect(spring.value.isFinite, isTrue);
    expect(spring.value, inInclusiveRange(0.0, 1.05));
  });

  test('isSettled becomes true once motion stops', () {
    final spring = Spring(value: 0.0)..target = 1.0;
    expect(spring.isSettled, isFalse);
    for (int i = 0; i < 1000; i++) {
      spring.step(kFixedSubstep);
    }
    expect(spring.isSettled, isTrue);
  });

  test('stepping is deterministic for identical inputs', () {
    List<double> run() {
      final spring = Spring(value: 0.0)..target = 1.0;
      return <double>[
        for (int i = 0; i < 50; i++) ...<double>[
          (spring..step(kFixedSubstep)).value,
        ],
      ];
    }

    expect(run(), run());
  });
}
