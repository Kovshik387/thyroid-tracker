import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/design_tokens.dart';
import 'app_card.dart';

class TrendPoint {
  const TrendPoint({
    required this.date,
    required this.value,
  });

  final DateTime date;
  final double value;
}

class TrendChartCard extends StatelessWidget {
  const TrendChartCard({
    required this.title,
    required this.points,
    required this.valueSuffix,
    this.lineColor = AppColors.azure,
    this.emptyText = 'Недостаточно данных для графика.',
    super.key,
  });

  final String title;
  final List<TrendPoint> points;
  final String valueSuffix;
  final Color lineColor;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          if (sorted.length < 2)
            Text(
              emptyText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted),
            )
          else
            SizedBox(
              height: 220,
              child: LineChart(_chartData(context, sorted)),
            ),
        ],
      ),
    );
  }

  LineChartData _chartData(BuildContext context, List<TrendPoint> points) {
    final firstDate = points.first.date;
    final spots = points
        .map(
          (point) => FlSpot(
            point.date.difference(firstDate).inDays.toDouble(),
            point.value,
          ),
        )
        .toList();

    final minX = spots.first.x;
    final maxX = spots.last.x == minX ? minX + 1 : spots.last.x;
    final rawMinY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final rawMaxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final yPadding = ((rawMaxY - rawMinY).abs() * 0.22).clamp(0.8, 3.0);
    final minY = rawMinY - yPadding;
    final maxY = rawMaxY + yPadding;
    final xInterval = ((maxX - minX) / 4).clamp(1.0, 90.0);
    final yInterval = ((maxY - minY) / 4).clamp(0.5, 10.0);

    return LineChartData(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        drawVerticalLine: true,
        horizontalInterval: yInterval,
        verticalInterval: xInterval,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: AppColors.border,
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
        getDrawingVerticalLine: (_) => const FlLine(
          color: AppColors.border,
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: AppColors.borderStrong),
          bottom: BorderSide(color: AppColors.borderStrong),
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: yInterval,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatNumber(value),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.muted),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            interval: xInterval,
            getTitlesWidget: (value, meta) {
              final date = firstDate.add(Duration(days: value.round()));
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  DateFormat('MM.yy').format(date),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.muted),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.24,
          preventCurveOverShooting: true,
          barWidth: 3,
          color: lineColor,
          dotData: FlDotData(show: spots.length <= 24),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                lineColor.withValues(alpha: 0.20),
                lineColor.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 14,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          tooltipMargin: AppSpacing.sm,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (_) => AppColors.ink.withValues(alpha: 0.88),
          getTooltipItems: (items) {
            return items.map((item) {
              return LineTooltipItem(
                '${_formatNumber(item.y)} $valueSuffix',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

String _formatNumber(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}
