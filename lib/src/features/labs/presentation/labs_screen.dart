import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../../../core/domain/reference_range.dart';
import '../../medication/domain/medication_plan.dart';
import '../domain/lab_evaluator.dart';
import '../domain/lab_forecast.dart';
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
          medicationPlans: appState.medicationPlans,
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
    _tshController.text = initial.tsh == null
        ? ''
        : _formatMetricValue(initial.tsh, _ChartMetric.tsh);
    _freeT4Controller.text = initial.freeT4 == null
        ? ''
        : _formatMetricValue(initial.freeT4, _ChartMetric.freeT4);
    _freeT3Controller.text = initial.freeT3 == null
        ? ''
        : _formatMetricValue(initial.freeT3, _ChartMetric.freeT3);
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
    required this.medicationPlans,
  });

  final List<LabResult> results;
  final bool hasAnyResults;
  final ReferenceRange tshRange;
  final ReferenceRange freeT4Range;
  final ReferenceRange freeT3Range;
  final List<MedicationPlan> medicationPlans;

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
      medicationPlans: widget.medicationPlans,
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
                final mediaQuery = MediaQuery.of(context);
                final prefersBoldText = mediaQuery.boldText;
                final bottomInterval = chartData.bottomTitleInterval(
                  maxLabels: compact
                      ? (prefersBoldText ? 3 : 4)
                      : (prefersBoldText ? 5 : 6),
                );
                return SizedBox(
                  height: compact ? 250 : 300,
                  child: MediaQuery(
                    data: mediaQuery.copyWith(
                      boldText: false,
                      textScaler: TextScaler.noScaling,
                    ),
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
                                  _formatAxisValue(value, _metric),
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: compact ? 42 : 36,
                              interval: bottomInterval,
                              getTitlesWidget: (value, meta) {
                                if (chartData.shouldHideBottomTitle(
                                  value,
                                  interval: bottomInterval,
                                )) {
                                  return const SizedBox.shrink();
                                }
                                return _BottomDateLabel(
                                  date: chartData.dateForX(value),
                                  compact: compact,
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
                                if (item.barIndex == 1 && item.spotIndex == 0) {
                                  return null;
                                }
                                final date = chartData.dateForX(item.x);
                                final isForecast = item.barIndex == 1;
                                return LineTooltipItem(
                                  '${isForecast ? 'Прогноз\n' : ''}${_formatMetricValue(item.y, _metric)} ${range.unit}\n${DateFormat('dd.MM.yyyy').format(date)}',
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
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpacing.md),
          _ChartTextScope(
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _LegendItem(color: AppColors.azure, label: _metric.label),
                const _LegendItem(
                  color: AppColors.mint,
                  label: 'Границы нормы',
                ),
                if (chartData.forecastSpots.isNotEmpty)
                  const _LegendItem(color: AppColors.amber, label: 'Прогноз'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ChartTextScope(
            child: Text(
              'Норма: ${_formatMetricValue(range.min, _metric)}-${_formatMetricValue(range.max, _metric)} ${range.unit}.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    height: 1.35,
                  ),
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
    required this.contentMaxX,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.xInterval,
    required this.spots,
    required this.forecastSpots,
    required this.forecastNote,
    this.medicationNote,
  });

  final DateTime startDate;
  final double contentMaxX;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double xInterval;
  final List<FlSpot> spots;
  final List<FlSpot> forecastSpots;
  final String forecastNote;
  final String? medicationNote;

  factory _SingleMetricChartData.fromResults(
    List<LabResult> results, {
    required _ChartMetric metric,
    required ReferenceRange range,
    required List<MedicationPlan> medicationPlans,
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
        contentMaxX: 1,
        minX: 0,
        maxX: 1,
        minY: range.min - 1,
        maxY: range.max + 1,
        xInterval: 1,
        spots: const [],
        forecastSpots: const [],
        forecastNote: '',
      );
    }

    final forecast = _forecastSpots(
      rawSpots,
      metric: metric,
      medicationPlans: medicationPlans,
      startDate: start,
    );
    final forecastSpots =
        forecast.points.map((point) => FlSpot(point.day, point.value)).toList();
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
    final contentMaxX = [
      dataMaxX,
      if (forecastSpots.isNotEmpty) forecastSpots.last.x,
      1.0,
    ].reduce((a, b) => a > b ? a : b);
    final maxX = contentMaxX + _rightPaddingFor(contentMaxX);

    return _SingleMetricChartData(
      startDate: start,
      contentMaxX: contentMaxX,
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      xInterval: _intervalFor(maxX),
      spots: _sampleSpots(rawSpots, maxPoints: 48),
      forecastSpots: forecastSpots,
      forecastNote: forecast.methodNote,
      medicationNote: forecast.medicationNote,
    );
  }

  DateTime dateForX(double x) {
    return startDate.add(Duration(days: x.round()));
  }

  double bottomTitleInterval({required int maxLabels}) {
    return _intervalFor(contentMaxX, maxLabels: maxLabels);
  }

  bool shouldHideBottomTitle(
    double value, {
    required double interval,
  }) {
    const edgeTolerance = 0.001;
    if (value > contentMaxX + edgeTolerance) {
      return true;
    }
    if (value <= minX + edgeTolerance || value >= contentMaxX - edgeTolerance) {
      return false;
    }
    return value - minX < interval * 0.45 ||
        contentMaxX - value < interval * 0.72;
  }
}

class _BottomDateLabel extends StatelessWidget {
  const _BottomDateLabel({
    required this.date,
    required this.compact,
    required this.isLongRange,
  });

  final DateTime date;
  final bool compact;
  final bool isLongRange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: SizedBox(
        width: compact ? 42 : 52,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            DateFormat(isLongRange ? 'MM.yy' : 'dd.MM').format(date),
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _ChartTextScope extends StatelessWidget {
  const _ChartTextScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        boldText: false,
        textScaler: TextScaler.noScaling,
      ),
      child: child,
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
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
        ),
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

LabForecastResult _forecastSpots(
  List<FlSpot> source, {
  required _ChartMetric metric,
  required List<MedicationPlan> medicationPlans,
  required DateTime startDate,
}) {
  return LabForecastEngine(
    forecastHorizonDays: _forecastHorizonDaysForChart(source),
  ).predict(
    source
        .map((spot) => LabForecastSample(day: spot.x, value: spot.y))
        .toList(),
    metric: switch (metric) {
      _ChartMetric.tsh => LabForecastMetric.tsh,
      _ChartMetric.freeT4 => LabForecastMetric.freeT4,
      _ChartMetric.freeT3 => LabForecastMetric.freeT3,
    },
    medicationPlans: medicationPlans,
    startDate: startDate,
  );
}

int _forecastHorizonDaysForChart(List<FlSpot> source) {
  return 56;
}

double _intervalFor(double maxX, {int maxLabels = 6}) {
  final labels = maxLabels.clamp(2, 8);
  final target = maxX <= 0 ? 1 : maxX / (labels - 1);
  const candidates = <double>[
    1,
    2,
    3,
    7,
    14,
    21,
    30,
    45,
    60,
    90,
    120,
    180,
    365,
  ];
  for (final candidate in candidates) {
    if (candidate >= target) {
      return candidate;
    }
  }
  return candidates.last;
}

double _rightPaddingFor(double maxX) {
  if (maxX <= 14) {
    return 2;
  }
  if (maxX <= 60) {
    return 5;
  }
  if (maxX <= 180) {
    return 10;
  }
  return (maxX * 0.06).clamp(14.0, 45.0);
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
                    text:
                        'ТТГ ${_formatMetricValue(result.tsh, _ChartMetric.tsh)}',
                    status: evaluator.evaluateTsh(result.tsh, profile).status,
                  ),
                  _ValueText(
                    text:
                        'Т4 ${_formatMetricValue(result.freeT4, _ChartMetric.freeT4)}',
                    status:
                        evaluator.evaluateFreeT4(result.freeT4, profile).status,
                  ),
                  _ValueText(
                    text:
                        'Т3 ${_formatMetricValue(result.freeT3, _ChartMetric.freeT3)}',
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
            'ТТГ ${_formatMetricValue(tshRange.min, _ChartMetric.tsh)}-${_formatMetricValue(tshRange.max, _ChartMetric.tsh)} ${tshRange.unit}; '
            'Т4 ${_formatMetricValue(freeT4Range.min, _ChartMetric.freeT4)}-${_formatMetricValue(freeT4Range.max, _ChartMetric.freeT4)} ${freeT4Range.unit}; '
            'Т3 ${_formatMetricValue(freeT3Range.min, _ChartMetric.freeT3)}-${_formatMetricValue(freeT3Range.max, _ChartMetric.freeT3)} ${freeT3Range.unit}.',
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

String _formatMetricValue(double? value, _ChartMetric metric) {
  if (value == null) {
    return '-';
  }
  final decimals = metric == _ChartMetric.tsh ? 3 : 1;
  return _trimTrailingZeros(value.toStringAsFixed(decimals));
}

String _formatAxisValue(double value, _ChartMetric metric) {
  if (metric == _ChartMetric.tsh && value > 0 && value < 1) {
    return _trimTrailingZeros(value.toStringAsFixed(3));
  }
  return _trimTrailingZeros(value.toStringAsFixed(1));
}

String _trimTrailingZeros(String value) {
  if (!value.contains('.')) {
    return value;
  }
  return value
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
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
