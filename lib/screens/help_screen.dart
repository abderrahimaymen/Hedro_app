import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/app_header.dart';

// ── Help item data model ──────────────────────────────────────────────
class _HelpItem {
  const _HelpItem({
    required this.emoji,
    required this.title,
    required this.short,
    required this.detail,
    required this.example,
    required this.accentColor,
    required this.bgColor,
    required this.darkBgColor,
  });
  final String emoji;
  final String title;
  final String short;
  final String detail;
  final String example;
  final Color accentColor;
  final Color bgColor;
  final Color darkBgColor;
}

// Items moved inside build method for localization access

/// Help & Guide screen — expandable FAQ items explaining inputs and outputs.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDark;

    final helpItems = [
      _HelpItem(
        emoji: '📏',
        title: provider.t('h_len_title'),
        short: provider.t('h_len_short'),
        detail: provider.t('h_len_detail'),
        example: provider.t('h_len_example'),
        accentColor: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        darkBgColor: const Color(0xFF1E3A5F),
      ),
      _HelpItem(
        emoji: '⭕',
        title: provider.t('h_diam_title'),
        short: provider.t('h_diam_short'),
        detail: provider.t('h_diam_detail'),
        example: provider.t('h_diam_example'),
        accentColor: const Color(0xFF06B6D4),
        bgColor: const Color(0xFFECFEFF),
        darkBgColor: const Color(0xFF164E63),
      ),
      _HelpItem(
        emoji: '💧',
        title: provider.t('h_flow_title'),
        short: provider.t('h_flow_short'),
        detail: provider.t('h_flow_detail'),
        example: provider.t('h_flow_example'),
        accentColor: const Color(0xFF6366F1),
        bgColor: const Color(0xFFEEF2FF),
        darkBgColor: const Color(0xFF312E81),
      ),
      _HelpItem(
        emoji: '🔧',
        title: provider.t('h_rough_title'),
        short: provider.t('h_rough_short'),
        detail: provider.t('h_rough_detail'),
        example: provider.t('h_rough_example'),
        accentColor: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        darkBgColor: const Color(0xFF78350F),
      ),
    ];

    final resultItems = [
      (
        emoji: '💨',
        title: provider.t('h_speed_title'),
        description: provider.t('h_speed_desc'),
        normal: provider.t('h_speed_normal'),
        accentColor: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        darkBgColor: const Color(0xFF1E3A5F),
      ),
      (
        emoji: '📉',
        title: provider.t('h_pressure_title'),
        description: provider.t('h_pressure_desc'),
        normal: provider.t('h_pressure_normal'),
        accentColor: const Color(0xFF06B6D4),
        bgColor: const Color(0xFFECFEFF),
        darkBgColor: const Color(0xFF164E63),
      ),
    ];

    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(
                title: provider.t('help_title'),
                subtitle: provider.t('help_subtitle'),
                emoji: '📚',
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Input fields section ───────────────────────────
                  _SectionLabel(
                    isDark: isDark,
                    emoji: '📋',
                    text: provider.t('section_inputs'),
                  ),
                  const SizedBox(height: 12),

                  // Expandable help items
                  ...List.generate(helpItems.length, (i) {
                    final item = helpItems[i];
                    final isExpanded = _expandedIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => setState(() {
                                _expandedIndex = isExpanded ? null : i;
                              }),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? item.darkBgColor
                                            : item.bgColor,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item.emoji,
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.short,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textMuted,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.5 : 0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: textMuted,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Expanded content
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: const SizedBox.shrink(),
                              secondChild: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                      color: isDark
                                          ? AppColors.darkBorder
                                          : const Color(0xFFE5E7EB),
                                      height: 16,
                                    ),
                                    Text(
                                      item.detail,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textMuted,
                                        height: 1.7,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? item.darkBgColor
                                            : item.bgColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item.example,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: item.accentColor,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // ── Results section ────────────────────────────────
                  _SectionLabel(
                    isDark: isDark,
                    emoji: '📊',
                    text: provider.t('section_results_help'),
                  ),
                  const SizedBox(height: 12),

                  ...List.generate(resultItems.length, (i) {
                    final item = resultItems[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? item.darkBgColor
                                        : item.bgColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.emoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: textMuted,
                                height: 1.7,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? item.darkBgColor : item.bgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '✅',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${provider.t('good_range')} ${item.normal}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: item.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // ── Flow status guide ──────────────────────────────
                  _SectionLabel(
                    isDark: isDark,
                    emoji: '🚦',
                    text: provider.t('section_status_help'),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _StatusRow(
                          emoji: '⬇️',
                          bgColor: isDark
                              ? const Color(0xFF78350F).withValues(alpha: 0.4)
                              : const Color(0xFFFEF3C7),
                          textColor: const Color(0xFFD97706),
                          label: provider.t('status_low_label'),
                          desc: provider.t('status_low_desc'),
                          textMuted: textMuted,
                        ),
                        const SizedBox(height: 8),
                        _StatusRow(
                          emoji: '✅',
                          bgColor: isDark
                              ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                              : const Color(0xFFD1FAE5),
                          textColor: const Color(0xFF059669),
                          label: provider.t('status_normal_label'),
                          desc: provider.t('status_normal_desc'),
                          textMuted: textMuted,
                        ),
                        const SizedBox(height: 8),
                        _StatusRow(
                          emoji: '⚠️',
                          bgColor: isDark
                              ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
                              : const Color(0xFFFEE2E2),
                          textColor: const Color(0xFFDC2626),
                          label: provider.t('status_high_label'),
                          desc: provider.t('status_high_desc'),
                          textMuted: textMuted,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer note
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCard
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.water_drop,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            provider.t('footer_note'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF1D4ED8),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.isDark,
    required this.emoji,
    required this.text,
  });
  final bool isDark;
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Status Row ────────────────────────────────────────────────────────
class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.emoji,
    required this.bgColor,
    required this.textColor,
    required this.label,
    required this.desc,
    required this.textMuted,
  });
  final String emoji;
  final Color bgColor;
  final Color textColor;
  final String label;
  final String desc;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(desc, style: TextStyle(fontSize: 12, color: textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
