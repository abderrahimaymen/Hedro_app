import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Gradient slider matching the React WaterSlider component.
class WaterSlider extends StatelessWidget {
  const WaterSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.isDark,
  });

  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.1),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
