import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/university/ui/widgets/university_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models & dummy data — swap with API responses later.
// ─────────────────────────────────────────────────────────────────────────────

enum MetricTone { primary, success, purple, accent, danger }

enum AnalyticsRange { week, month, sixMonths, year }

extension AnalyticsRangeX on AnalyticsRange {
  String get label {
    switch (this) {
      case AnalyticsRange.week:
        return 'أسبوع';
      case AnalyticsRange.month:
        return 'شهر';
      case AnalyticsRange.sixMonths:
        return '٦ أشهر';
      case AnalyticsRange.year:
        return 'سنة';
    }
  }
}

class KpiMetric {
  const KpiMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
    required this.trend,
    required this.isUp,
  });

  final String label;
  final String value;
  final IconData icon;
  final MetricTone tone;
  final String trend;
  final bool isUp;
}

class AnalyticsRangeData {
  const AnalyticsRangeData({
    required this.views,
    required this.students,
    required this.requests,
    required this.conversion,
    required this.labels,
    required this.viewSeries,
    required this.interestSeries,
  });

  final int views;
  final int students;
  final int requests;
  final double conversion;
  final List<String> labels;
  final List<double> viewSeries;
  final List<double> interestSeries;
}

class RankedProgram {
  const RankedProgram({
    required this.rank,
    required this.name,
    required this.percent,
    required this.interested,
    required this.views,
  });

  final int rank;
  final String name;
  final int percent;
  final int interested;
  final int views;
}

class FunnelStage {
  const FunnelStage({
    required this.name,
    required this.icon,
    required this.tone,
    required this.percent,
    required this.count,
  });

  final String name;
  final IconData icon;
  final MetricTone tone;
  final int percent;
  final int count;
}

const Map<AnalyticsRange, AnalyticsRangeData> _rangeData =
    <AnalyticsRange, AnalyticsRangeData>{
  AnalyticsRange.week: AnalyticsRangeData(
    views: 2140,
    students: 310,
    requests: 78,
    conversion: 7.8,
    labels: <String>[
      'يوم ١',
      'يوم ٢',
      'يوم ٣',
      'يوم ٤',
      'يوم ٥',
      'يوم ٦',
      'يوم ٧'
    ],
    viewSeries: <double>[320, 510, 430, 680, 590, 760, 640],
    interestSeries: <double>[90, 150, 130, 210, 180, 240, 200],
  ),
  AnalyticsRange.month: AnalyticsRangeData(
    views: 8432,
    students: 1250,
    requests: 312,
    conversion: 8.4,
    labels: <String>['أسبوع ١', 'أسبوع ٢', 'أسبوع ٣', 'أسبوع ٤'],
    viewSeries: <double>[1420, 2890, 2450, 3420],
    interestSeries: <double>[410, 890, 680, 1120],
  ),
  AnalyticsRange.sixMonths: AnalyticsRangeData(
    views: 48190,
    students: 7420,
    requests: 1890,
    conversion: 9.1,
    labels: <String>['مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس'],
    viewSeries: <double>[8200, 9600, 8900, 11500, 12400, 13800],
    interestSeries: <double>[2100, 2600, 2400, 3100, 3400, 3900],
  ),
  AnalyticsRange.year: AnalyticsRangeData(
    views: 96400,
    students: 14800,
    requests: 3840,
    conversion: 8.9,
    labels: <String>[
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ],
    viewSeries: <double>[
      7200,
      8100,
      7600,
      9400,
      8800,
      10200,
      9800,
      11600,
      12400,
      13100,
      12800,
      14200,
    ],
    interestSeries: <double>[
      1800,
      2100,
      1900,
      2500,
      2300,
      2800,
      2600,
      3100,
      3300,
      3500,
      3400,
      3800,
    ],
  ),
};

String _formatNumber(num value) {
  final bool negative = value < 0;
  final String digits = value.abs().round().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}$buffer';
}

String _compactAxis(double value) {
  if (value <= 0) return '0';
  if (value >= 1000) {
    final double k = value / 1000;
    return k == k.roundToDouble()
        ? '${k.toInt()}k'
        : '${k.toStringAsFixed(1)}k';
  }
  return value.toInt().toString();
}

double _niceMax(double value) {
  if (value <= 0) return 1;
  final double magnitude =
      math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
  final double normalized = value / magnitude;
  final double halfStep = (normalized * 2).ceilToDouble() / 2;
  return halfStep * magnitude;
}

Color _toneColor(AppColors c, MetricTone tone) {
  switch (tone) {
    case MetricTone.primary:
      return c.primary;
    case MetricTone.success:
      return c.success;
    case MetricTone.purple:
      return c.purple;
    case MetricTone.accent:
      return c.accent;
    case MetricTone.danger:
      return c.danger;
  }
}

