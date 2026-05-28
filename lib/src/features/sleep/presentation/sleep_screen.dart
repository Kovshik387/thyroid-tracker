import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../domain/sleep_log.dart';
import '../../../shared/presentation/adaptive_picker.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/screen_frame.dart';
import '../../../shared/presentation/status_chip.dart';
import '../../../shared/presentation/trend_chart.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  static const _pageSize = 10;

  DateTime? _fromDate;
  DateTime? _toDate;
  var _page = 0;

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.watch(context);
    final filteredLogs = appState.sleepLogs.where(_isInsideRange).toList();
    final totalPages =
        filteredLogs.isEmpty ? 1 : ((filteredLogs.length - 1) ~/ _pageSize) + 1;
    if (_page >= totalPages) {
      _page = totalPages - 1;
    }
    final pageLogs =
        filteredLogs.skip(_page * _pageSize).take(_pageSize).toList();

    return ScreenFrame(
      title: 'Сон',
      subtitle:
          'Отмечайте сон, чтобы позже сопоставлять его с самочувствием и анализами.',
      actions: [
        IconButton(
          tooltip: 'Добавить сон',
          onPressed: () => _showSleepDialog(context),
          icon: const Icon(Icons.add),
        ),
      ],
      children: [
        if (appState.sleepLogs.isEmpty)
          const _EmptySleepCard()
        else ...[
          TrendChartCard(
            title: 'Динамика сна',
            points: filteredLogs
                .where((log) => log.duration != null)
                .map(
                  (log) => TrendPoint(
                    date: log.date,
                    value: log.duration!.inMinutes / 60,
                  ),
                )
                .toList(),
            valueSuffix: 'ч',
            lineColor: AppColors.aqua,
            emptyText: 'Добавьте хотя бы две записи с временем сна.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _HistoryFilterCard(
            fromDate: _fromDate,
            toDate: _toDate,
            total: filteredLogs.length,
            onPickFrom: () => _pickRangeDate(isFrom: true),
            onPickTo: () => _pickRangeDate(isFrom: false),
            onReset: _resetRange,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (pageLogs.isEmpty)
            const AppCard(child: Text('В выбранном периоде записей нет.'))
          else
            for (final log in pageLogs) ...[
              _SleepLogCard(
                log: log,
                onEdit: () => _showSleepDialog(context, log: log),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          if (filteredLogs.length > _pageSize)
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

  bool _isInsideRange(SleepLog log) {
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

  Future<void> _showSleepDialog(BuildContext context, {SleepLog? log}) {
    return showDialog<void>(
      context: context,
      builder: (context) => _SleepDialog(log: log),
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

class _EmptySleepCard extends StatelessWidget {
  const _EmptySleepCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.bedtime_outlined, color: AppColors.azure),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child:
                Text('Добавьте первую запись сна: время, качество и заметку.'),
          ),
        ],
      ),
    );
  }
}

class _SleepLogCard extends StatelessWidget {
  const _SleepLogCard({
    required this.log,
    required this.onEdit,
  });

  final SleepLog log;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(
                label: DateFormat('dd.MM.yyyy').format(log.date),
                color: AppColors.azure,
                icon: Icons.calendar_today_outlined,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Изменить',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Удалить',
                onPressed: () => AppScope.read(context).deleteSleepLog(log.id),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _sleepTitle(log),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Качество: ${log.quality == null ? '-' : '${log.quality}/5'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
          ),
          if (log.comment != null && log.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(log.comment!),
          ],
        ],
      ),
    );
  }
}

class _SleepDialog extends StatefulWidget {
  const _SleepDialog({this.log});

  final SleepLog? log;

  @override
  State<_SleepDialog> createState() => _SleepDialogState();
}

class _SleepDialogState extends State<_SleepDialog> {
  DateTime _date = DateTime.now();
  TimeOfDay _sleepStart = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _sleepEnd = const TimeOfDay(hour: 7, minute: 0);
  double _quality = 4;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final log = widget.log;
    if (log == null) {
      return;
    }
    _date = log.date;
    final start = log.sleepStart;
    final end = log.sleepEnd;
    if (start != null) {
      _sleepStart = TimeOfDay(hour: start.hour, minute: start.minute);
    }
    if (end != null) {
      _sleepEnd = TimeOfDay(hour: end.hour, minute: end.minute);
    }
    _quality = (log.quality ?? 4).toDouble();
    _commentController.text = log.comment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.log == null ? 'Запись сна' : 'Изменить сон'),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.nights_stay_outlined),
              title: const Text('Легли'),
              subtitle: Text(_sleepStart.format(context)),
              onTap: () => _pickTime(isStart: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('Проснулись'),
              subtitle: Text(_sleepEnd.format(context)),
              onTap: () => _pickTime(isStart: false),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Expanded(child: Text('Качество сна')),
                Text('${_quality.round()}/5'),
              ],
            ),
            Slider(
              value: _quality,
              min: 1,
              max: 5,
              divisions: 4,
              label: _quality.round().toString(),
              onChanged: (value) => setState(() => _quality = value),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _commentController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Комментарий',
                hintText: 'Например, просыпался ночью, стресс, кофе поздно',
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
      firstDate: DateTime(_date.year - 2),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await pickAdaptiveTime(
      context: context,
      initialTime: isStart ? _sleepStart : _sleepEnd,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isStart) {
        _sleepStart = picked;
      } else {
        _sleepEnd = picked;
      }
    });
  }

  void _save() {
    final appState = AppScope.read(context);
    final log = widget.log;
    final date = DateTime(_date.year, _date.month, _date.day);
    final comment = _commentController.text.trim().isEmpty
        ? null
        : _commentController.text.trim();
    if (log == null) {
      appState.addSleepLog(
        date: date,
        sleepStart: _withTime(_date, _sleepStart),
        sleepEnd: _withTime(_date, _sleepEnd),
        quality: _quality.round(),
        comment: comment,
      );
    } else {
      appState.updateSleepLog(
        id: log.id,
        date: date,
        sleepStart: _withTime(_date, _sleepStart),
        sleepEnd: _withTime(_date, _sleepEnd),
        quality: _quality.round(),
        comment: comment,
      );
    }
    Navigator.of(context).pop();
  }
}

DateTime _withTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

String _sleepTitle(SleepLog log) {
  final start = log.sleepStart;
  final end = log.sleepEnd;
  final duration = log.duration;
  final range = start == null || end == null
      ? 'Время не указано'
      : '${_formatTime(start)} - ${_formatTime(end)}';
  if (duration == null) {
    return range;
  }
  return '$range · ${duration.inHours}ч ${duration.inMinutes.remainder(60)}м';
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
