import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_flow_calculator/models/flow_calculator.dart';

void main() {
  group('FlowCalculator Physics & Logic Tests', () {
    test('1. Invalid inputs should throw ArgumentError (Safety)', () {
      expect(() => FlowCalculator.calculate(L: 0, D: 0.1, Q: 0.05), throwsArgumentError);
      expect(() => FlowCalculator.calculate(L: 10, D: -0.1, Q: 0.05), throwsArgumentError);
      expect(() => FlowCalculator.calculate(L: 10, D: 0.1, Q: 0), throwsArgumentError);
    });

    test('2. Extremely low flow rate avoiding division by zero (Re < 1e-8)', () {
      // Re = V * D / nu. To get Re < 1e-8 with D = 1 and nu = 1e-6, V must be < 1e-14.
      // Area = pi * (0.5)^2 ~ 0.785. Q = V * Area = 1e-15 is plenty small.
      final results = FlowCalculator.calculate(
        L: 100,
        D: 1.0,
        Q: 1e-15,
      );
      // The friction factor should be clamped to 0.0 early on, returning 0 pressure loss.
      expect(results.pressureLoss, 0.0);
      expect(results.flowSpeed, greaterThan(0)); // Speed is > 0
      expect(results.re, lessThan(1e-8));
      expect(results.flowStatus, FlowStatus.low);
    });

    test('3. Laminar flow formula validation (Re <= 2000)', () {
      // Re = 1000. Re = V * 0.1 / 1e-6 => V = 0.01.
      // Area = pi * (0.05)^2 = 0.00785... | Q = V * Area = 0.0000785398
      final results = FlowCalculator.calculate(
        L: 10,
        D: 0.1,
        Q: 0.0000785398,
      );
      expect(results.re <= 2000, isTrue);
      expect(results.re, greaterThan(1e-8));

      // Calculate the expected manual logic for Laminar: f = 64 / Re
      final expectedF = 64.0 / results.re;
      final expectedLoss = expectedF * (10 / 0.1) * (pow(results.flowSpeed, 2) / (2 * 9.81));
      
      expect(results.pressureLoss, closeTo(expectedLoss, 1e-10));
    });

    test('4. Turbulent flow validation (Smooth pipe / NO roughness)', () {
      // Q = ~0.00785 (about 1 m/s velocity in a 0.1 D pipe). Re ~ 100,000.
      final results = FlowCalculator.calculate(
        L: 50,
        D: 0.1,
        Q: 0.00785398,
      );
      expect(results.re > 2000, isTrue);

      // eps = 0.0
      final argRaw = 5.74 / pow(results.re, 0.9);
      final arg = max(argRaw, 1e-10);
      final expectedF = max(0.25 / pow(log(arg) / ln10, 2), 0.008);
      
      final expectedLoss = expectedF * (50 / 0.1) * (pow(results.flowSpeed, 2) / (2 * 9.81));
      expect(results.pressureLoss, closeTo(expectedLoss, 1e-10));
    });

    test('5. Turbulent flow validation WITH specific Roughness', () {
      // D = 0.1, Q = 0.05 (turbulent), roughness = 0.2 mm
      final results = FlowCalculator.calculate(
        L: 50,
        D: 0.1,
        Q: 0.05,
        roughnessMm: 0.2, // 0.2 mm
      );
      expect(results.re > 2000, isTrue);

      // Calculate manual expectation
      final epsOverD = (0.2 / 1000.0) / 0.1;
      final argRaw = (epsOverD / 3.7) + (5.74 / pow(results.re, 0.9));
      final arg = max(argRaw, 1e-10);
      final expectedF = max(0.25 / pow(log(arg) / ln10, 2), 0.008);
      
      final expectedLoss = expectedF * (50 / 0.1) * (pow(results.flowSpeed, 2) / (2 * 9.81));
      expect(results.pressureLoss, closeTo(expectedLoss, 1e-10));
    });

    test('6. Safety clamps (Extreme Reynolds testing bounds)', () {
      // Pushing an impossibly massive flow rate to trigger extreme boundaries
      final results = FlowCalculator.calculate(
        L: 10,
        D: 1.0, 
        Q: 1.0e10, // Massive flow causing Re ~ 1e16 -> testing f = 0.008 clamp and 1e-10 arg clamp!
      );
      
      final argsRawManual = 5.74 / pow(results.re, 0.9); 
      expect(argsRawManual, lessThan(1e-10)); // Verify we ARE pushing into the clamped range!

      final arg = max(argsRawManual, 1e-10); // Handled safely by logic
      final expectedF = max(0.25 / pow(log(arg) / ln10, 2), 0.008); // Will trigger the 0.008 limit
      
      final expectedLoss = expectedF * (10 / 1.0) * (pow(results.flowSpeed, 2) / (2 * 9.81));
      expect(results.pressureLoss, closeTo(expectedLoss, 1e-3)); // using slightly wider approx for huge numbers
    });

    test('7. Flow Status triggers (Velocity Enum mappings)', () {
      // low status < 0.5 m/s
      final lowFlow = FlowCalculator.calculate(L: 10, D: 0.1, Q: 0.1 * pi * pow(0.05, 2));
      expect(lowFlow.flowStatus, FlowStatus.low);

      // normal status [0.5, 3.0] m/s
      final normalFlow = FlowCalculator.calculate(L: 10, D: 0.1, Q: 1.0 * pi * pow(0.05, 2));
      expect(normalFlow.flowStatus, FlowStatus.normal);

      final normalFlowMax = FlowCalculator.calculate(L: 10, D: 0.1, Q: 2.9 * pi * pow(0.05, 2));
      expect(normalFlowMax.flowStatus, FlowStatus.normal);

      // high status > 3.0 m/s
      final highFlow = FlowCalculator.calculate(L: 10, D: 0.1, Q: 3.1 * pi * pow(0.05, 2));
      expect(highFlow.flowStatus, FlowStatus.high);
    });
  });
}
