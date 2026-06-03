import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../../../core/domain/reference_range.dart';
import '../domain/lab_evaluator.dart';
import '../domain/lab_result.dart';
import '../domain/lab_trend_analyzer.dart';
import '../../../shared/presentation/adaptive_picker.dart';
import '../../../shared/presentation/adaptive_message.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/screen_frame.dart';
import '../../../shared/presentation/status_chip.dart';

class LabsScreen extends StatefulWidget {
  const LabsScreen({super.key});

  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.watch(context);
    final filteredLabs = _filteredLabs(appState.labs);
    final evaluator = LabEvaluator(
      tshRange: appState.tshRange,
      freeT4Range: appState.freeT4Range,
      freeT3Range: appState.freeT3Range,
    );

    return ScreenFrame(
      title: 'Анализы',
      subtitle:
          'Добавляйте только числовые значения. Диапазоны можно настроить под вашу лабораторию.',
      actions: [
        IconButton(
          tooltip: 'Добавить анализ',
          onPressed: () => _showLabDialog(context),
          icon: const Icon(Icons.add),
        ),
      ],
      children: [
        _LabsFormCard(onSubmit: (entry) => _saveEntry(context, entry)),
        const SizedBox(height: AppSpacing.lg),
        _LabsChartCard(
          results: filteredLabs,
          hasAnyResults: appState.labs.isNotEmpty,
          tshRange: appState.tshRange,
          freeT4Range: appState.freeT4Range,
          freeT3Range: appState.freeT3Range,
        ),
        const SizedBox(height: AppSpacing.lg),
        _TrendCard(trend: const LabTrendAnalyzer().analyze(filteredLabs)),
        const SizedBox(height: AppSpacing.lg),
        _HistoryCard(
          results: appState.labs,
          fromDate: _fromDate,
          toDate: _toDate,
          evaluator: evaluator,
          profile: appState.userProfile,
          onPickRange: _pickRange,
          onClearRange: _clearRange,
          onEdit: (result) => _showEditDialog(context, result),
          onDelete: (result) => _deleteEntry(context, result),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ReferenceCard(
          tshRange: appState.tshRange,
          freeT4Range: appState.freeT4Range,
          freeT3Range: appState.freeT3Range,
        ),
      ],
    );
  }

