import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/input_field_row.dart';
import '../widgets/water_slider.dart';

/// Calculator screen — the main input screen.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _lengthCtrl;
  late TextEditingController _diameterCtrl;
  late TextEditingController _flowRateCtrl;
  late TextEditingController _roughnessCtrl;

  bool _showError = false;
  bool _isCalculating = false;

  late AnimationController _buttonAnimCtrl;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _lengthCtrl = TextEditingController(text: provider.inputs.pipeLength);
    _diameterCtrl = TextEditingController(text: provider.inputs.pipeDiameter);
    _flowRateCtrl = TextEditingController(text: provider.inputs.flowRate);
    _roughnessCtrl = TextEditingController(text: provider.inputs.roughness);

    _buttonAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _buttonAnimCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _diameterCtrl.dispose();
    _flowRateCtrl.dispose();
    _roughnessCtrl.dispose();
    _buttonAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCalculate(AppProvider provider) async {
    // Animate button press
    await _buttonAnimCtrl.forward();
    await _buttonAnimCtrl.reverse();

    setState(() => _isCalculating = true);

    // Brief loading delay for polish
    await Future.delayed(const Duration(milliseconds: 600));

    final success = provider.calculate();

    if (mounted) {
      setState(() {
        _showError = !success;
        _isCalculating = false;
      });

      if (success) {
        // Switch to results tab — use scaffold if nav available
        ScaffoldMessenger.of(context).clearSnackBars();
        // Navigate to results tab by posting to parent
        _goToResults();
      }
    }
  }

  void _goToResults() {
    // Pop up to HomeScreen and switch tab
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    }
    // Use callback if available (passed via InheritedWidget/callback)
    // For simplicity we use a local approach: wrap in a HomeScreenTabController if needed.
    // Instead, just show a SnackBar guiding the user to the Results tab.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.read<AppProvider>().t('snack_results')),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDark;
    final errors = provider.validationErrors;
    final results = provider.results;

    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B7280);
    final divider = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  AppHeader(
                    title: provider.t('home_title'),
                    subtitle: provider.t('home_subtitle'),
                    emoji: '💧',
                    trailingIcon: isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    onTrailingTap: provider.toggleTheme,
                  ),
                  // Language Selector
                  PositionedDirectional(
                    top: 28,
                    end:
                        80, // Moved to make space for the trailing icon mode button
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: provider.locale,
                          dropdownColor: isDark
                              ? AppColors.darkCard
                              : Colors.white,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          selectedItemBuilder: (context) {
                            return ['en', 'fr', 'ar'].map<Widget>((
                              String item,
                            ) {
                              return Center(
                                child: Text(
                                  item.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(
                                'English',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'fr',
                              child: Text(
                                'Français',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text(
                                'العربية',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) provider.setLocale(val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Error Banner ──────────────────────────────────
                  if (_showError && errors.isNotEmpty)
                    _ErrorBanner(isDark: isDark, provider: provider),
                  if (_showError && errors.isNotEmpty)
                    const SizedBox(height: 12),

                  // ── Input Card ────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.t('section_enter_data'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Pipe Length
                        InputFieldRow(
                          controller: _lengthCtrl,
                          label: provider.t('field_pipe_length'),
                          unit: 'm',
                          helpText: provider.t('field_pipe_length_help'),
                          placeholder: provider.t('field_pipe_length_hint'),
                          icon: Icons.straighten,
                          hasError: errors.contains('pipeLength'),
                          isDark: isDark,
                          onChanged: (v) =>
                              provider.updateInput('pipeLength', v),
                        ),
                        const SizedBox(height: 8),
                        WaterSlider(
                          value:
                              double.tryParse(provider.inputs.pipeLength) ?? 1,
                          min: 1,
                          max: 500,
                          divisions: 499,
                          isDark: isDark,
                          onChanged: (v) {
                            final str = v.toStringAsFixed(0);
                            provider.updateInput('pipeLength', str);
                            _lengthCtrl.text = str;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '1 m',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                            Text(
                              '500 m',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                          ],
                        ),

                        Divider(color: divider, height: 28),

                        // Pipe Diameter
                        InputFieldRow(
                          controller: _diameterCtrl,
                          label: provider.t('field_pipe_diameter'),
                          unit: 'm',
                          helpText: provider.t('field_pipe_diameter_help'),
                          placeholder: provider.t('field_pipe_diameter_hint'),
                          icon: Icons.radio_button_unchecked,
                          hasError: errors.contains('pipeDiameter'),
                          isDark: isDark,
                          onChanged: (v) =>
                              provider.updateInput('pipeDiameter', v),
                        ),
                        const SizedBox(height: 8),
                        WaterSlider(
                          value:
                              double.tryParse(provider.inputs.pipeDiameter) ??
                              0.01,
                          min: 0.01,
                          max: 1.0,
                          divisions: 99,
                          isDark: isDark,
                          onChanged: (v) {
                            final str = v.toStringAsFixed(2);
                            provider.updateInput('pipeDiameter', str);
                            _diameterCtrl.text = str;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0.01 m',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                            Text(
                              '1.00 m',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                          ],
                        ),

                        Divider(color: divider, height: 28),

                        // Flow Rate
                        InputFieldRow(
                          controller: _flowRateCtrl,
                          label: provider.t('field_flow_rate'),
                          unit: 'm³/s',
                          helpText: provider.t('field_flow_rate_help'),
                          placeholder: provider.t('field_flow_rate_hint'),
                          icon: Icons.water_drop_outlined,
                          hasError: errors.contains('flowRate'),
                          isDark: isDark,
                          onChanged: (v) => provider.updateInput('flowRate', v),
                        ),

                        Divider(color: divider, height: 28),

                        // Roughness (optional)
                        InputFieldRow(
                          controller: _roughnessCtrl,
                          label: provider.t('field_roughness'),
                          unit: 'mm',
                          helpText: provider.t('field_roughness_help'),
                          placeholder: provider.t('field_roughness_hint'),
                          icon: Icons.build_outlined,
                          hasError: false,
                          isDark: isDark,
                          optional: true,
                          onChanged: (v) =>
                              provider.updateInput('roughness', v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Tip Card ──────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFEFF6FF),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('💡', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: textMuted,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text: '${provider.t('tip_label')} ',
                                  style: const TextStyle(
                                    color: Color(0xFFD97706),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(text: provider.t('tip_text')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Calculate Button ──────────────────────────────
                  ScaleTransition(
                    scale: _buttonScale,
                    child: GestureDetector(
                      onTap: _isCalculating
                          ? null
                          : () => _handleCalculate(provider),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: _isCalculating
                              ? null
                              : AppColors.headerGradient,
                          color: _isCalculating
                              ? const Color(0xFF94A3B8)
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _isCalculating
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: _isCalculating
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      provider.t('btn_calculate'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),

                  // ── Last Result Card ──────────────────────────────
                  if (results != null) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        if (results != null) {
                          Navigator.pushNamed(context, '/results');
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : const Color(0xFFEFF6FF),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEFF6FF),
                                    Color(0xFFCFFAFE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.water_drop,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.t('last_result'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: textMuted,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${results.flowSpeed.toStringAsFixed(2)} m/s · '
                                    '${results.pressureLoss.toStringAsFixed(2)} m loss',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.isDark, required this.provider});
  final bool isDark;
  final AppProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Color(0xFFEF4444),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ ${provider.t('err_invalid_numbers')}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.t('err_positive_required'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
