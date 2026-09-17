import 'dart:math';

/// Physics is integrated at a fixed substep so behaviour does not change with
/// frame rate -- a 60 Hz phone and a 120 Hz one must look the same.
const double kFixedSubstep = 1 / 120;

/// One critically-damped harmonic oscillator.
///
/// The equation is textbook damped-harmonic motion, not adapted artwork:
///   v += (-2*zeta*omega*v - omega^2*(x - target)) * dt
///   x += v * dt
class Spring {
  Spring({
    required double value,
    this.stiffness = 14.0,
    this.damping = 1.0,
  })  : value = value,
        target = value;

  /// Angular frequency. Higher is snappier.
  final double stiffness;

  /// Damping ratio. 1.0 is critical -- converges fastest without overshoot.
  final double damping;

  double value;
  double velocity = 0.0;
  double target;

  bool get isSettled =>
      (value - target).abs() < 0.001 && velocity.abs() < 0.001;

  /// Adds velocity without moving position. State transitions use this to
  /// give the character a kick rather than tweening it, which is what makes
  /// the motion read as alive.
  void impulse(double amount) {
    velocity += amount;
  }

  void step(double dt) {
    if (!dt.isFinite || dt <= 0) return;

    // A dropped frame or a backgrounded app hands us a large dt; integrating
    // it in one go diverges, so subdivide. Capped so catching up after a long
    // pause cannot stall the frame.
    final int steps = min((dt / kFixedSubstep).ceil(), 32);
    final double h = dt / steps;

    for (int i = 0; i < steps; i++) {
      velocity += (-2 * damping * stiffness * velocity -
              stiffness * stiffness * (value - target)) *
          h;
      value += velocity * h;

      if (!value.isFinite || !velocity.isFinite) {
        value = target;
        velocity = 0.0;
        return;
      }
    }
  }
}
