import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app_router.dart';
import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../../../features/labs/domain/lab_result.dart';
import '../../../features/labs/domain/lab_evaluator.dart';
import '../../../features/medication/domain/medication_plan.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/adaptive_picker.dart';
import '../../../shared/presentation/medication_time_chart.dart';
import '../../../shared/presentation/screen_frame.dart';
import '../../../shared/presentation/status_chip.dart';
import '../../profile/domain/user_profile.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.watch(context);

    return ScreenFrame(
      title: 'Сегодня',
      subtitle: 'Личный дневник контроля гипотиреоза.',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: _ProfileAvatar(
            name: appState.userProfile?.name,
            avatarData: appState.userProfile?.avatarData,
          ),
        ),
      ],
      children: [
        _MedicationTodayCard(
          medicationName: appState.primaryMedication?.name,
          dosage: appState.primaryMedication?.dosage,
          intakeTime: appState.primaryMedication?.intakeTime,
          isTaken: appState.isPrimaryMedicationTakenToday,
          onTakenAt: (takenAt) {
            final medication = appState.primaryMedication;
            if (medication == null) {
              return;
            }
            appState.markMedicationTaken(
              medicationId: medication.id,
              date: takenAt,
              takenAt: takenAt,
            );
          },
          intakes: appState.medicationIntakes,
          plannedTime: appState.primaryMedication?.intakeTime,
        ),
        const SizedBox(height: AppSpacing.lg),
        _LatestLabsCard(
          result: appState.latestLab,
          evaluator: LabEvaluator(
            tshRange: appState.tshRange,
            freeT4Range: appState.freeT4Range,
            freeT3Range: appState.freeT3Range,
          ),
          profile: appState.userProfile,
        ),
        const SizedBox(height: AppSpacing.lg),
        _AttentionCard(
          needsLabControl: appState.needsLabControl,
          needsDoctorVisit: appState.needsDoctorVisit,
        ),
        const SizedBox(height: AppSpacing.lg),
        _QuickActionsCard(
          weightKg: appState.userProfile?.weightKg,
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    required this.avatarData,
  });

  final String? name;
  final String? avatarData;

  @override
  Widget build(BuildContext context) {
    final bytes = avatarData == null ? null : base64Decode(avatarData!);
    final initial = name == null || name!.trim().isEmpty
        ? '?'
        : name!.trim().characters.first.toUpperCase();

    return CircleAvatar(
      backgroundColor: AppColors.azureSoft,
      backgroundImage: bytes == null ? null : MemoryImage(bytes),
      child: bytes == null
          ? Text(
              initial,
              style: const TextStyle(
                color: AppColors.azureDeep,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}

class _MedicationTodayCard extends StatelessWidget {
  const _MedicationTodayCard({
    required this.medicationName,
    required this.dosage,
    required this.intakeTime,
    required this.isTaken,
    required this.onTakenAt,
    required this.intakes,
    required this.plannedTime,
  });

  final String? medicationName;
  final String? dosage;
  final DateTime? intakeTime;
  final bool isTaken;
  final ValueChanged<DateTime> onTakenAt;
  final List<MedicationIntake> intakes;
  final DateTime? plannedTime;

  @override
  Widget build(BuildContext context) {
    if (medicationName == null) {
      return const AppCard(
        child: Text(
            'Препарат пока не указан. Его можно добавить после первого запуска.'),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: () => _showMedicationChart(context, intakes, plannedTime),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, color: AppColors.azure),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  medicationName!,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                StatusChip(
                  label: _formatTime(intakeTime),
                  color: AppColors.azureDeep,
                  icon: Icons.schedule,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${dosage ?? 'Дозировка не указана'}, до завтрака',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: isTaken ? null : () => _pickIntakeTime(context),
              icon: Icon(
                  isTaken ? Icons.check_circle : Icons.radio_button_unchecked),
              label: Text(isTaken ? 'Принято сегодня' : 'Отметить прием'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickIntakeTime(BuildContext context) async {
    final now = DateTime.now();
    final picked = await pickAdaptiveTime(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (picked == null) {
      return;
    }
    onTakenAt(
      DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
    );
  }

  Future<void> _showMedicationChart(
    BuildContext context,
    List<MedicationIntake> intakes,
    DateTime? plannedTime,
  ) {
    if (plannedTime == null) {
      return Future.value();
    }

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('График приема'),
        content: SizedBox(
          width: 360,
          height: 260,
          child: MedicationTimeChart(
            intakes: intakes,
            plannedTime: plannedTime,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

class _LatestLabsCard extends StatelessWidget {
  const _LatestLabsCard({
    required this.result,
    required this.evaluator,
    required this.profile,
  });

  final LabResult? result;
  final LabEvaluator evaluator;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const AppCard(
        child:
            Text('Добавьте первый анализ, чтобы видеть последние показатели.'),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Последние анализы',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat('dd.MM.yyyy').format(result!.date),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'ТТГ',
                  value: _format(result!.tsh, decimals: 3),
                  unit: 'мМЕ/л',
                  status: evaluator.evaluateTsh(result!.tsh, profile).status,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricTile(
                  label: 'Т4 св.',
                  value: _format(result!.freeT4),
                  unit: 'пмоль/л',
                  status:
                      evaluator.evaluateFreeT4(result!.freeT4, profile).status,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricTile(
                  label: 'Т3 св.',
                  value: _format(result!.freeT3),
                  unit: 'пмоль/л',
                  status:
                      evaluator.evaluateFreeT3(result!.freeT3, profile).status,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          StatusChip(
            label: _summaryLabel(
              [
                evaluator.evaluateTsh(result!.tsh, profile).status,
                evaluator.evaluateFreeT4(result!.freeT4, profile).status,
                evaluator.evaluateFreeT3(result!.freeT3, profile).status,
              ],
            ),
            color: _summaryColor(
              [
                evaluator.evaluateTsh(result!.tsh, profile).status,
                evaluator.evaluateFreeT4(result!.freeT4, profile).status,
                evaluator.evaluateFreeT3(result!.freeT3, profile).status,
              ],
            ),
            icon: Icons.verified_outlined,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
  });

  final String label;
  final String value;
  final String unit;
  final LabStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _statusColor(status),
                  ),
            ),
            Text(
              unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.needsLabControl,
    required this.needsDoctorVisit,
  });

  final bool needsLabControl;
  final bool needsDoctorVisit;

  @override
  Widget build(BuildContext context) {
    final message = switch ((needsLabControl, needsDoctorVisit)) {
      (true, true) =>
        'Давно не было анализов и визита к врачу. Стоит запланировать контроль.',
      (true, false) =>
        'Давно не было анализов. Стоит обсудить повторный контроль с врачом.',
      (false, true) =>
        'Давно не было визита к врачу. Рекомендуется запланировать консультацию.',
      (false, false) =>
        'Контроль выглядит актуальным. Продолжайте вести дневник.',
    };

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_active_outlined,
              color: AppColors.amber),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Нужен контроль',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
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

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.weightKg});

  final double? weightKg;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Быстро добавить',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.bedtime_outlined,
                  title: 'Сон',
                  subtitle: 'Запись сна',
                  onTap: () => context.push(AppRoute.sleep.path),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Вес',
                  subtitle: weightKg == null
                      ? 'Не указан'
                      : '${_format(weightKg)} кг',
                  onTap: () => context.push(AppRoute.weight.path),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.azure),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _format(double? value, {int decimals = 1}) {
  if (value == null) {
    return '-';
  }
  final fixed = value.toStringAsFixed(decimals);
  if (!fixed.contains('.')) {
    return fixed;
  }
  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _summaryLabel(List<LabStatus> statuses) {
  final actualStatuses =
      statuses.where((status) => status != LabStatus.missing);
  if (actualStatuses.isEmpty) {
    return 'Нет значений';
  }
  return actualStatuses.every((status) => status == LabStatus.normal)
      ? 'В пределах диапазона'
      : 'Есть отклонения';
}

Color _summaryColor(List<LabStatus> statuses) {
  return statuses
          .any((status) => status == LabStatus.low || status == LabStatus.high)
      ? AppColors.coral
      : AppColors.mint;
}

Color _statusColor(LabStatus status) {
  return switch (status) {
    LabStatus.low || LabStatus.high => AppColors.coral,
    LabStatus.normal => AppColors.mint,
    LabStatus.missing => AppColors.muted,
  };
}

Color _statusBackground(LabStatus status) {
  return switch (status) {
    LabStatus.low || LabStatus.high => AppColors.coral.withValues(alpha: 0.10),
    LabStatus.normal => AppColors.mint.withValues(alpha: 0.10),
    LabStatus.missing => AppColors.surfaceTint,
  };
}

String _formatTime(DateTime? value) {
  if (value == null) {
    return '08:00';
  }
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
