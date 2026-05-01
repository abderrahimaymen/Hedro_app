import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/flow_calculator.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/app_header.dart';

/// Result screen — shows large result cards with status feedback.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant ResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entryCtrl
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDark;
    final results = provider.results;

    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: provider.t('results_title'),
              subtitle: provider.t('results_subtitle'),
              emoji: '📊',
            ),
            Expanded(
              child: results == null
                  ? _EmptyState(isDark: isDark, provider: provider)
                  : FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: _ResultsContent(
                          results: results,
                          isDark: isDark,
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          onReset: () {
                            provider.resetAll();
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results Content ───────────────────────────────────────────────────
class _ResultsContent extends StatelessWidget {
  const _ResultsContent({
    required this.results,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
    required this.textMuted,
    required this.onReset,
  });

  final FlowResults results;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;
  final Color textMuted;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final status = results.flowStatus;

    final statusConfig = {
      FlowStatus.low: _StatusConfig(
        emoji: '⬇️',
        title: provider.t('flow_low_title'),
        advice: provider.t('flow_low_advice'),
        iconData: Icons.arrow_downward_rounded,
        iconColor: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        darkBgColor: const Color(0xFF78350F).withValues(alpha: 0.4),
        barColor: AppColors.statusLow,
      ),
      FlowStatus.normal: _StatusConfig(
        emoji: '✅',
        title: provider.t('flow_normal_title'),
        advice: provider.t('flow_normal_advice'),
        iconData: Icons.check_circle_outline,
        iconColor: const Color(0xFF059669),
        bgColor: const Color(0xFFD1FAE5),
        darkBgColor: const Color(0xFF064E3B).withValues(alpha: 0.4),
        barColor: AppColors.statusNormal,
      ),
      FlowStatus.high: _StatusConfig(
        emoji: '⚠️',
        title: provider.t('flow_high_title'),
        advice: provider.t('flow_high_advice'),
        iconData: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEE2E2),
        darkBgColor: const Color(0xFF7F1D1D).withValues(alpha: 0.4),
        barColor: AppColors.statusHigh,
      ),
    };

    final s = statusConfig[status]!;
    final barWidth = (results.flowSpeed / 5.0).clamp(0.0, 1.0);

    // Flow type label
    final String flowType;
    if (results.re < 2300) {
      flowType = provider.t('flow_smooth');
    } else if (results.re < 4000) {
      flowType = provider.t('flow_mixed');
    } else {
      flowType = provider.t('flow_turbulent');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        children: [
          // Speed card
          _GradientResultCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
            ),
            shadowColor: const Color(0xFF2563EB),
            icon: Icons.air,
            label: provider.t('card_speed_label'),
            value: results.flowSpeed.toStringAsFixed(3),
            unit: 'm/s',
            sublabel: provider.t('card_speed_sub'),
          ),

          const SizedBox(height: 12),

          // Pressure loss card
          _GradientResultCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
            ),
            shadowColor: const Color(0xFF06B6D4),
            icon: Icons.trending_down,
            label: provider.t('card_pressure_label'),
            value: results.pressureLoss.toStringAsFixed(3),
            unit: 'm',
            sublabel: provider.t('card_pressure_sub'),
          ),

          const SizedBox(height: 12),

          // Status card
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? s.darkBgColor : s.bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(s.iconData, color: s.iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.t('section_flow_status'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          s.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Speed bar indicator
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 12,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                Container(
                                  width: constraints.maxWidth,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: barWidth),
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.easeOut,
                                  builder: (context, val, _) {
                                    return Container(
                                      width: constraints.maxWidth * val,
                                      decoration: BoxDecoration(
                                        color: s.barColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider.t('bar_low'),
                          style: TextStyle(fontSize: 10, color: textMuted),
                        ),
                        Text(
                          provider.t('bar_normal'),
                          style: TextStyle(fontSize: 10, color: textMuted),
                        ),
                        Text(
                          provider.t('bar_high'),
                          style: TextStyle(fontSize: 10, color: textMuted),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Advice
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    s.advice,
                    style: TextStyle(
                      fontSize: 13,
                      color: textMuted,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Pipe details card
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
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
                  provider.t('section_pipe_details'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _InfoPill(
                        label: provider.t('label_area'),
                        value:
                            '${(results.area * 10000).toStringAsFixed(2)} cm²',
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoPill(
                        label: provider.t('label_flow_type'),
                        value: flowType,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(provider.t('btn_new_calc')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : const Color(0xFFE5E7EB),
                    ),
                    foregroundColor: textMuted,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Gradient result card ──────────────────────────────────────────────
class _GradientResultCard extends StatelessWidget {
  const _GradientResultCard({
    required this.gradient,
    required this.shadowColor,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.sublabel,
  });

  final LinearGradient gradient;
  final Color shadowColor;
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      unit,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                sublabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Info Pill ─────────────────────────────────────────────────────────
class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.value,
    required this.isDark,
    required this.textPrimary,
    required this.textMuted,
  });
  final String label;
  final String value;
  final bool isDark;
  final Color textPrimary;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status config helper ──────────────────────────────────────────────
class _StatusConfig {
  const _StatusConfig({
    required this.emoji,
    required this.title,
    required this.advice,
    required this.iconData,
    required this.iconColor,
    required this.bgColor,
    required this.darkBgColor,
    required this.barColor,
  });
  final String emoji;
  final String title;
  final String advice;
  final IconData iconData;
  final Color iconColor;
  final Color bgColor;
  final Color darkBgColor;
  final Color barColor;
}

// ── Empty state ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark, required this.provider});
  final bool isDark;
  final AppProvider provider;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B7280);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFCFFAFE)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.water_drop,
                size: 40,
                color: Color(0xFF60A5FA),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              provider.t('no_results'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.t('no_results_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textMuted, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