Color _toneSoft(AppColors c, MetricTone tone) {
  switch (tone) {
    case MetricTone.primary:
      return c.primarySoft;
    case MetricTone.success:
      return c.successSoft;
    case MetricTone.purple:
      return c.purpleSoft;
    case MetricTone.accent:
      return c.accentSoft;
    case MetricTone.danger:
      return c.dangerSoft;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class UniversityAnalyticsScreen extends StatefulWidget {
  const UniversityAnalyticsScreen({super.key});

  @override
  State<UniversityAnalyticsScreen> createState() =>
      _UniversityAnalyticsScreenState();
}

class _UniversityAnalyticsScreenState extends State<UniversityAnalyticsScreen> {
  AnalyticsRange _range = AnalyticsRange.month;

  AnalyticsRangeData get _data => _rangeData[_range]!;

  double get _scale {
    switch (_range) {
      case AnalyticsRange.week:
        return 0.25;
      case AnalyticsRange.month:
        return 1.0;
      case AnalyticsRange.sixMonths:
        return 6.0;
      case AnalyticsRange.year:
        return 12.0;
    }
  }

  List<KpiMetric> get _kpis {
    final AnalyticsRangeData d = _data;
    return <KpiMetric>[
      KpiMetric(
        label: 'إجمالي المشاهدات',
        value: _formatNumber(d.views),
        icon: Icons.visibility_rounded,
        tone: MetricTone.primary,
        trend: '18%',
        isUp: true,
      ),
      KpiMetric(
        label: 'طالب مهتم',
        value: _formatNumber(d.students),
        icon: Icons.people_alt_rounded,
        tone: MetricTone.success,
        trend: '12%',
        isUp: true,
      ),
      KpiMetric(
        label: 'طلبات تقديم',
        value: _formatNumber(d.requests),
        icon: Icons.how_to_reg_rounded,
        tone: MetricTone.purple,
        trend: '6%',
        isUp: true,
      ),
      KpiMetric(
        label: 'معدل التحويل',
        value: '${d.conversion.toStringAsFixed(1)}%',
        icon: Icons.percent_rounded,
        tone: MetricTone.accent,
        trend: '2%',
        isUp: false,
      ),
    ];
  }

  List<RankedProgram> get _rankedPrograms => <RankedProgram>[
        RankedProgram(
          rank: 1,
          name: 'هندسة البرمجيات',
          percent: 89,
          interested: (342 * _scale).round(),
          views: (2300 * _scale).round(),
        ),
        RankedProgram(
          rank: 2,
          name: 'الذكاء الاصطناعي',
          percent: 76,
          interested: (289 * _scale).round(),
          views: (1950 * _scale).round(),
        ),
        RankedProgram(
          rank: 3,
          name: 'الطب البشري والجراحة',
          percent: 64,
          interested: (234 * _scale).round(),
          views: (1700 * _scale).round(),
        ),
        RankedProgram(
          rank: 4,
          name: 'إدارة الأعمال الدولية',
          percent: 51,
          interested: (180 * _scale).round(),
          views: (1200 * _scale).round(),
        ),
      ];

  List<FunnelStage> get _funnelStages => <FunnelStage>[
        FunnelStage(
          name: 'شاهد التوصية',
          icon: Icons.visibility_rounded,
          tone: MetricTone.primary,
          percent: 100,
          count: (1200 * _scale).round(),
        ),
        FunnelStage(
          name: 'فتح التفاصيل',
          icon: Icons.info_outline_rounded,
          tone: MetricTone.purple,
          percent: 62,
          count: (744 * _scale).round(),
        ),
        FunnelStage(
          name: 'أضاف للمفضلة',
          icon: Icons.favorite_rounded,
          tone: MetricTone.danger,
          percent: 38,
          count: (456 * _scale).round(),
        ),
        FunnelStage(
          name: 'قدّم طلب تقديم',
          icon: Icons.task_alt_rounded,
          tone: MetricTone.success,
          percent: 12,
          count: (144 * _scale).round(),
        ),
      ];

  void _onNavChanged(int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        context.go('/university');
        break;
      case 1:
        context.go('/university/programs');
        break;
      case 3:
        context.go('/university/students');
        break;
      case 4:
        context.go('/university/settings');
        break;
    }
  }

  Future<void> _openExportSheet() async {
    final String? type = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        final AppColors c = ctx.appColors;
        return Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: c.isDark ? Border(top: BorderSide(color: c.divider)) : null,
          ),
          child: const SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: _ExportSheet(),
            ),
          ),
        );
      },
    );

    if (!mounted || type == null) return;
    _showSnack('تم بدء تصدير $type بنجاح، سيتم إشعارك فور اكتماله');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: context.appColors.success,
          content: Row(
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(c),
                  const SizedBox(height: 20),
                  _RangeSelector(
                    selected: _range,
                    onChanged: (AnalyticsRange range) =>
                        setState(() => _range = range),
                  ),
                  const SizedBox(height: 28),
                  _buildKpiGrid(),
                  const SizedBox(height: 28),
                  _InterestChartCard(data: _data),
                  const SizedBox(height: 28),
                  _buildRankedCard(c),
                  const SizedBox(height: 28),
                  _buildFunnelCard(c),
                  const SizedBox(height: 28),
                  _InsightCard(
                    onContact: () => _showSnack(
                      'جاري تجهيز قائمة الطلاب المتوافقين للتواصل...',
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: UniversityBottomNav(
          currentIndex: 2,
          onChanged: _onNavChanged,
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors c) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'التحليلات',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'أداء جامعتك واهتمام الطلاب',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _IconCircleButton(
          icon: Icons.ios_share_rounded,
          onTap: _openExportSheet,
        ),
      ],
    );
  }

  Widget _buildKpiGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 124,
      ),
      children: <Widget>[
        for (final KpiMetric metric in _kpis) _KpiCard(metric: metric),
      ],
    );
  }

  Widget _buildRankedCard(AppColors c) {
    final List<RankedProgram> programs = _rankedPrograms;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'أعلى التخصصات تفاعلاً',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < programs.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 16),
            _RankRow(program: programs[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildFunnelCard(AppColors c) {
    final List<FunnelStage> stages = _funnelStages;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'مسار الطالب',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'من التوصية حتى التقديم',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < stages.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 12),
            _FunnelStep(stage: stages[i]),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (1) Export / header button
// ─────────────────────────────────────────────────────────────────────────────

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: c.surface,
        shape: BoxShape.circle,
        border: c.isDark ? Border.all(color: c.divider) : null,
        boxShadow: c.isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(icon, size: 20, color: c.textPrimary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (2) Time range selector
// ─────────────────────────────────────────────────────────────────────────────

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onChanged});

  final AnalyticsRange selected;
  final ValueChanged<AnalyticsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: c.divider.withValues(alpha: c.isDark ? 1 : 0.6),
        ),
      ),
      child: Row(
        children: <Widget>[
          for (final AnalyticsRange range in AnalyticsRange.values)
            Expanded(
              child: _RangeSegment(
                label: range.label,
                selected: range == selected,
                onTap: () => onChanged(range),
              ),
            ),
        ],
      ),
    );
  }
}

