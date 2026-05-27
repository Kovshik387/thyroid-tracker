import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../domain/medication_plan.dart';
import '../../../shared/presentation/app_card.dart';
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

  Future<void> _showMedicationDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const _MedicationDialog(),
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
    required this.onDelete,
  });

  final List<MedicationPlan> plans;
  final bool Function(String id) isTakenToday;
  final ValueChanged<String> onTaken;
  final ValueChanged<String> onBackdated;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
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
            for (final plan in plans) ...[
              _MedicationPlanTile(
                plan: plan,
                isTaken: isTakenToday(plan.id),
                onTaken: () => onTaken(plan.id),
                onBackdated: () => onBackdated(plan.id),
                onDelete: () => _confirmDelete(context, plan),
              ),
              if (plan != plans.last) const Divider(height: AppSpacing.xl),
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

class _MedicationPlanTile extends StatelessWidget {
  const _MedicationPlanTile({
    required this.plan,
    required this.isTaken,
    required this.onTaken,
    required this.onBackdated,
    required this.onDelete,
  });

  final MedicationPlan plan;
  final bool isTaken;
  final VoidCallback onTaken;
  final VoidCallback onBackdated;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.name, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${plan.dosage} в ${_formatTime(plan.intakeTime)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: isTaken ? 'Принято сегодня' : 'Отметить прием',
          onPressed: isTaken ? null : onTaken,
          icon: Icon(isTaken ? Icons.check_circle : Icons.check_circle_outline),
        ),
        IconButton(
          tooltip: 'Отметить за другую дату',
          onPressed: onBackdated,
          icon: const Icon(Icons.event_available_outlined),
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      locale: const Locale('ru'),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
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
        _LegendItem(color: AppColors.borderStrong, label: 'Пропуск'),
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
  const _MedicationDialog();

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay _intakeTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый препарат'),
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
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Дозировка',
                  hintText: 'Например, 75 мкг',
                  prefixIcon: Icon(Icons.straighten_outlined),
                ),
                validator: _required,
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
          child: const Text('Добавить'),
        ),
      ],
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _intakeTime,
    );
    if (picked != null) {
      setState(() => _intakeTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    await AppScope.read(context).addMedicationPlan(
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      intakeTime: DateTime(
        now.year,
        now.month,
        now.day,
        _intakeTime.hour,
        _intakeTime.minute,
      ),
    );

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

List<DateTime> _currentWeekDays() {
  final today = _today();
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return [
    for (var i = 0; i < 7; i++) monday.add(Duration(days: i)),
  ];
}

String _weekdayLabel(DateTime date) {
  const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  return labels[date.weekday - 1];
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

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Заполните поле';
  }
  return null;
}