  List<LabResult> _filteredLabs(List<LabResult> results) {
    final from = _fromDate == null ? null : _dateOnly(_fromDate!);
    final to = _toDate == null ? null : _dateOnly(_toDate!);
    return results.where((result) {
      final date = _dateOnly(result.date);
      if (from != null && date.isBefore(from)) {
        return false;
      }
      if (to != null && date.isAfter(to)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await pickAdaptiveDateRange(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _fromDate == null || _toDate == null
          ? null
          : DateTimeRange(start: _fromDate!, end: _toDate!),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _fromDate = picked.start;
      _toDate = picked.end;
    });
  }

  void _clearRange() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  Future<void> _showLabDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Новый анализ'),
          content: SingleChildScrollView(
            child: _LabsFormCard(
              compact: true,
              onSubmit: (entry) async {
                await _saveEntry(context, entry);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveEntry(BuildContext context, _LabEntry entry) async {
    await AppScope.read(context).addLab(
      date: entry.date,
      tsh: entry.tsh,
      freeT4: entry.freeT4,
      freeT3: entry.freeT3,
      comment: entry.comment,
    );
    if (!context.mounted) {
      return;
    }
    showAdaptiveMessage(
      context,
      'Данные анализа добавлены',
      type: AppMessageType.success,
    );
  }

  Future<void> _deleteEntry(BuildContext context, LabResult result) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить запись?'),
          content: Text(
            'Анализ от ${DateFormat('dd.MM.yyyy').format(result.date)} будет удален.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await AppScope.read(context).deleteLab(result.id);
    }
  }

  Future<void> _showEditDialog(BuildContext context, LabResult result) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Изменить анализ'),
          content: SingleChildScrollView(
            child: _LabsFormCard(
              compact: true,
              initial: result,
              submitLabel: 'Сохранить',
              onSubmit: (entry) async {
                await AppScope.read(context).updateLab(
                  id: result.id,
                  date: entry.date,
                  tsh: entry.tsh,
                  freeT4: entry.freeT4,
                  freeT3: entry.freeT3,
                  comment: entry.comment,
                );
                if (!context.mounted) {
                  return;
                }
                showAdaptiveMessage(
                  context,
                  'Запись анализа обновлена',
                  type: AppMessageType.success,
                );
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend});

  final LabTrend trend;

  @override
  Widget build(BuildContext context) {
    final color = switch (trend.direction) {
      LabTrendDirection.rising => AppColors.amber,
      LabTrendDirection.falling => AppColors.azure,
      LabTrendDirection.stable => AppColors.mint,
      LabTrendDirection.mixed => AppColors.amber,
      LabTrendDirection.insufficient => AppColors.muted,
    };
    final icon = switch (trend.direction) {
      LabTrendDirection.rising => Icons.trending_up,
      LabTrendDirection.falling => Icons.trending_down,
      LabTrendDirection.stable => Icons.trending_flat,
      LabTrendDirection.mixed => Icons.sync_alt,
      LabTrendDirection.insufficient => Icons.info_outline,
    };

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trend.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  trend.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
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

class _LabsFormCard extends StatefulWidget {
  const _LabsFormCard({
    required this.onSubmit,
    this.compact = false,
    this.initial,
    this.submitLabel = 'Сохранить',
  });

  final Future<void> Function(_LabEntry entry) onSubmit;
  final bool compact;
  final LabResult? initial;
  final String submitLabel;

  @override
  State<_LabsFormCard> createState() => _LabsFormCardState();
}

class _LabsFormCardState extends State<_LabsFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final _dateController = TextEditingController(
    text:
        DateFormat('dd.MM.yyyy').format(widget.initial?.date ?? DateTime.now()),
  );
  final _tshController = TextEditingController();
  final _freeT4Controller = TextEditingController();
  final _freeT3Controller = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial == null) {
      return;
    }
    _tshController.text = initial.tsh == null ? '' : _formatValue(initial.tsh);
    _freeT4Controller.text =
        initial.freeT4 == null ? '' : _formatValue(initial.freeT4);
    _freeT3Controller.text =
        initial.freeT3 == null ? '' : _formatValue(initial.freeT3);
    _commentController.text = initial.comment ?? '';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _tshController.dispose();
    _freeT4Controller.dispose();
    _freeT3Controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.compact) ...[
            Text('Новая запись',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Заполните только те показатели, которые есть в анализе.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _dateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Дата анализа',
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
            onTap: _pickDate,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                  child:
                      _NumberField(label: 'ТТГ', controller: _tshController)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: _NumberField(
                      label: 'Т4 св.', controller: _freeT4Controller)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                  child: _NumberField(
                      label: 'Т3 св.', controller: _freeT3Controller)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Комментарий'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(widget.submitLabel),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Дополнительный показатель'),
          ),
        ],
      ),
    );

    if (widget.compact) {
      return form;
    }

    return AppCard(child: form);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await pickAdaptiveDate(
      context: context,
      initialDate: _parseDate(_dateController.text) ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
    );

    if (picked == null) {
      return;
    }

    _dateController.text = DateFormat('dd.MM.yyyy').format(picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    await widget.onSubmit(
      _LabEntry(
        date: _parseDate(_dateController.text) ?? DateTime.now(),
        tsh: _parseNumber(_tshController.text),
        freeT4: _parseNumber(_freeT4Controller.text),
        freeT3: _parseNumber(_freeT3Controller.text),
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      ),
    );

    _tshController.clear();
    _freeT4Controller.clear();
    _freeT3Controller.clear();
    _commentController.clear();
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return null;
        }
        return _parseNumber(value) == null ? 'Только число' : null;
      },
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.pin_outlined, size: 18),
      ),
    );
  }
}

class _LabsChartCard extends StatefulWidget {
  const _LabsChartCard({
    required this.results,
    required this.hasAnyResults,
    required this.tshRange,
    required this.freeT4Range,
    required this.freeT3Range,
  });

  final List<LabResult> results;
  final bool hasAnyResults;
  final ReferenceRange tshRange;
  final ReferenceRange freeT4Range;
  final ReferenceRange freeT3Range;

  @override
  State<_LabsChartCard> createState() => _LabsChartCardState();
}

