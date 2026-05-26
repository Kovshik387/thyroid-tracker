import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../domain/doctor_visit.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/screen_frame.dart';
import '../../../shared/presentation/status_chip.dart';

class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.watch(context);

    return ScreenFrame(
      title: 'Врач',
      subtitle: 'История посещений и рекомендации специалиста.',
      actions: [
        IconButton(
          tooltip: 'Добавить визит',
          onPressed: () => _showVisitDialog(context),
          icon: const Icon(Icons.add),
        ),
      ],
      children: [
        if (appState.needsDoctorVisit) ...[
          const _VisitReminderCard(),
          const SizedBox(height: AppSpacing.lg),
        ],
        for (final visit in appState.doctorVisits) ...[
          _VisitCard(visit: visit),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }

  Future<void> _showVisitDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const _DoctorVisitDialog(),
    );
  }
}

class _VisitReminderCard extends StatelessWidget {
  const _VisitReminderCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_busy_outlined, color: AppColors.amber),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
                'Давно не было визита к врачу. Рекомендуется запланировать консультацию.'),
          ),
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit});

  final DoctorVisit visit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusChip(
            label: DateFormat('dd.MM.yyyy').format(visit.date),
            color: AppColors.azure,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            visit.specialization ?? visit.doctorName ?? 'Визит к врачу',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            visit.recommendations ?? 'Рекомендации не указаны.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _DoctorVisitDialog extends StatefulWidget {
  const _DoctorVisitDialog();

  @override
  State<_DoctorVisitDialog> createState() => _DoctorVisitDialogState();
}

class _DoctorVisitDialogState extends State<_DoctorVisitDialog> {
  final _specializationController = TextEditingController(text: 'Эндокринолог');
  final _recommendationsController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _specializationController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Посещение врача'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(DateFormat('dd.MM.yyyy').format(_date)),
              onTap: _pickDate,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _specializationController,
              decoration: const InputDecoration(labelText: 'Специализация'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _recommendationsController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Рекомендации'),
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 10),
      lastDate: DateTime(_date.year + 1),
      locale: const Locale('ru'),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() {
    AppScope.read(context).addDoctorVisit(
      date: _date,
      specialization: _specializationController.text.trim().isEmpty
          ? null
          : _specializationController.text.trim(),
      recommendations: _recommendationsController.text.trim().isEmpty
          ? null
          : _recommendationsController.text.trim(),
    );
    Navigator.of(context).pop();
  }
}
