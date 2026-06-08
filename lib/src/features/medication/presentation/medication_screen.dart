import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../domain/medication_plan.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/adaptive_picker.dart';
import '../../../shared/presentation/medication_time_chart.dart';
import '../../../shared/presentation/screen_frame.dart';
import '../../../shared/presentation/status_chip.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.watch(context);

    return ScreenFrame(
      title: 'Препараты',
      subtitle: 'Контроль назначений и ежедневной отметки приема.',
      actions: [
        IconButton(
          tooltip: 'Добавить препарат',
          onPressed: () => _showMedicationDialog(context),
          icon: const Icon(Icons.add),
        ),
      ],
      children: [
        _TodayDoseCard(
          medicationName: appState.primaryMedication?.name,
          dosage: appState.primaryMedication?.dosage,
          intakeTime: appState.primaryMedication?.intakeTime,
          streakDays: appState.medicationStreakDays,
          isTaken: appState.isPrimaryMedicationTakenToday,
          onTaken: appState.markPrimaryMedicationTakenToday,
          onBackdated: () => _showIntakeDialog(
            context,
            appState.primaryMedication?.id,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _MedicationPlansCard(
          plans: appState.medicationPlans,
          isTakenToday: appState.isMedicationTakenToday,
          onTaken: appState.markMedicationTakenToday,
          onBackdated: (id) => _showIntakeDialog(context, id),
          onEdit: (plan) => _showMedicationDialog(context, plan: plan),
          onChangeDose: (plan) => _showDoseChangeDialog(context, plan),
          onShowHistory: (plan) => _showDoseHistoryDialog(
            context,
            selectedPlan: plan,
            plans: appState.medicationPlans,
            onEdit: (course) => _showMedicationDialog(context, plan: course),
            onDelete: appState.deleteMedicationPlan,
          ),
          onDelete: appState.deleteMedicationPlan,
        ),
        const SizedBox(height: AppSpacing.lg),
        _MedicationIntakeChartCard(
          plans: appState.medicationPlans,
          intakes: appState.medicationIntakes,
        ),
        const SizedBox(height: AppSpacing.lg),
        _MedicationHistoryCard(takenDays: appState.takenMedicationDays),
      ],
    );
  }

  Future<void> _showMedicationDialog(
    BuildContext context, {
    MedicationPlan? plan,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => _MedicationDialog(initial: plan),
    );
  }

  Future<void> _showIntakeDialog(BuildContext context, String? planId) {
    if (planId == null) {
      return Future.value();
    }
    return showDialog<void>(
      context: context,
      builder: (context) => _MedicationIntakeDialog(planId: planId),
    );
  }

  Future<void> _showDoseHistoryDialog(
    BuildContext context, {
    required MedicationPlan selectedPlan,
    required List<MedicationPlan> plans,
    required ValueChanged<MedicationPlan> onEdit,
    required ValueChanged<String> onDelete,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => _DoseHistoryDialog(
        selectedPlan: selectedPlan,
        plans: plans,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  Future<void> _showDoseChangeDialog(
      BuildContext context, MedicationPlan plan) {
    return showDialog<void>(
      context: context,
      builder: (context) => _DoseChangeDialog(plan: plan),
    );
  }
}

class _TodayDoseCard extends StatelessWidget {
  const _TodayDoseCard({
    required this.medicationName,
    required this.dosage,
    required this.intakeTime,
    required this.streakDays,
    required this.isTaken,
    required this.onTaken,
    required this.onBackdated,
  });

  final String? medicationName;
  final String? dosage;
  final DateTime? intakeTime;
  final int streakDays;
  final bool isTaken;
  final VoidCallback onTaken;
  final VoidCallback onBackdated;

  @override
  Widget build(BuildContext context) {
    if (medicationName == null) {
      return const AppCard(
        child: Text(
            'Препарат пока не добавлен. Заполните данные на первом запуске.'),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusChip(
            label: isTaken ? 'Принято сегодня' : 'Ожидает приема',
            color: isTaken ? AppColors.mint : AppColors.amber,
            icon: isTaken ? Icons.check_circle_outline : Icons.schedule,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(medicationName!,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${dosage ?? 'Дозировка не указана'} в ${_formatTime(intakeTime)}',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.lg),
          _StreakPanel(streakDays: streakDays),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: isTaken ? null : onTaken,
                icon: const Icon(Icons.check),
                label: Text(isTaken ? 'Прием отмечен' : 'Отметить сегодня'),
              ),
              OutlinedButton.icon(
                onPressed: onBackdated,
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Другая дата'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakPanel extends StatelessWidget {
  const _StreakPanel({required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.azureSoft,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: AppColors.azureDeep),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streakDays == 0
                        ? 'Серия еще не началась'
                        : '$streakDays ${_daysWord(streakDays)} подряд',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Отмечайте прием каждый день, чтобы серия продолжалась.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationPlansCard extends StatelessWidget {
  const _MedicationPlansCard({
    required this.plans,
    required this.isTakenToday,
    required this.onTaken,
    required this.onBackdated,
    required this.onEdit,
    required this.onChangeDose,
    required this.onShowHistory,
    required this.onDelete,
  });

  final List<MedicationPlan> plans;
  final bool Function(String id) isTakenToday;
  final ValueChanged<String> onTaken;
  final ValueChanged<String> onBackdated;
  final ValueChanged<MedicationPlan> onEdit;
  final ValueChanged<MedicationPlan> onChangeDose;
  final ValueChanged<MedicationPlan> onShowHistory;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final groups = _groupMedicationPlans(plans);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Назначения', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (plans.isEmpty)
            Text(
              'Препараты пока не добавлены.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            )
          else
            for (final group in groups) ...[
              _MedicationCourseTile(
                plans: group,
                currentPlan: _currentPlanForGroup(group),
                isTakenToday: isTakenToday,
                onTaken: onTaken,
                onBackdated: onBackdated,
                onEdit: onEdit,
                onChangeDose: onChangeDose,
                onShowHistory: onShowHistory,
                onDelete: (plan) => _confirmDelete(context, plan),
              ),
              if (group != groups.last) const Divider(height: AppSpacing.xl),
            ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MedicationPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить препарат?'),
          content: Text('${plan.name} ${plan.dosage}'),
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
      onDelete(plan.id);
    }
  }
}

class _MedicationCourseTile extends StatelessWidget {
  const _MedicationCourseTile({
    required this.plans,
    required this.currentPlan,
    required this.isTakenToday,
    required this.onTaken,
    required this.onBackdated,
    required this.onEdit,
    required this.onChangeDose,
    required this.onShowHistory,
    required this.onDelete,
  });

  final List<MedicationPlan> plans;
  final MedicationPlan currentPlan;
  final bool Function(String id) isTakenToday;
  final ValueChanged<String> onTaken;
  final ValueChanged<String> onBackdated;
  final ValueChanged<MedicationPlan> onEdit;
  final ValueChanged<MedicationPlan> onChangeDose;
  final ValueChanged<MedicationPlan> onShowHistory;
  final ValueChanged<MedicationPlan> onDelete;

  @override
  Widget build(BuildContext context) {
    final isTaken = isTakenToday(currentPlan.id);
    final historyCount = plans.length;
    final dose = _doseFor(currentPlan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppRadii.card),
          onTap: () => onShowHistory(currentPlan),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentPlan.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${dose == null ? currentPlan.dosage : '${_formatDose(dose)} мкг'} в ${_formatTime(currentPlan.intakeTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_courseDateRange(currentPlan)} · $historyCount ${_recordsWord(historyCount)} в истории',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isTaken ? 'Принято сегодня' : 'Отметить прием',
                  onPressed: isTaken ? null : () => onTaken(currentPlan.id),
                  icon: Icon(
                    isTaken ? Icons.check_circle : Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: () => onChangeDose(currentPlan),
              icon: const Icon(Icons.swap_vert_outlined),
              label: const Text('Изменить дозу'),
            ),
            OutlinedButton.icon(
              onPressed: () => onShowHistory(currentPlan),
              icon: const Icon(Icons.show_chart_outlined),
              label: const Text('История доз'),
            ),
            IconButton(
              tooltip: 'Другая дата приема',
              onPressed: () => onBackdated(currentPlan.id),
              icon: const Icon(Icons.event_available_outlined),
            ),
            IconButton(
              tooltip: 'Настроить курс',
              onPressed: () => onEdit(currentPlan),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Удалить текущий курс',
              onPressed: () => onDelete(currentPlan),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ],
    );
  }
}

class _DoseHistoryDialog extends StatelessWidget {
  const _DoseHistoryDialog({
    required this.selectedPlan,
    required this.plans,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicationPlan selectedPlan;
  final List<MedicationPlan> plans;
  final ValueChanged<MedicationPlan> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final coursePlans = _plansForSameCourse(plans, selectedPlan);
    final hasDoseHistory = coursePlans.any((plan) => _doseFor(plan) != null);

    return AlertDialog(
      title: const Text('История дозировки'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedPlan.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Эти изменения учитываются в прогнозе анализов, если курс активен на дату наблюдения.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (hasDoseHistory)
              SizedBox(
                height: 220,
                child: _DoseHistoryChart(plans: coursePlans),
              )
            else
              Text(
                'Для графика укажите числовую дозу курса в мкг.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
            const SizedBox(height: AppSpacing.lg),
            ...coursePlans.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _DoseHistoryRow(
                  plan: plan,
                  onEdit: () {
                    Navigator.of(context).pop();
                    onEdit(plan);
                  },
                  onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Удалить запись курса?'),
                        content: Text(
                          '${plan.name}: ${_courseLabel(plan)}',
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
                      ),
                    );
                    if (confirmed == true) {
                      onDelete(plan.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}

class _DoseHistoryChart extends StatelessWidget {
  const _DoseHistoryChart({required this.plans});

  final List<MedicationPlan> plans;

  @override
  Widget build(BuildContext context) {
    final entries = plans
        .where((plan) => _doseFor(plan) != null)
        .map(
          (plan) => (
            date: _dateOnly(plan.startedAt ?? DateTime.now()),
            dose: _doseFor(plan)!,
          ),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final startDate = entries.first.date;
    final spots = entries
        .map(
          (entry) => FlSpot(
            entry.date.difference(startDate).inDays.toDouble(),
            entry.dose,
          ),
        )
        .toList();
    final maxX = spots.length == 1 ? 30.0 : spots.last.x.clamp(1.0, 3650.0);
    final minDose = entries.map((entry) => entry.dose).reduce(
          (a, b) => a < b ? a : b,
        );
    final maxDose = entries.map((entry) => entry.dose).reduce(
          (a, b) => a > b ? a : b,
        );
    final yPadding = ((maxDose - minDose).abs() * 0.18).clamp(5.0, 25.0);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: (minDose - yPadding).clamp(0, double.infinity),
        maxY: maxDose + yPadding,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: entries.length > 1,
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
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.round().toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: _doseChartInterval(maxX),
              getTitlesWidget: (value, meta) {
                if (_hideDoseBottomTitle(value, maxX)) {
                  return const SizedBox.shrink();
                }
                final date = startDate.add(Duration(days: value.round()));
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: SizedBox(
                    width: 46,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DateFormat(maxX > 120 ? 'MM.yy' : 'dd.MM').format(date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
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
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 14,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => AppColors.ink.withValues(alpha: 0.88),
            getTooltipItems: (items) {
              return items.map((item) {
                final date = startDate.add(Duration(days: item.x.round()));
                return LineTooltipItem(
                  '${_formatDose(item.y)} мкг\n${DateFormat('dd.MM.yyyy').format(date)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots.length == 1
                ? [spots.first, FlSpot(maxX, spots.first.y)]
                : spots,
            color: AppColors.azure,
            barWidth: 3,
            isCurved: false,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.azure.withValues(alpha: 0.20),
                  AppColors.azure.withValues(alpha: 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseHistoryRow extends StatelessWidget {
  const _DoseHistoryRow({
    required this.plan,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicationPlan plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dose = _doseFor(plan);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.azure,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                [
                  dose == null ? plan.dosage : '${_formatDose(dose)} мкг',
                  _courseDateRange(plan),
                ].join(' · '),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: 'Изменить запись',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Удалить запись',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoseChangeDialog extends StatefulWidget {
  const _DoseChangeDialog({required this.plan});

  final MedicationPlan plan;

  @override
  State<_DoseChangeDialog> createState() => _DoseChangeDialogState();
}

class _DoseChangeDialogState extends State<_DoseChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _doseController = TextEditingController(
    text: _doseFor(widget.plan) == null
        ? ''
        : _formatDose(_doseFor(widget.plan)!),
  );
  DateTime _startedAt = DateTime.now();

  @override
  void dispose() {
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDose = _doseFor(widget.plan);
    return AlertDialog(
      title: const Text('Изменить дозу'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.plan.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (currentDose != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Текущая доза: ${_formatDose(currentDose)} мкг',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _doseController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Новая доза',
                suffixText: 'мкг',
                prefixIcon: Icon(Icons.swap_vert_outlined),
              ),
              validator: (value) {
                final parsed =
                    double.tryParse((value ?? '').trim().replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Введите дозу';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('С какого дня'),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(_startedAt)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickStartDate,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Предыдущий курс будет закрыт днем раньше, а новая доза появится в истории и будет учитываться в прогнозе.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
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

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await pickAdaptiveDate(
      context: context,
      initialDate: _startedAt,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _startedAt = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final dose = double.parse(_doseController.text.trim().replaceAll(',', '.'));
    await AppScope.read(context).changeMedicationDose(
      plan: widget.plan,
      doseMcg: dose,
      startedAt: _startedAt,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _MedicationIntakeDialog extends StatefulWidget {
  const _MedicationIntakeDialog({required this.planId});

  final String planId;

  @override
  State<_MedicationIntakeDialog> createState() =>
      _MedicationIntakeDialogState();
}

class _MedicationIntakeDialogState extends State<_MedicationIntakeDialog> {
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    final isBackdated = !_isSameDay(_date, DateTime.now());

    return AlertDialog(
      title: const Text('Отметка приема'),
      content: Column(
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
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Время приема'),
            subtitle: Text(_time.format(context)),
            onTap: _pickTime,
          ),
          if (isBackdated) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Отметка задним числом сохранится в истории, но не увеличит серию приема.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted),
            ),
          ],
        ],
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
    final now = DateTime.now();
    final picked = await pickAdaptiveDate(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await pickAdaptiveTime(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _save() async {
    await AppScope.read(context).markMedicationTaken(
      medicationId: widget.planId,
      date: _date,
      takenAt: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _MedicationIntakeChartCard extends StatelessWidget {
  const _MedicationIntakeChartCard({
    required this.plans,
    required this.intakes,
  });

  final List<MedicationPlan> plans;
  final List<MedicationIntake> intakes;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const AppCard(
        child: Text('Добавьте препарат, чтобы отслеживать время приема.'),
      );
    }

    final plan = plans.first;
    final planIntakes =
        intakes.where((intake) => intake.planId == plan.id).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('График приема', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${plan.name}: фактическое время относительно ${_formatTime(plan.intakeTime)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 210,
            child: MedicationTimeChart(
              intakes: planIntakes,
              plannedTime: plan.intakeTime,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _TimeChartLegend(),
        ],
      ),
    );
  }
}

class _TimeChartLegend extends StatelessWidget {
  const _TimeChartLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _LegendItem(color: AppColors.azure, label: 'Фактическое время'),
        _LegendItem(color: AppColors.mint, label: 'Плановое время'),
        //_LegendItem(color: AppColors.borderStrong, label: 'Пропуск'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

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

class _MedicationDialog extends StatefulWidget {
  const _MedicationDialog({this.initial});

  final MedicationPlan? initial;

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _doseController = TextEditingController();
  DateTime _startedAt = DateTime.now();
  DateTime? _endedAt;
  TimeOfDay _intakeTime = const TimeOfDay(hour: 8, minute: 0);

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial == null) {
      return;
    }
    _nameController.text = initial.name;
    _dosageController.text = initial.dosage;
    _doseController.text =
        initial.doseMcg == null ? '' : _formatDose(initial.doseMcg!);
    _startedAt = initial.startedAt ?? DateTime.now();
    _endedAt = initial.endedAt;
    _intakeTime = TimeOfDay(
      hour: initial.intakeTime.hour,
      minute: initial.intakeTime.minute,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Курс препарата' : 'Новый препарат'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Например, Эутирокс',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _dosageController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Дозировка для отображения',
                  hintText: 'Например, 75 мкг',
                  prefixIcon: Icon(Icons.straighten_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _doseController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Доза курса',
                  suffixText: 'мкг',
                  prefixIcon: Icon(Icons.monitor_heart_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  final parsed =
                      double.tryParse(value.trim().replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return 'Введите число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_outlined),
                title: const Text('Время приема'),
                subtitle: Text(_intakeTime.format(context)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickTime,
              ),
              const Divider(height: AppSpacing.xl),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Начало курса'),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(_startedAt)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickStartDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.stop_circle_outlined),
                title: const Text('Окончание курса'),
                subtitle: Text(_endedAt == null
                    ? 'Не указано'
                    : DateFormat('dd.MM.yyyy').format(_endedAt!)),
                trailing: _endedAt == null
                    ? const Icon(Icons.chevron_right)
                    : IconButton(
                        tooltip: 'Очистить дату',
                        onPressed: () => setState(() => _endedAt = null),
                        icon: const Icon(Icons.close),
                      ),
                onTap: _pickEndDate,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(_isEditing ? 'Сохранить' : 'Добавить'),
        ),
      ],
    );
  }

  Future<void> _pickTime() async {
    final picked = await pickAdaptiveTime(
      context: context,
      initialTime: _intakeTime,
    );
    if (picked != null) {
      setState(() => _intakeTime = picked);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await pickAdaptiveDate(
      context: context,
      initialDate: _startedAt,
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() {
        _startedAt = picked;
        if (_endedAt != null && _endedAt!.isBefore(_startedAt)) {
          _endedAt = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await pickAdaptiveDate(
      context: context,
      initialDate: _endedAt ?? _startedAt,
      firstDate: _startedAt,
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() => _endedAt = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final dose = _doseController.text.trim().isEmpty
        ? null
        : double.tryParse(_doseController.text.trim().replaceAll(',', '.'));
    final intakeTime = DateTime(
      now.year,
      now.month,
      now.day,
      _intakeTime.hour,
      _intakeTime.minute,
    );
    final appState = AppScope.read(context);
    if (_isEditing) {
      await appState.updateMedicationPlan(
        id: widget.initial!.id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        doseMcg: dose,
        intakeTime: intakeTime,
        startedAt: _startedAt,
        endedAt: _endedAt,
        note: widget.initial!.note,
      );
    } else {
      await appState.addMedicationPlan(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        doseMcg: dose,
        intakeTime: intakeTime,
        startedAt: _startedAt,
        endedAt: _endedAt,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _MedicationHistoryCard extends StatelessWidget {
  const _MedicationHistoryCard({required this.takenDays});

  final Set<DateTime> takenDays;

  @override
  Widget build(BuildContext context) {
    final weekDays = _currentWeekDays();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Неделя', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in weekDays)
                _WeekDayMarker(
                  date: day,
                  isTaken: takenDays.contains(day),
                  isFuture: day.isAfter(_today()),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekDayMarker extends StatelessWidget {
  const _WeekDayMarker({
    required this.date,
    required this.isTaken,
    required this.isFuture,
  });

  final DateTime date;
  final bool isTaken;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_weekdayLabel(date),
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: 28,
          height: 28,
          child: _MarkerCircle(isTaken: isTaken, isFuture: isFuture),
        ),
      ],
    );
  }
}

class _MarkerCircle extends StatelessWidget {
  const _MarkerCircle({
    required this.isTaken,
    required this.isFuture,
  });

  final bool isTaken;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    if (isTaken) {
      return const CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.azureSoft,
        child: Icon(Icons.check, size: 16, color: AppColors.azureDeep),
      );
    }

    if (isFuture) {
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderStrong),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong),
      ),
    );
  }
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

List<DateTime> _currentWeekDays() {
  final today = _today();
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return [
    for (var i = 0; i < 7; i++) monday.add(Duration(days: i)),
  ];
}

List<List<MedicationPlan>> _groupMedicationPlans(List<MedicationPlan> plans) {
  final groupsByName = <String, List<MedicationPlan>>{};
  for (final plan in plans) {
    final key = plan.name.trim().toLowerCase();
    groupsByName.putIfAbsent(key, () => []).add(plan);
  }
  final groups = groupsByName.values.toList();
  for (final group in groups) {
    group.sort((a, b) {
      final aDate = a.startedAt ?? DateTime(1900);
      final bDate = b.startedAt ?? DateTime(1900);
      return aDate.compareTo(bDate);
    });
  }
  groups.sort((a, b) => a.first.name.compareTo(b.first.name));
  return groups;
}

MedicationPlan _currentPlanForGroup(List<MedicationPlan> plans) {
  final today = _today();
  final active = plans.where((plan) => plan.isActiveOn(today)).toList()
    ..sort((a, b) {
      final aDate = a.startedAt ?? DateTime(1900);
      final bDate = b.startedAt ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });
  if (active.isNotEmpty) {
    return active.first;
  }
  return plans.reduce((latest, plan) {
    final latestDate = latest.startedAt ?? DateTime(1900);
    final planDate = plan.startedAt ?? DateTime(1900);
    return planDate.isAfter(latestDate) ? plan : latest;
  });
}

String _weekdayLabel(DateTime date) {
  const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  return labels[date.weekday - 1];
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

String _daysWord(int value) {
  final mod10 = value % 10;
  final mod100 = value % 100;
  if (mod10 == 1 && mod100 != 11) {
    return 'день';
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'дня';
  }
  return 'дней';
}

String _formatTime(DateTime? value) {
  if (value == null) {
    return '08:00';
  }
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _courseDateRange(MedicationPlan plan) {
  final start = plan.startedAt == null
      ? 'начало не указано'
      : 'с ${DateFormat('dd.MM.yyyy').format(plan.startedAt!)}';
  final end = plan.endedAt == null
      ? 'по настоящее время'
      : 'до ${DateFormat('dd.MM.yyyy').format(plan.endedAt!)}';
  return '$start, $end';
}

double? _doseFor(MedicationPlan plan) {
  if (plan.doseMcg != null) {
    return plan.doseMcg;
  }
  final match =
      RegExp(r'(\d+(?:[,.]\d+)?)').firstMatch(plan.dosage.replaceAll(',', '.'));
  if (match == null) {
    return null;
  }
  return double.tryParse(match.group(1)!);
}

List<MedicationPlan> _plansForSameCourse(
  List<MedicationPlan> plans,
  MedicationPlan selectedPlan,
) {
  final normalizedName = selectedPlan.name.trim().toLowerCase();
  return plans
      .where((plan) => plan.name.trim().toLowerCase() == normalizedName)
      .toList()
    ..sort((a, b) {
      final aDate = a.startedAt ?? DateTime(1900);
      final bDate = b.startedAt ?? DateTime(1900);
      return aDate.compareTo(bDate);
    });
}

double _doseChartInterval(double maxX) {
  if (maxX <= 60) return 14;
  if (maxX <= 180) return 45;
  if (maxX <= 365) return 90;
  if (maxX <= 900) return 180;
  return 365;
}

bool _hideDoseBottomTitle(double value, double maxX) {
  if (value <= 0 || value >= maxX) {
    return false;
  }
  final interval = _doseChartInterval(maxX);
  final nearest = (value / interval).round() * interval;
  return (value - nearest).abs() > interval * 0.08;
}

String _courseLabel(MedicationPlan plan) {
  final dose =
      plan.doseMcg == null ? null : '${_formatDose(plan.doseMcg!)} мкг';
  return [if (dose != null) dose, _courseDateRange(plan)].join(' · ');
}

String _formatDose(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Заполните поле';
  }
  return null;
}