class _LabsChartCardState extends State<_LabsChartCard> {
  var _metric = _ChartMetric.tsh;

  @override
  Widget build(BuildContext context) {
    final chartResults = [...widget.results]
      ..sort((a, b) => a.date.compareTo(b.date));
    if (chartResults.isEmpty) {
      return AppCard(
        child: Text(
          widget.hasAnyResults
              ? 'За выбранный период анализов нет.'
              : 'Добавьте первый анализ, чтобы увидеть динамику.',
        ),
      );
    }

    final range = switch (_metric) {
      _ChartMetric.tsh => widget.tshRange,
      _ChartMetric.freeT4 => widget.freeT4Range,
      _ChartMetric.freeT3 => widget.freeT3Range,
    };
    final chartData = _SingleMetricChartData.fromResults(
      chartResults,
      metric: _metric,
      range: range,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Динамика', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              SegmentedButton<_ChartMetric>(
                segments: const [
                  ButtonSegment(value: _ChartMetric.tsh, label: Text('ТТГ')),
                  ButtonSegment(value: _ChartMetric.freeT4, label: Text('Т4')),
                  ButtonSegment(value: _ChartMetric.freeT3, label: Text('Т3')),
                ],
                selected: {_metric},
                showSelectedIcon: false,
                onSelectionChanged: (value) {
                  setState(() => _metric = value.first);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (chartData.spots.isEmpty)
            Text(
              'Для выбранного показателя пока нет значений.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 380;
                return SizedBox(
                  height: compact ? 250 : 300,
                  child: LineChart(
                    LineChartData(
                      minX: chartData.minX,
                      maxX: chartData.maxX,
                      minY: chartData.minY,
                      maxY: chartData.maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: chartData.spots.length > 1,
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
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(0),
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            interval: chartData.xInterval,
                            getTitlesWidget: (value, meta) {
                              if (chartData.shouldHideBottomTitle(value)) {
                                return const SizedBox.shrink();
                              }
                              return _BottomDateLabel(
                                date: chartData.dateForX(value),
                                isLongRange: chartData.maxX > 120,
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        border: const Border(
                          left: BorderSide(color: AppColors.borderStrong),
                          bottom: BorderSide(color: AppColors.borderStrong),
                        ),
                      ),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: range.min,
                            color: AppColors.mint,
                            strokeWidth: 1.4,
                            dashArray: [5, 4],
                          ),
                          HorizontalLine(
                            y: range.max,
                            color: AppColors.mint,
                            strokeWidth: 1.4,
                            dashArray: [5, 4],
                          ),
                        ],
                      ),
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
                          getTooltipColor: (_) =>
                              AppColors.ink.withValues(alpha: 0.88),
                          getTooltipItems: (items) {
                            return items.map((item) {
                              final date = chartData.dateForX(item.x);
                              final isForecast = item.barIndex == 1;
                              return LineTooltipItem(
                                '${isForecast ? 'Прогноз\n' : ''}${_formatValue(item.y)} ${range.unit}\n${DateFormat('dd.MM.yyyy').format(date)}',
                                TextStyle(
                                  color: isForecast
                                      ? AppColors.amber
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  height: 1.25,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData.spots,
                          color: AppColors.azure,
                          barWidth: 2.8,
                          isCurved: true,
                          curveSmoothness: 0.18,
                          preventCurveOverShooting: true,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.azure.withValues(alpha: 0.24),
                                AppColors.azure.withValues(alpha: 0.04),
                              ],
                            ),
                          ),
                          dotData: FlDotData(
                            show: chartData.spots.length <= 36,
                          ),
                        ),
                        if (chartData.forecastSpots.isNotEmpty)
                          LineChartBarData(
                            spots: chartData.forecastSpots,
                            color: AppColors.amber,
                            barWidth: 2.5,
                            isCurved: true,
                            curveSmoothness: 0.12,
                            preventCurveOverShooting: true,
                            dashArray: [6, 5],
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: index == 0 ? 0 : 4,
                                  color: AppColors.amber,
                                  strokeWidth: 2,
                                  strokeColor: AppColors.surface,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _LegendItem(color: AppColors.azure, label: _metric.label),
              const _LegendItem(color: AppColors.mint, label: 'Границы нормы'),
              if (chartData.forecastSpots.isNotEmpty)
                const _LegendItem(color: AppColors.amber, label: 'Прогноз'),
            ],
          ),
          if (chartData.forecastSpots.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Прогноз рассчитан методом отношений к центрированной 12-месячной скользящей средней: сезонный индекс умножается на тренд последних 12 месяцев. Это ориентировочная оценка.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Норма: ${_formatValue(range.min)}-${_formatValue(range.max)} ${range.unit}.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
          ),
        ],
      ),
    );
  }
}

enum _ChartMetric {
  tsh('ТТГ'),
  freeT4('Т4 св.'),
  freeT3('Т3 св.');

