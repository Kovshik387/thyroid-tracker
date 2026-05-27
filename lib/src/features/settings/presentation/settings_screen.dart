import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../../../core/domain/reference_range.dart';
import '../../../shared/presentation/date_input_formatter.dart';
import '../../../shared/presentation/screen_frame.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _labDaysController = TextEditingController();
  late final _doctorDaysController = TextEditingController();
  late final _tshMinController = TextEditingController();
  late final _tshMaxController = TextEditingController();
  late final _freeT4MinController = TextEditingController();
  late final _freeT4MaxController = TextEditingController();
  late final _freeT3MinController = TextEditingController();
  late final _freeT3MaxController = TextEditingController();
  late final _weightController = TextEditingController();
  late final _birthDateController = TextEditingController();

  var _didSeed = false;
  var _medicationNotifications = true;
  var _doctorNotifications = true;
  var _demoDataEnabled = false;
  var _demoSleepDataEnabled = false;
  var _demoWeightDataEnabled = false;
  var _demoMedicationDataEnabled = false;
  DateTime? _birthDate;
  TimeOfDay _intakeTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSeed) {
      return;
    }
    final appState = AppScope.watch(context);
    _labDaysController.text = appState.labControlDays.toString();
    _doctorDaysController.text = appState.doctorControlDays.toString();
    _medicationNotifications = appState.medicationNotificationsEnabled;
    _doctorNotifications = appState.doctorNotificationsEnabled;
    _demoDataEnabled = appState.demoDataEnabled;
    _demoSleepDataEnabled = appState.demoSleepDataEnabled;
    _demoWeightDataEnabled = appState.demoWeightDataEnabled;
    _demoMedicationDataEnabled = appState.demoMedicationDataEnabled;
    _birthDate = appState.userProfile?.birthDate;
    _birthDateController.text =
        _birthDate == null ? '' : DateFormat('dd.MM.yyyy').format(_birthDate!);
    final weight = appState.userProfile?.weightKg;
    _weightController.text = weight == null ? '' : _format(weight);
    final medicationTime = appState.primaryMedication?.intakeTime;
    if (medicationTime != null) {
      _intakeTime = TimeOfDay(
        hour: medicationTime.hour,
        minute: medicationTime.minute,
      );
    }
    _tshMinController.text = _format(appState.tshRange.min);
    _tshMaxController.text = _format(appState.tshRange.max);
    _freeT4MinController.text = _format(appState.freeT4Range.min);
    _freeT4MaxController.text = _format(appState.freeT4Range.max);
    _freeT3MinController.text = _format(appState.freeT3Range.min);
    _freeT3MaxController.text = _format(appState.freeT3Range.max);
    _didSeed = true;
  }

  @override
  void dispose() {
    _labDaysController.dispose();
    _doctorDaysController.dispose();
    _tshMinController.dispose();
    _tshMaxController.dispose();
    _freeT4MinController.dispose();
    _freeT4MaxController.dispose();
    _freeT3MinController.dispose();
    _freeT3MaxController.dispose();
    _weightController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'Настройки',
      children: [
        Column(
          children: [
            _SettingsSection(
              title: 'Профиль',
              children: [
                _DateTextField(
                  controller: _birthDateController,
                  label: 'Дата рождения',
                  helperText: _birthDate == null ? null : _ageText(_birthDate!),
                  icon: Icons.cake_outlined,
                  onPick: _pickBirthDate,
                  onChanged: _handleBirthDateTextChanged,
                  onEditingComplete: _saveBirthDateFromText,
                ),
                const SizedBox(height: AppSpacing.md),
                _NumberField(
                  controller: _weightController,
                  label: 'Вес',
                  suffix: 'кг',
                  allowEmpty: true,
                  onEditingComplete: _saveProfile,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsSection(
              title: 'Уведомления',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Время приема препарата'),
                  subtitle: Text(_intakeTime.format(context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickIntakeTime,
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Прием препарата'),
                  subtitle: const Text('Напоминать о сегодняшнем приеме'),
                  value: _medicationNotifications,
                  onChanged: (value) async {
                    setState(() => _medicationNotifications = value);
                    await _saveSettings();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Визит к врачу'),
                  subtitle: const Text('Напоминать, если контроль просрочен'),
                  value: _doctorNotifications,
                  onChanged: (value) async {
                    setState(() => _doctorNotifications = value);
                    await _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsSection(
              title: 'Контроль',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        controller: _labDaysController,
                        label: 'Анализы',
                        suffix: 'дней',
                        integersOnly: true,
                        onEditingComplete: _saveSettings,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _NumberField(
                        controller: _doctorDaysController,
                        label: 'Врач',
                        suffix: 'дней',
                        integersOnly: true,
                        onEditingComplete: _saveSettings,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsSection(
              title: 'Референсы',
              children: [
                _RangeRow(
                  label: 'ТТГ',
                  unit: 'мМЕ/л',
                  minController: _tshMinController,
                  maxController: _tshMaxController,
                  onEditingComplete: _saveSettings,
                ),
                const Divider(height: AppSpacing.xl),
                _RangeRow(
                  label: 'Т4 св.',
                  unit: 'пмоль/л',
                  minController: _freeT4MinController,
                  maxController: _freeT4MaxController,
                  onEditingComplete: _saveSettings,
                ),
                const Divider(height: AppSpacing.xl),
                _RangeRow(
                  label: 'Т3 св.',
                  unit: 'пмоль/л',
                  minController: _freeT3MinController,
                  maxController: _freeT3MaxController,
                  onEditingComplete: _saveSettings,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsSection(
              title: 'Демо-режим',
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Анализы'),
                  subtitle: const Text(
                    'Заполнить анализы за последние полгода для проверки графика',
                  ),
                  value: _demoDataEnabled,
                  onChanged: _toggleDemoData,
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Вес'),
                  subtitle: const Text(
                    'Заполнить историю веса за последние полгода',
                  ),
                  value: _demoWeightDataEnabled,
                  onChanged: _toggleDemoWeightData,
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Сон'),
                  subtitle: const Text(
                    'Заполнить дневник сна за последние полгода',
                  ),
                  value: _demoSleepDataEnabled,
                  onChanged: _toggleDemoSleepData,
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Прием таблеток'),
                  subtitle: const Text(
                    'Заполнить историю приема за последние полгода',
                  ),
                  value: _demoMedicationDataEnabled,
                  onChanged: _toggleDemoMedicationData,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveSettings() async {
    final labDays = int.tryParse(_labDaysController.text);
    final doctorDays = int.tryParse(_doctorDaysController.text);
    final tsh = _range(_tshMinController, _tshMaxController, 'мМЕ/л');
    final freeT4 =
        _range(_freeT4MinController, _freeT4MaxController, 'пмоль/л');
    final freeT3 =
        _range(_freeT3MinController, _freeT3MaxController, 'пмоль/л');

    if (labDays == null ||
        labDays <= 0 ||
        doctorDays == null ||
        doctorDays <= 0 ||
        tsh == null ||
        freeT4 == null ||
        freeT3 == null) {
      return;
    }

    await AppScope.read(context).updateSettings(
      labControlDays: labDays,
      doctorControlDays: doctorDays,
      medicationNotificationsEnabled: _medicationNotifications,
      doctorNotificationsEnabled: _doctorNotifications,
      tshRange: tsh,
      freeT4Range: freeT4,
      freeT3Range: freeT3,
    );
  }

  Future<void> _saveIntakeTime() async {
    final now = DateTime.now();
    await AppScope.read(context).updatePrimaryMedicationTime(
      DateTime(
        now.year,
        now.month,
        now.day,
        _intakeTime.hour,
        _intakeTime.minute,
      ),
    );
  }

  Future<void> _saveProfile() async {
    await AppScope.read(context).updateProfile(
      birthDate: _birthDate,
      weightKg: _weightController.text.trim().isEmpty
          ? null
          : double.tryParse(_weightController.text.replaceAll(',', '.')),
    );
  }

  Future<void> _pickIntakeTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _intakeTime,
    );
    if (picked == null) {
      return;
    }
    setState(() => _intakeTime = picked);
    await _saveIntakeTime();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      locale: const Locale('ru'),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
      await _saveProfile();
    }
  }

  void _handleBirthDateTextChanged(String value) {
    final parsed = _parseDate(value);
    if (parsed != null) {
      setState(() => _birthDate = parsed);
    }
  }

  Future<void> _saveBirthDateFromText() async {
    final value = _birthDateController.text.trim();
    if (value.isEmpty) {
      setState(() => _birthDate = null);
      await _saveProfile();
      return;
    }

    final parsed = _parseDate(value);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите дату в формате дд.мм.гггг')),
      );
      return;
    }

    setState(() => _birthDate = parsed);
    await _saveProfile();
  }

  Future<void> _toggleDemoData(bool value) async {
    setState(() => _demoDataEnabled = value);
    await AppScope.read(context).setDemoDataEnabled(value);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Тестовые данные добавлены' : 'Тестовые данные удалены',
        ),
      ),
    );
  }

  Future<void> _toggleDemoSleepData(bool value) async {
    setState(() => _demoSleepDataEnabled = value);
    await AppScope.read(context).setDemoSleepDataEnabled(value);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Тестовые данные сна добавлены'
              : 'Тестовые данные сна удалены',
        ),
      ),
    );
  }

  Future<void> _toggleDemoWeightData(bool value) async {
    setState(() => _demoWeightDataEnabled = value);
    await AppScope.read(context).setDemoWeightDataEnabled(value);
    if (!mounted) {
      return;
    }
    final weight = AppScope.read(context).userProfile?.weightKg;
    if (weight != null) {
      _weightController.text = _format(weight);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Тестовые данные веса добавлены'
              : 'Тестовые данные веса удалены',
        ),
      ),
    );
  }

  Future<void> _toggleDemoMedicationData(bool value) async {
    setState(() => _demoMedicationDataEnabled = value);
    await AppScope.read(context).setDemoMedicationDataEnabled(value);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Тестовые данные приема добавлены'
              : 'Тестовые данные приема удалены',
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _RangeRow extends StatelessWidget {
  const _RangeRow({
    required this.label,
    required this.unit,
    required this.minController,
    required this.maxController,
    required this.onEditingComplete,
  });

  final String label;
  final String unit;
  final TextEditingController minController;
  final TextEditingController maxController;
  final VoidCallback onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                controller: minController,
                label: 'Мин.',
                onEditingComplete: onEditingComplete,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _NumberField(
                controller: maxController,
                label: 'Макс.',
                onEditingComplete: onEditingComplete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    this.suffix,
    this.integersOnly = false,
    this.allowEmpty = false,
    this.onEditingComplete,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;
  final bool integersOnly;
  final bool allowEmpty;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.numberWithOptions(decimal: !integersOnly),
      inputFormatters: [
        if (integersOnly)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: (_) => onEditingComplete?.call(),
      validator: (value) {
        if (allowEmpty && (value == null || value.trim().isEmpty)) {
          return null;
        }
        final parsed = integersOnly
            ? int.tryParse(value ?? '')
            : double.tryParse((value ?? '').replaceAll(',', '.'));
        if (parsed == null || parsed <= 0) {
          return 'Число';
        }
        return null;
      },
    );
  }
}

class _DateTextField extends StatelessWidget {
  const _DateTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onPick,
    required this.onChanged,
    required this.onEditingComplete,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;
  final IconData icon;
  final VoidCallback onPick;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.done,
      inputFormatters: const [DateInputFormatter()],
      decoration: InputDecoration(
        labelText: label,
        hintText: 'дд.мм.гггг',
        helperText: helperText,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          onPressed: onPick,
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ),
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: (_) => onEditingComplete(),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return null;
        }
        return _parseDate(trimmed) == null ? 'Формат дд.мм.гггг' : null;
      },
    );
  }
}

ReferenceRange? _range(
  TextEditingController minController,
  TextEditingController maxController,
  String unit,
) {
  final min = double.tryParse(minController.text.replaceAll(',', '.'));
  final max = double.tryParse(maxController.text.replaceAll(',', '.'));
  if (min == null || max == null || min >= max) {
    return null;
  }
  return ReferenceRange(min: min, max: max, unit: unit);
}

String _format(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}

DateTime? _parseDate(String value) {
  final parts = value.trim().split('.');
  if (parts.length != 3) {
    return null;
  }
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) {
    return null;
  }
  final date = DateTime(year, month, day);
  final now = DateTime.now();
  if (date.day != day ||
      date.month != month ||
      date.year != year ||
      date.isAfter(now) ||
      date.isBefore(DateTime(now.year - 100))) {
    return null;
  }
  return date;
}

String _ageText(DateTime birthDate) {
  final now = DateTime.now();
  var age = now.year - birthDate.year;
  final hasBirthdayPassed = now.month > birthDate.month ||
      (now.month == birthDate.month && now.day >= birthDate.day);
  if (!hasBirthdayPassed) {
    age--;
  }
  return '$age ${_yearsWord(age)}';
}

String _yearsWord(int value) {
  final mod10 = value % 10;
  final mod100 = value % 100;
  if (mod10 == 1 && mod100 != 11) {
    return 'год';
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'года';
  }
  return 'лет';
}
