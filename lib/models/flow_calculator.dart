import 'dart:math';

/// Holds the calculation results for a pipe flow calculation.
class FlowResults {
  final double flowSpeed;      // m/s — velocity of water in the pipe
  final double pressureLoss;   // meters of head — energy lost
  final double area;           // m² — cross-sectional area of pipe
  final double re;             // Reynolds number (used for flow type classification)
  final FlowStatus flowStatus;

  const FlowResults({
    required this.flowSpeed,
    required this.pressureLoss,
    required this.area,
    required this.re,
    required this.flowStatus,
  });
}

/// Status of flow based on velocity thresholds.
enum FlowStatus { low, normal, high }

/// All the pipe input values the user enters.
class PipeInputs {
  final String pipeLength;
  final String pipeDiameter;
  final String flowRate;
  final String roughness; // optional

  const PipeInputs({
    required this.pipeLength,
    required this.pipeDiameter,
    required this.flowRate,
    required this.roughness,
  });

  PipeInputs copyWith({
    String? pipeLength,
    String? pipeDiameter,
    String? flowRate,
    String? roughness,
  }) {
    return PipeInputs(
      pipeLength: pipeLength ?? this.pipeLength,
      pipeDiameter: pipeDiameter ?? this.pipeDiameter,
      flowRate: flowRate ?? this.flowRate,
      roughness: roughness ?? this.roughness,
    );
  }
}

/// --------------------------------------------------
/// Core calculation logic — separated from UI
/// --------------------------------------------------
class FlowCalculator {
  static const double _g = 9.81;   // gravitational acceleration m/s²
  static const double _nu = 1e-6;  // kinematic viscosity of water m²/s

  /// Calculates velocity and pressure loss using Darcy-Weisbach.
  ///
  /// [L] = pipe length in meters
  /// [D] = pipe diameter in meters
  /// [Q] = flow rate in m³/s
  ///
  /// Returns [FlowResults] or throws [ArgumentError] on bad inputs.
  static FlowResults calculate({
    required double L,
    required double D,
    required double Q,
    double? roughnessMm, // optional roughness in mm
  }) {
    if (L <= 0 || D <= 0 || Q <= 0) {
      throw ArgumentError('All inputs must be positive numbers.');
    }

    // Cross-sectional area: A = π * (D/2)²
    final double area = pi * pow(D / 2, 2);

    // Flow velocity: V = Q / A
    final double velocity = Q / area;

    // Reynolds number: Re = V * D / ν
    final double re = velocity * D / _nu;

    // Calculate friction factor
    final double f;
    if (re < 1e-8) {
      f = 0.0;
    } else if (re <= 2000) {
      f = 64.0 / re;
    } else {
      final double eps = (roughnessMm ?? 0.0) / 1000.0; // convert mm to meters
      final double epsOverD = eps / D;
      final double argRaw = (epsOverD / 3.7) + (5.74 / pow(re, 0.9));
      final double arg = max(argRaw, 1e-10);
      f = max(0.25 / pow(log(arg) / ln10, 2), 0.008);
    }

    // Pressure loss (head loss) using Darcy-Weisbach:
    // ΔH = f * (L/D) * (V² / (2*g))
    final double pressureLoss = f * (L / D) * (pow(velocity, 2) / (2 * _g));

    // Determine flow status based on velocity thresholds
    final FlowStatus status;
    if (velocity < 0.5) {
      status = FlowStatus.low;
    } else if (velocity <= 3.0) {
      status = FlowStatus.normal;
    } else {
      status = FlowStatus.high;
    }

    return FlowResults(
      flowSpeed: velocity,
      pressureLoss: pressureLoss,
      area: area,
      re: re,
      flowStatus: status,
    );
  }
}