  const _ChartMetric(this.label);

  final String label;
}

class _SingleMetricChartData {
  const _SingleMetricChartData({
    required this.startDate,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.xInterval,
    required this.spots,
    required this.forecastSpots,
  });

  final DateTime startDate;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double xInterval;
  final List<FlSpot> spots;
  final List<FlSpot> forecastSpots;

  factory _SingleMetricChartData.fromResults(
    List<LabResult> results, {
    required _ChartMetric metric,
    required ReferenceRange range,
  }) {
    final start = _dateOnly(results.first.date);
    final valuesByDay = <double, List<double>>{};

    for (final result in results) {
      final value = switch (metric) {
        _ChartMetric.tsh => result.tsh,
        _ChartMetric.freeT4 => result.freeT4,
        _ChartMetric.freeT3 => result.freeT3,
      };
      if (value == null) {
        continue;
      }
      final x = _dateOnly(result.date).difference(start).inDays.toDouble();
      valuesByDay.putIfAbsent(x, () => []).add(value);
    }

    final rawSpots = valuesByDay.entries.map((entry) {
      final values = entry.value;
      final average = values.reduce((a, b) => a + b) / values.length;
      return FlSpot(entry.key, average);
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    if (rawSpots.isEmpty) {
      return _SingleMetricChartData(
        startDate: start,
        minX: 0,
        maxX: 1,
        minY: range.min - 1,
        maxY: range.max + 1,
        xInterval: 1,
        spots: const [],
        forecastSpots: const [],
      );
    }

    final forecastSpots = _forecastSpots(
      rawSpots,
      startDate: start,
    );
    final values = [
      range.min,
      range.max,
      ...rawSpots.map((spot) => spot.y),
      ...forecastSpots.skip(1).map((spot) => spot.y),
    ];
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final padding = ((maxValue - minValue).abs() * 0.18).clamp(1.0, 6.0);
    final minY = (minValue - padding).clamp(0.0, double.infinity);
    final maxY = maxValue + padding;
    final dataMaxX = rawSpots.last.x;
    final maxX = [
      dataMaxX,
      if (forecastSpots.isNotEmpty) forecastSpots.last.x,
      1.0,
    ].reduce((a, b) => a > b ? a : b);

    return _SingleMetricChartData(
      startDate: start,
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      xInterval: _intervalFor(maxX),
      spots: _sampleSpots(rawSpots, maxPoints: 48),
      forecastSpots: forecastSpots,
    );
  }

  DateTime dateForX(double x) {
    return startDate.add(Duration(days: x.round()));
  }

  bool shouldHideBottomTitle(double value) {
    if (value <= minX || value >= maxX) {
      return false;
    }
    return maxX - value < xInterval * 0.72;
  }
}

class _BottomDateLabel extends StatelessWidget {
  const _BottomDateLabel({
    required this.date,
    required this.isLongRange,
  });

  final DateTime date;
  final bool isLongRange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: SizedBox(
        width: 48,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            DateFormat(isLongRange ? 'MM.yy' : 'dd.MM').format(date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

List<FlSpot> _sampleSpots(List<FlSpot> source, {required int maxPoints}) {
  if (source.length <= maxPoints) {
    return source;
  }

  final step = (source.length - 1) / (maxPoints - 1);
  final sampled = <FlSpot>[];
  for (var i = 0; i < maxPoints; i++) {
    sampled.add(source[(i * step).round()]);
  }
  return sampled;
}

List<FlSpot> _forecastSpots(
  List<FlSpot> source, {
  required DateTime startDate,
}) {
  const seasonLength = 12;
  final monthly = _monthlyPoints(source, startDate);
  if (monthly.length < seasonLength * 2) {
    return const [];
  }

  final centeredMovingAverages = _centeredMovingAverages(
    monthly,
    seasonLength: seasonLength,
  );
  if (centeredMovingAverages.length < seasonLength) {
    return const [];
  }

  final ratiosByMonth = <int, List<double>>{};
  for (final entry in centeredMovingAverages.entries) {
    final point = monthly[entry.key];
    final movingAverage = entry.value;
    if (movingAverage <= 0 || point.value <= 0) {
      continue;
    }
    ratiosByMonth
        .putIfAbsent(point.date.month, () => [])
        .add(point.value / movingAverage);
  }

  final seasonalIndices = <int, double>{};
  for (final entry in ratiosByMonth.entries) {
    final values = entry.value;
    seasonalIndices[entry.key] =
        values.fold<double>(0, (sum, value) => sum + value) / values.length;
  }
  if (seasonalIndices.length < seasonLength) {
    return const [];
  }

  final indicesAverage =
      seasonalIndices.values.fold<double>(0, (sum, value) => sum + value) /
          seasonalIndices.length;
  if (indicesAverage <= 0) {
    return const [];
  }
  seasonalIndices.updateAll((_, value) => value / indicesAverage);

  final deseasonalized = <_TrendPoint>[];
  for (var i = 0; i < monthly.length; i++) {
    final point = monthly[i];
    final seasonalIndex = seasonalIndices[point.date.month] ?? 1;
    if (seasonalIndex <= 0) {
      continue;
    }
    deseasonalized.add(_TrendPoint(i.toDouble(), point.value / seasonalIndex));
  }
  if (deseasonalized.length < 2) {
    return const [];
  }

  final trendPoints = deseasonalized.length > seasonLength
      ? deseasonalized.sublist(deseasonalized.length - seasonLength)
      : deseasonalized;
  final trend = _linearTrend(trendPoints);
  if (trend == null) {
    return const [];
  }

  final lastMonth = monthly.last.date;
  final lastTrendValue = trend.valueAt((monthly.length - 1).toDouble());
  final lastSeasonalIndex = seasonalIndices[lastMonth.month] ?? 1;
  final fittedY =
      (lastTrendValue * lastSeasonalIndex).clamp(0.0, double.infinity);
  if (fittedY.isNaN || fittedY.isInfinite) {
    return const [];
  }

  final result = <FlSpot>[FlSpot(source.last.x, fittedY)];
  for (var step = 1; step <= 3; step++) {
    final forecastMonth = DateTime(lastMonth.year, lastMonth.month + step);
    final trendValue = trend.valueAt((monthly.length - 1 + step).toDouble());
    final seasonalIndex = seasonalIndices[forecastMonth.month] ?? 1;
    final forecastY = (trendValue * seasonalIndex).clamp(0.0, double.infinity);
    final forecastX = forecastMonth.difference(startDate).inDays.toDouble();
    if (forecastX <= result.last.x || forecastY.isNaN || forecastY.isInfinite) {
      return const [];
    }
    result.add(FlSpot(forecastX, forecastY));
  }
  return result;
}

Map<int, double> _centeredMovingAverages(
  List<_MonthlyPoint> monthly, {
  required int seasonLength,
}) {
  final simpleAverages = <double>[];
  for (var start = 0; start + seasonLength <= monthly.length; start++) {
    final window = monthly.sublist(start, start + seasonLength);
    simpleAverages.add(
      window.fold<double>(0, (sum, point) => sum + point.value) / seasonLength,
    );
  }

  final centered = <int, double>{};
  for (var i = 0; i + 1 < simpleAverages.length; i++) {
    final monthIndex = i + seasonLength ~/ 2;
    centered[monthIndex] = (simpleAverages[i] + simpleAverages[i + 1]) / 2;
  }
  return centered;
}

List<_MonthlyPoint> _monthlyPoints(List<FlSpot> source, DateTime startDate) {
  final valuesByMonth = <DateTime, List<double>>{};
  for (final spot in source) {
    final date = startDate.add(Duration(days: spot.x.round()));
    final month = DateTime(date.year, date.month);
    valuesByMonth.putIfAbsent(month, () => []).add(spot.y);
  }

  final points = valuesByMonth.entries.map((entry) {
    final values = entry.value;
    final average =
        values.fold<double>(0, (sum, value) => sum + value) / values.length;
    return _MonthlyPoint(entry.key, average);
  }).toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  return points;
}

_LinearTrend? _linearTrend(List<_TrendPoint> points) {
  final count = points.length;
  final sumX = points.fold<double>(0, (sum, point) => sum + point.x);
  final sumY = points.fold<double>(0, (sum, point) => sum + point.y);
  final sumXY = points.fold<double>(0, (sum, point) => sum + point.x * point.y);
  final sumX2 = points.fold<double>(0, (sum, point) => sum + point.x * point.x);
  final denominator = count * sumX2 - sumX * sumX;
  if (denominator == 0) {
    return null;
  }

  final slope = (count * sumXY - sumX * sumY) / denominator;
  final intercept = (sumY - slope * sumX) / count;
  return _LinearTrend(intercept, slope);
}

class _MonthlyPoint {
  const _MonthlyPoint(this.date, this.value);

  final DateTime date;
  final double value;
}

class _TrendPoint {
  const _TrendPoint(this.x, this.y);

  final double x;
  final double y;
}

class _LinearTrend {
  const _LinearTrend(this.intercept, this.slope);

  final double intercept;
  final double slope;

  double valueAt(double x) => intercept + slope * x;
}

double _intervalFor(double maxX) {
  if (maxX <= 10) {
    return 1;
  }
  if (maxX <= 45) {
    return 7;
  }
  if (maxX <= 120) {
    return 14;
  }
  if (maxX <= 240) {
    return 60;
  }
  if (maxX <= 540) {
    return 120;
  }
  return 180;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

class _HistoryCard extends StatefulWidget {
  const _HistoryCard({
    required this.results,
    required this.fromDate,
    required this.toDate,
    required this.evaluator,
    required this.profile,
    required this.onPickRange,
    required this.onClearRange,
    required this.onEdit,
    required this.onDelete,
  });

  final List<LabResult> results;
  final DateTime? fromDate;
  final DateTime? toDate;
  final LabEvaluator evaluator;
  final dynamic profile;
  final VoidCallback onPickRange;
  final VoidCallback onClearRange;
  final ValueChanged<LabResult> onEdit;
  final ValueChanged<LabResult> onDelete;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  static const _pageSize = 10;

  var _page = 0;

  @override
  void didUpdateWidget(covariant _HistoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromDate != widget.fromDate ||
        oldWidget.toDate != widget.toDate) {
      _page = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredResults();
    final totalPages =
        filtered.isEmpty ? 1 : ((filtered.length - 1) ~/ _pageSize) + 1;
    if (_page >= totalPages) {
      _page = totalPages - 1;
    }
    final start = _page * _pageSize;
    final end = (start + _pageSize) > filtered.length
        ? filtered.length
        : start + _pageSize;
    final pageItems = filtered.sublist(start, end);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'История',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Фильтр по датам',
                onPressed: widget.onPickRange,
                icon: const Icon(Icons.date_range_outlined),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _HistoryFilterBar(
            fromDate: widget.fromDate,
            toDate: widget.toDate,
            total: filtered.length,
            onPickRange: widget.onPickRange,
            onClear: widget.onClearRange,
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.results.isEmpty)
            Text(
              'Пока нет записей.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            )
          else if (filtered.isEmpty)
            Text(
              'За выбранный период записей нет.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            )
          else
            for (final result in pageItems) ...[
              _LabHistoryTile(
                result: result,
                evaluator: widget.evaluator,
                profile: widget.profile,
                onEdit: () => widget.onEdit(result),
                onDelete: () => widget.onDelete(result),
              ),
              if (result != pageItems.last)
                const Divider(height: AppSpacing.xl),
            ],
          if (filtered.length > _pageSize) ...[
            const SizedBox(height: AppSpacing.md),
            _HistoryPager(
              page: _page,
              totalPages: totalPages,
              onPrevious: _page == 0 ? null : () => setState(() => _page--),
              onNext: _page >= totalPages - 1
                  ? null
                  : () => setState(() => _page++),
            ),
          ],
        ],
      ),
    );
  }

  List<LabResult> _filteredResults() {
    final from = widget.fromDate == null ? null : _dateOnly(widget.fromDate!);
    final to = widget.toDate == null ? null : _dateOnly(widget.toDate!);
    return widget.results.where((result) {
      final date = _dateOnly(result.date);
      if (from != null && date.isBefore(from)) {
        return false;
      }
      if (to != null && date.isAfter(to)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

class _HistoryFilterBar extends StatelessWidget {
  const _HistoryFilterBar({
    required this.fromDate,
    required this.toDate,
    required this.total,
    required this.onPickRange,
    required this.onClear,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final int total;
  final VoidCallback onPickRange;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasRange = fromDate != null && toDate != null;
    final label = hasRange
        ? '${DateFormat('dd.MM.yy').format(fromDate!)} - ${DateFormat('dd.MM.yy').format(toDate!)}'
        : 'Все даты';

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ActionChip(
          avatar: const Icon(Icons.date_range_outlined, size: 18),
          label: Text(label),
          onPressed: onPickRange,
        ),
        StatusChip(
          label: '$total ${_recordsWord(total)}',
          color: AppColors.azure,
        ),
        if (hasRange)
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Сбросить'),
          ),
      ],
    );
  }
}

class _HistoryPager extends StatelessWidget {
  const _HistoryPager({
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Предыдущая страница',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Страница ${page + 1} из $totalPages',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Следующая страница',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _LabHistoryTile extends StatelessWidget {
  const _LabHistoryTile({
    required this.result,
    required this.evaluator,
    required this.profile,
    required this.onEdit,
    required this.onDelete,
  });

  final LabResult result;
  final LabEvaluator evaluator;
  final dynamic profile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('dd.MM.yyyy').format(result.date)),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  _ValueText(
                    text: 'ТТГ ${_formatValue(result.tsh)}',
                    status: evaluator.evaluateTsh(result.tsh, profile).status,
                  ),
                  _ValueText(
                    text: 'Т4 ${_formatValue(result.freeT4)}',
                    status:
                        evaluator.evaluateFreeT4(result.freeT4, profile).status,
                  ),
                  _ValueText(
                    text: 'Т3 ${_formatValue(result.freeT3)}',
                    status:
                        evaluator.evaluateFreeT3(result.freeT3, profile).status,
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Изменить',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Удалить',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}

class _ValueText extends StatelessWidget {
  const _ValueText({
    required this.text,
    required this.status,
  });

  final String text;
  final LabStatus status;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: switch (status) {
          LabStatus.low || LabStatus.high => AppColors.coral,
          LabStatus.normal => AppColors.mint,
          LabStatus.missing => AppColors.muted,
        },
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  const _ReferenceCard({
    required this.tshRange,
    required this.freeT4Range,
    required this.freeT3Range,
  });

  final ReferenceRange tshRange;
  final ReferenceRange freeT4Range;
  final ReferenceRange freeT3Range;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusChip(
            label: 'Настраиваемые диапазоны',
            color: AppColors.azureDeep,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ТТГ ${_formatValue(tshRange.min)}-${_formatValue(tshRange.max)} ${tshRange.unit}; '
            'Т4 ${_formatValue(freeT4Range.min)}-${_formatValue(freeT4Range.max)} ${freeT4Range.unit}; '
            'Т3 ${_formatValue(freeT3Range.min)}-${_formatValue(freeT3Range.max)} ${freeT3Range.unit}.',
          ),
        ],
      ),
    );
  }
}

class _LabEntry {
  const _LabEntry({
    required this.date,
    this.tsh,
    this.freeT4,
    this.freeT3,
    this.comment,
  });

  final DateTime date;
  final double? tsh;
  final double? freeT4;
  final double? freeT3;
  final String? comment;
}

double? _parseNumber(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.'));
}

DateTime? _parseDate(String value) {
  final parts = value.split('.');
  if (parts.length != 3) {
    return null;
  }
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) {
    return null;
  }
  return DateTime(year, month, day);
}

String _formatValue(double? value) {
  if (value == null) {
    return '-';
  }
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}

String _recordsWord(int value) {
  final mod10 = value % 10;
  final mod100 = value % 100;
  if (mod10 == 1 && mod100 != 11) {
    return 'запись';
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'записи';
  }
  return 'записей';
}
