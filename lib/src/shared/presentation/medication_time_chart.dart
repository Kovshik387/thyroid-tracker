import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/design_tokens.dart';
import '../../features/medication/domain/medication_plan.dart';

class MedicationTimeChart extends StatelessWidget {
  const MedicationTimeChart({
    super.key,
    required this.intakes,
    required this.plannedTime,
  });

  final List<MedicationIntake> intakes;
  final DateTime plannedTime;

  @override
  Widget build(BuildContext context) {
    final taken = intakes
        .where((intake) => intake.taken && intake.takenAt != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (taken.length < 2) {
      return const Center(child: Text('Пока мало отметок приема.'));
    }

    final last = _dateOnly(DateTime.now());
    final firstTaken = _dateOnly(taken.first.date);
    final visibleStart = _maxDate(
      firstTaken,
      last.subtract(const Duration(days: 84)),
    );
    final plannedMinutes = _minutesOfDay(plannedTime);
    final visibleTaken = taken
        .where((intake) => !_dateOnly(intake.date).isBefore(visibleStart))
        .toList();
    final bucketSize = last.difference(visibleStart).inDays > 35 ? 7 : 1;
    final buckets = <int, _TimeBucket>{};

    for (final intake in visibleTaken) {
      final x = _dateOnly(intake.date).difference(visibleStart).inDays;
      final bucketIndex = x ~/ bucketSize;
      buckets
          .putIfAbsent(bucketIndex, () => _TimeBucket(bucketIndex, bucketSize))
          .add(_minutesOfDay(intake.takenAt!));
    }

    if (buckets.length < 2) {
      return const Center(child: Text('Пока мало отметок приема.'));
    }

    final spots = buckets.values
        .map((bucket) => FlSpot(bucket.centerX, bucket.averageMinutes))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
    final maxX =
        last.difference(visibleStart).inDays.clamp(1, 10000).toDouble();
    final missedSpots = <FlSpot>[];
    for (var day = 0; day <= maxX; day++) {
      final bucketIndex = day ~/ bucketSize;
      if (!buckets.containsKey(bucketIndex)) {
        missedSpots.add(FlSpot(
          bucketIndex * bucketSize + (bucketSize - 1) / 2,
          plannedMinutes.toDouble(),
        ));
      }
    }
    final compactMissedSpots = <double, FlSpot>{};
    for (final spot in missedSpots) {
      compactMissedSpots[spot.x] = spot;
    }
    final yValues = [
      plannedMinutes.toDouble(),
      ...spots.map((spot) => spot.y),
    ];
    final minTakenY = yValues.reduce((a, b) => a < b ? a : b);
    final maxTakenY = yValues.reduce((a, b) => a > b ? a : b);
    final minY = (minTakenY - 45).clamp(0, 1440).toDouble();
    final maxY = (maxTakenY + 45).clamp(0, 1440).toDouble();
    final bottomInterval = maxX <= 45 ? 14.0 : 28.0;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY <= minY ? minY + 120 : maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: plannedMinutes.toDouble(),
              color: AppColors.mint,
              strokeWidth: 1.8,
              dashArray: [6, 4],
            ),
          ],
        ),
        borderData: FlBorderData(
          border: const Border(
            left: BorderSide(color: AppColors.borderStrong),
            bottom: BorderSide(color: AppColors.borderStrong),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: 60,
              getTitlesWidget: (value, meta) {
                if (value != meta.min &&
                    value != meta.max &&
                    (value - plannedMinutes).abs() > 1) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _formatMinutes(value.round()),
                  style: Theme.of(context).textTheme.labelSmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: bottomInterval,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > maxX) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    DateFormat('dd.MM').format(
                        visibleStart.add(Duration(days: value.round()))),
                    style: Theme.of(context).textTheme.labelSmall,
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
            color: AppColors.azure,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3.5,
                  color: AppColors.azure,
                  strokeWidth: 2,
                  strokeColor: AppColors.surface,
                );
              },
            ),
          ),
          if (compactMissedSpots.isNotEmpty)
            LineChartBarData(
              spots: compactMissedSpots.values.toList()
                ..sort((a, b) => a.x.compareTo(b.x)),
              color: AppColors.borderStrong,
              barWidth: 0,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.surface,
                    strokeWidth: 1.2,
                    strokeColor: AppColors.amber,
                  );
                },
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
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  '${_formatMinutes(spot.y.round())}\nсреднее',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.25,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _maxDate(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

int _minutesOfDay(DateTime date) => date.hour * 60 + date.minute;

String _formatMinutes(int minutes) {
  final safeMinutes = minutes.clamp(0, 1439);
  final hour = (safeMinutes ~/ 60).toString().padLeft(2, '0');
  final minute = (safeMinutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _TimeBucket {
  _TimeBucket(this.index, this.size);

  final int index;
  final int size;
  final List<int> values = [];

  double get centerX => index * size + (size - 1) / 2;

  double get averageMinutes =>
      values.fold<double>(0, (sum, value) => sum + value) / values.length;

  void add(int minutes) => values.add(minutes);
}
