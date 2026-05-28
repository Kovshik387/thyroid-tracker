import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../../../shared/presentation/adaptive_picker.dart';
import '../../../shared/presentation/adaptive_message.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/screen_frame.dart';
import '../../../shared/presentation/status_chip.dart';
import '../../../shared/presentation/trend_chart.dart';
import '../domain/weight_log.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  static const _pageSize = 10;

  DateTime? _fromDate;
  DateTime? _toDate;
  var _page = 0;

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.watch(context);
    final logs = appState.weightLogs.where(_isInsideRange).toList();
    final totalPages = logs.isEmpty ? 1 : ((logs.length - 1) ~/ _pageSize) + 1;
    if (_page >= totalPages) {
      _page = totalPages - 1;
    }
    final pageLogs = logs.skip(_page * _pageSize).take(_pageSize).toList();

    return ScreenFrame(
      title: 'Вес',
      subtitle: 'Отмечайте изменения веса и смотрите динамику без прогноза.',
      actions: [
        IconButton(
          tooltip: 'Добавить вес',
          onPressed: () => _showWeightDialog(context),
          icon: const Icon(Icons.add),
        ),
      ],
      children: [
        if (appState.weightLogs.isEmpty)
          const _EmptyWeightCard()
        else ...[
          TrendChartCard(
            title: 'Динамика веса',
            points: logs
                .map(
                  (log) => TrendPoint(
                    date: log.date,
                    value: log.weightKg,
                  ),
                )
                .toList(),
            valueSuffix: 'кг',
            lineColor: AppColors.mint,
            emptyText: 'Добавьте хотя бы две записи веса.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _HistoryFilterCard(
            fromDate: _fromDate,
            toDate: _toDate,
            total: logs.length,
            onPickFrom: () => _pickRangeDate(isFrom: true),
            onPickTo: () => _pickRangeDate(isFrom: false),
            onReset: _resetRange,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (pageLogs.isEmpty)
            const AppCard(child: Text('В выбранном периоде записей нет.'))
          else
            for (final log in pageLogs) ...[
              _WeightLogCard(
                log: log,
                onEdit: () => _showWeightDialog(context, log: log),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          if (logs.length > _pageSize)
            _PagerCard(
              page: _page,
              totalPages: totalPages,
              onPrevious: _page == 0 ? null : () => setState(() => _page--),
              onNext: _page >= totalPages - 1
                  ? null
                  : () => setState(() => _page++),
            ),
        ],
      ],
    );
  }

  bool _isInsideRange(WeightLog log) {
    final date = DateTime(log.date.year, log.date.month, log.date.day);
    final from = _fromDate;
    final to = _toDate;
    if (from != null && date.isBefore(from)) {
      return false;
    }
    if (to != null && date.isAfter(to)) {
      return false;
    }
    return true;
  }

  Future<void> _pickRangeDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initialDate = isFrom
        ? _fromDate ?? DateTime(now.year, now.month - 1, now.day)
        : _toDate ?? now;
    final picked = await pickAdaptiveDate(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isFrom) {
        _fromDate = DateTime(picked.year, picked.month, picked.day);
      } else {
        _toDate = DateTime(picked.year, picked.month, picked.day);
      }
      _page = 0;
    });
  }

  void _resetRange() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _page = 0;
    });
  }

  Future<void> _showWeightDialog(BuildContext context, {WeightLog? log}) {
    return showDialog<void>(
      context: context,
      builder: (context) => _WeightDialog(log: log),
    );
  }
}

class _HistoryFilterCard extends StatelessWidget {
  const _HistoryFilterCard({
    required this.fromDate,
    required this.toDate,
    required this.total,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onReset,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final int total;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('История', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Записей: $total',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPickFrom,
                  child: Text(_dateLabel('От', fromDate)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: onPickTo,
                  child: Text(_dateLabel('До', toDate)),
                ),
              ),
              IconButton(
                tooltip: 'Сбросить период',
                onPressed: onReset,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PagerCard extends StatelessWidget {
  const _PagerCard({
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
    return AppCard(
      child: Row(
        children: [
          IconButton(
            tooltip: 'Предыдущая страница',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Center(child: Text('Страница ${page + 1} из $totalPages')),
          ),
          IconButton(
            tooltip: 'Следующая страница',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

String _dateLabel(String prefix, DateTime? value) {
  return value == null
      ? prefix
      : '$prefix ${DateFormat('dd.MM.yy').format(value)}';
}

class _EmptyWeightCard extends StatelessWidget {
  const _EmptyWeightCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.monitor_weight_outlined, color: AppColors.azure),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text('Добавьте первую запись веса, чтобы увидеть график.'),
          ),
        ],
      ),
    );
  }
}

class _WeightLogCard extends StatelessWidget {
  const _WeightLogCard({
    required this.log,
    required this.onEdit,
  });

  final WeightLog log;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          StatusChip(
            label: DateFormat('dd.MM.yyyy').format(log.date),
            color: AppColors.mint,
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_format(log.weightKg)} кг',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (log.comment != null && log.comment!.trim().isNotEmpty)
                  Text(
                    log.comment!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.muted),
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
            onPressed: () => AppScope.read(context).deleteWeightLog(log.id),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _WeightDialog extends StatefulWidget {
  const _WeightDialog({this.log});

  final WeightLog? log;

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  DateTime _date = DateTime.now();
  final _weightController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final log = widget.log;
    if (log == null) {
      return;
    }
    _date = log.date;
    _weightController.text = _format(log.weightKg);
    _commentController.text = log.comment ?? '';
  }

  @override
  void dispose() {
    _weightController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.log == null ? 'Запись веса' : 'Изменить вес'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Дата'),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(_date)),
              onTap: _pickDate,
            ),
            TextField(
              controller: _weightController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Вес',
                suffixText: 'кг',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _commentController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Комментарий',
                hintText: 'Например, после отпуска, новый режим',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await pickAdaptiveDate(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 3),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() {
    final value = double.tryParse(_weightController.text.replaceAll(',', '.'));
    if (value == null || value <= 0) {
      showAdaptiveMessage(context, 'Введите вес числом');
      return;
    }

    final appState = AppScope.read(context);
    final log = widget.log;
    final date = DateTime(_date.year, _date.month, _date.day);
    final comment = _commentController.text.trim().isEmpty
        ? null
        : _commentController.text.trim();
    if (log == null) {
      appState.addWeightLog(
        date: date,
        weightKg: value,
        comment: comment,
      );
    } else {
      appState.updateWeightLog(
        id: log.id,
        date: date,
        weightKg: value,
        comment: comment,
      );
    }
    Navigator.of(context).pop();
  }
}

String _format(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}
