import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../domain/medication_plan.dart';
import '../../../shared/presentation/app_card.dart';
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
        ),
        const SizedBox(height: AppSpacing.lg),
        _MedicationPlansCard(
          plans: appState.medicationPlans,
          isTakenToday: appState.isMedicationTakenToday,
          onTaken: appState.markMedicationTakenToday,
          onDelete: appState.deleteMedicationPlan,
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
}

class _TodayDoseCard extends StatelessWidget {
  const _TodayDoseCard({
    required this.medicationName,
    required this.dosage,
    required this.intakeTime,
    required this.streakDays,
    required this.isTaken,
    required this.onTaken,
  });

  final String? medicationName;
  final String? dosage;
  final DateTime? intakeTime;
  final int streakDays;
  final bool isTaken;
  final VoidCallback onTaken;

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
          FilledButton.icon(
            onPressed: isTaken ? null : onTaken,
            icon: const Icon(Icons.check),
            label: Text(isTaken ? 'Прием отмечен' : 'Отметить прием'),
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
    required this.onDelete,
  });

  final List<MedicationPlan> plans;
  final bool Function(String id) isTakenToday;
  final ValueChanged<String> onTaken;
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
    required this.onDelete,
  });

  final MedicationPlan plan;
  final bool isTaken;
  final VoidCallback onTaken;
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
          tooltip: 'Удалить',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
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

    return const SizedBox.shrink();
  }
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
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
