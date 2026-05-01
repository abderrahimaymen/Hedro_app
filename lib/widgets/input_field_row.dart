import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';

/// Styled input field row matching the React reference design.
class InputFieldRow extends StatelessWidget {
  const InputFieldRow({
    super.key,
    required this.controller,
    required this.label,
    required this.unit,
    required this.helpText,
    required this.placeholder,
    required this.icon,
    required this.hasError,
    required this.isDark,
    this.optional = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String unit;
  final String helpText;
  final String placeholder;
  final IconData icon;
  final bool hasError;
  final bool isDark;
  final bool optional;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final inputBg = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF3F4F6);
    final errorBg = const Color(0xFFFEF2F2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          children: [
            Icon(icon, size: 17, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            if (optional) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Builder(builder: (context) {
                  return Text(
                    context.read<AppProvider>().t('label_optional'),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: mutedColor),
                  );
                }),
              ),
            ],
            const Spacer(),
            Text(
              unit,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: mutedColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Help text
        Text(
          helpText,
          style: TextStyle(fontSize: 11, color: mutedColor),
        ),
        const SizedBox(height: 8),
        // Text field
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          style: TextStyle(fontSize: 15, color: hasError ? const Color(0xFFB91C1C) : textColor),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: mutedColor, fontSize: 15),
            filled: true,
            fillColor: hasError ? errorBg : inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hasError ? const Color(0xFFF87171) : Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFF87171) : Colors.transparent,
                width: hasError ? 1.5 : 0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFF87171) : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
            ),
          ),
        ),
        // Inline error
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 12, color: Color(0xFFEF4444)),
              const SizedBox(width: 4),
              Text(
                'Please enter a valid positive number',
                style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