class _RangeSegment extends StatelessWidget {
  const _RangeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: selected && !c.isDark
              ? <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? c.primary : c.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (3) KPI cards
// ─────────────────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.metric});

  final KpiMetric metric;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color tone = _toneColor(c, metric.tone);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _toneSoft(c, metric.tone),
                  shape: BoxShape.circle,
                ),
                child: Icon(metric.icon, size: 20, color: tone),
              ),
              const Spacer(),
              _TrendPill(
                isUp: metric.isUp,
                text: metric.trend,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                metric.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                metric.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill({required this.isUp, required this.text});

  final bool isUp;
  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color color = isUp ? c.success : c.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isUp ? c.successSoft : c.dangerSoft,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (4) Interest trend line chart
// ─────────────────────────────────────────────────────────────────────────────

class _InterestChartCard extends StatelessWidget {
  const _InterestChartCard({required this.data});

  final AnalyticsRangeData data;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    final double maxValue = <double>[
      ...data.viewSeries,
      ...data.interestSeries,
    ].reduce(math.max);
    final double maxY = _niceMax(maxValue * 1.05);
    final double interval = maxY / 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'اتجاه الاهتمام',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const Spacer(),
              _LegendDot(color: c.primary, label: 'مشاهدات'),
              const SizedBox(width: 12),
              _LegendDot(color: c.purple, label: 'اهتمام'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              _chartData(c, maxY, interval),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _chartData(AppColors c, double maxY, double interval) {
    return LineChartData(
      minX: 0,
      maxX: (data.viewSeries.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (double value) => FlLine(
          color: c.divider,
          strokeWidth: 1,
          dashArray: const <int>[4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            interval: interval,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value < 0 || value > maxY) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 6,
                child: Text(
                  _compactAxis(value),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    color: c.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              final int index = value.round();
              if (index < 0 || index >= data.labels.length) {
                return const SizedBox.shrink();
              }
              final int step = data.labels.length > 6 ? 2 : 1;
              if (index % step != 0) return const SizedBox.shrink();
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 6,
                child: Text(
                  data.labels[index],
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    color: c.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: const Color(0xFF0F172A),
          tooltipRoundedRadius: 12,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          maxContentWidth: 200,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (List<LineBarSpot> spots) {
            return spots.map((LineBarSpot spot) {
              final bool isViews = spot.barIndex == 0;
              return LineTooltipItem(
                '${isViews ? 'مشاهدات' : 'اهتمام'}: ${_formatNumber(spot.y)}',
                TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isViews
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFFC4B5FD),
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: <LineChartBarData>[
        _bar(
          c,
          data.viewSeries,
          c.primary,
          fill: true,
        ),
        _bar(
          c,
          data.interestSeries,
          c.purple,
          fill: false,
        ),
      ],
    );
  }

  LineChartBarData _bar(
    AppColors c,
    List<double> series,
    Color color, {
    required bool fill,
  }) {
    return LineChartBarData(
      spots: <FlSpot>[
        for (int i = 0; i < series.length; i++) FlSpot(i.toDouble(), series[i]),
      ],
      isCurved: true,
      curveSmoothness: 0.32,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      isStrokeJoinRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (
          FlSpot spot,
          double percent,
          LineChartBarData bar,
          int index,
        ) {
          return FlDotCirclePainter(
            radius: 4,
            color: c.surface,
            strokeWidth: 2,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: fill,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 10,
            color: c.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared progress bar
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.height,
    this.color,
    this.gradient,
  });

  final double value;
  final double height;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ColoredBox(color: c.divider),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double animated, Widget? child) {
                return FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: animated,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      gradient: gradient,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (5) Ranked programs
// ─────────────────────────────────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  const _RankRow({required this.program});

  final RankedProgram program;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${program.rank}',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      program.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${program.percent}%',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _ProgressBar(
                value: program.percent / 100,
                height: 6,
                color: c.primary,
              ),
              const SizedBox(height: 6),
              Text(
                '${program.interested} مهتم · ${_formatNumber(program.views)} مشاهدة',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 10,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (6) Student funnel
// ─────────────────────────────────────────────────────────────────────────────

class _FunnelStep extends StatelessWidget {
  const _FunnelStep({required this.stage});

  final FunnelStage stage;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color tone = _toneColor(c, stage.tone);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _toneSoft(c, stage.tone),
            shape: BoxShape.circle,
          ),
          child: Icon(stage.icon, size: 17, color: tone),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      stage.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${stage.percent}%',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _ProgressBar(
                value: stage.percent / 100,
                height: 8,
                gradient: LinearGradient(
                  colors: <Color>[
                    tone,
                    tone.withValues(alpha: 0.55),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatNumber(stage.count)} طالب',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 10,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (7) AI insights card
// ─────────────────────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.onContact});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: <Color>[c.gradientStart, c.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: c.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ترشيحات ذكية 💡',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  '3 جديد',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InsightTile(
            icon: Icons.person_search_rounded,
            text: '١٥ طالب توافقهم 90%+ مع تخصص الصيدلة هذا الشهر',
            action: _WhitePillButton(
              label: 'تواصل معهم',
              onTap: onContact,
            ),
          ),
          const SizedBox(height: 10),
          const _InsightTile(
            icon: Icons.trending_up_rounded,
            text:
                'تخصص الأمن السيبراني نما 24% هذا الشهر — فكر بتحديث بياناته وإضافة خطط جديدة.',
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.text,
    this.action,
  });

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                if (action != null) ...<Widget>[
                  const SizedBox(height: 8),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhitePillButton extends StatelessWidget {
  const _WhitePillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (8) Export bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ExportSheet extends StatelessWidget {
  const _ExportSheet();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.divider,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'تصدير التقرير',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  customBorder: const CircleBorder(),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'اختر صيغة التقرير المناسبة لمشاركتها مع الإدارة',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        _ExportOption(
          icon: Icons.picture_as_pdf_rounded,
          tone: MetricTone.danger,
          name: 'ملف PDF',
          description: 'تقرير جاهز للطباعة والمشاركة',
          onTap: () => Navigator.pop(context, 'PDF'),
        ),
        const SizedBox(height: 12),
        _ExportOption(
          icon: Icons.table_chart_rounded,
          tone: MetricTone.success,
          name: 'ملف Excel',
          description: 'بيانات قابلة للتحليل والتعديل',
          onTap: () => Navigator.pop(context, 'Excel'),
        ),
      ],
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.tone,
    required this.name,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final MetricTone tone;
  final String name;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color color = _toneColor(c, tone);

    return Material(
      color: c.surfaceAlt,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _toneSoft(c, tone),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_left_rounded,
                size: 20,
                color: c.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration(AppColors c) {
  return BoxDecoration(
    color: c.surface,
    borderRadius: BorderRadius.circular(20),
    border: c.isDark ? Border.all(color: c.divider) : null,
    boxShadow: c.isDark
        ? null
        : <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
  );
}
