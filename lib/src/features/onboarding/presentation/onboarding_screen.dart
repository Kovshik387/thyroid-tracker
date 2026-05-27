import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/date_input_formatter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _diagnosisController = TextEditingController(text: 'Гипотиреоз');
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _labDaysController = TextEditingController(text: '90');
  final _doctorDaysController = TextEditingController(text: '180');

  var _step = 0;
  String _sex = 'not_specified';
  String? _avatarData;
  DateTime? _birthDate;
  TimeOfDay _intakeTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _birthDateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _diagnosisController.dispose();
    _medicationController.dispose();
    _dosageController.dispose();
    _labDaysController.dispose();
    _doctorDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _WelcomeStep(
                      nameController: _nameController,
                      birthDateController: _birthDateController,
                      birthDate: _birthDate,
                      onPickBirthDate: _pickBirthDate,
                      onBirthDateChanged: _handleBirthDateTextChanged,
                      avatarData: _avatarData,
                      onPickAvatar: _pickAvatar,
                    ),
                    _BodyStep(
                      weightController: _weightController,
                      heightController: _heightController,
                      diagnosisController: _diagnosisController,
                      sex: _sex,
                      onSexChanged: (value) => setState(() => _sex = value),
                    ),
                    _MedicationStep(
                      medicationController: _medicationController,
                      dosageController: _dosageController,
                      intakeTime: _intakeTime,
                      onPickTime: _pickTime,
                    ),
                    _ControlStep(
                      labDaysController: _labDaysController,
                      doctorDaysController: _doctorDaysController,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    if (_step > 0)
                      IconButton(
                        tooltip: 'Назад',
                        onPressed: _previous,
                        icon: const Icon(Icons.arrow_back),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(child: _StepDots(currentStep: _step, steps: 4)),
                    FilledButton(
                      onPressed: _next,
                      child: Text(_step == 3 ? 'Начать' : 'Далее'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  void _previous() {
    setState(() => _step--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _next() async {
    final typedBirthDate = _parseDate(_birthDateController.text);
    if (_birthDateController.text.trim().isNotEmpty && typedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите дату в формате дд.мм.гггг')),
      );
      return;
    }
    if (typedBirthDate != null) {
      _birthDate = typedBirthDate;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_step < 3) {
      setState(() => _step++);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final now = DateTime.now();
    await AppScope.read(context).completeOnboarding(
      name: _nameController.text.trim(),
      birthDate: _birthDate,
      weightKg: _parseNumber(_weightController.text),
      heightCm: _parseNumber(_heightController.text),
      sex: _sex,
      diagnosis: _emptyToNull(_diagnosisController.text),
      avatarData: _avatarData,
      medicationName: _medicationController.text.trim(),
      dosage: _dosageController.text.trim(),
      intakeTime: DateTime(
        now.year,
        now.month,
        now.day,
        _intakeTime.hour,
        _intakeTime.minute,
      ),
      labControlDays: int.parse(_labDaysController.text),
      doctorControlDays: int.parse(_doctorDaysController.text),
    );
  }

  Future<void> _pickAvatar() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 88,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _avatarData = base64Encode(bytes));
    }
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
    }
  }

  void _handleBirthDateTextChanged(String value) {
    final parsed = _parseDate(value);
    if (parsed != null) {
      setState(() => _birthDate = parsed);
    }
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    required this.nameController,
    required this.birthDateController,
    required this.birthDate,
    required this.onPickBirthDate,
    required this.onBirthDateChanged,
    required this.avatarData,
    required this.onPickAvatar,
  });

  final TextEditingController nameController;
  final TextEditingController birthDateController;
  final DateTime? birthDate;
  final VoidCallback onPickBirthDate;
  final ValueChanged<String> onBirthDateChanged;
  final String? avatarData;
  final VoidCallback onPickAvatar;

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      title: 'Давайте познакомимся',
      subtitle: 'Эти данные нужны только для вашего локального дневника.',
      image: const _OnboardingImage(),
      child: Column(
        children: [
          _AvatarPicker(
            nameController: nameController,
            avatarData: avatarData,
            onTap: onPickAvatar,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Как вас зовут',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          _DateTextField(
            controller: birthDateController,
            label: 'Дата рождения',
            hintText: birthDate == null
                ? 'дд.мм.гггг'
                : DateFormat('dd.MM.yyyy').format(birthDate!),
            icon: Icons.cake_outlined,
            onPick: onPickBirthDate,
            onChanged: onBirthDateChanged,
          ),
        ],
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.nameController,
    required this.avatarData,
    required this.onTap,
  });

  final TextEditingController nameController;
  final String? avatarData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: nameController,
      builder: (context, value, child) {
        final initial = value.text.trim().isEmpty
            ? '?'
            : value.text.trim().characters.first.toUpperCase();
        final avatarBytes =
            avatarData == null ? null : base64Decode(avatarData!);

        return Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(48),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.azureSoft,
                backgroundImage:
                    avatarBytes == null ? null : MemoryImage(avatarBytes),
                child: avatarBytes == null
                    ? Text(
                        initial,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.azureDeep,
                              fontWeight: FontWeight.w800,
                            ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(
                  avatarData == null ? 'Добавить аватар' : 'Изменить аватар'),
            ),
          ],
        );
      },
    );
  }
}

class _BodyStep extends StatelessWidget {
  const _BodyStep({
    required this.weightController,
    required this.heightController,
    required this.diagnosisController,
    required this.sex,
    required this.onSexChanged,
  });

  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController diagnosisController;
  final String sex;
  final ValueChanged<String> onSexChanged;

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      title: 'Параметры здоровья',
      subtitle: 'Вес и рост пригодятся для будущих заметок и отчетов.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DecimalField(
                  controller: weightController,
                  label: 'Вес, кг',
                  required: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _DecimalField(
                  controller: heightController,
                  label: 'Рост, см',
                  required: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SexSelector(
            value: sex,
            onChanged: onSexChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: diagnosisController,
            decoration: const InputDecoration(
              labelText: 'Диагноз / состояние',
              prefixIcon: Icon(Icons.medical_information_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _SexSelector extends StatelessWidget {
  const _SexSelector({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Пол', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            return SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'female',
                  label: Text(compact ? 'Ж' : 'Женский'),
                  icon: const Icon(Icons.female),
                ),
                ButtonSegment(
                  value: 'male',
                  label: Text(compact ? 'М' : 'Мужской'),
                  icon: const Icon(Icons.male),
                ),
                ButtonSegment(
                  value: 'not_specified',
                  label: Text(compact ? 'Не ук.' : 'Не указывать'),
                  icon: const Icon(Icons.person_outline),
                ),
              ],
              selected: {value},
              onSelectionChanged: (selection) => onChanged(selection.first),
              showSelectedIcon: false,
            );
          },
        ),
      ],
    );
  }
}

class _MedicationStep extends StatelessWidget {
  const _MedicationStep({
    required this.medicationController,
    required this.dosageController,
    required this.intakeTime,
    required this.onPickTime,
  });

  final TextEditingController medicationController;
  final TextEditingController dosageController;
  final TimeOfDay intakeTime;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      title: 'Лечение',
      subtitle: 'Укажите препарат, дозировку и обычное время приема.',
      child: Column(
        children: [
          TextFormField(
            controller: medicationController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Название препарата',
              hintText: 'Например, Эутирокс',
              prefixIcon: Icon(Icons.medication_outlined),
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: dosageController,
            textInputAction: TextInputAction.next,
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
            subtitle: Text(intakeTime.format(context)),
            trailing: const Icon(Icons.chevron_right),
            onTap: onPickTime,
          ),
        ],
      ),
    );
  }
}

class _ControlStep extends StatelessWidget {
  const _ControlStep({
    required this.labDaysController,
    required this.doctorDaysController,
  });

  final TextEditingController labDaysController;
  final TextEditingController doctorDaysController;

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      title: 'Контроль',
      subtitle:
          'Укажите, как часто по вашим рекомендациям необходимо проводить исследования крови и посещать врача-эндокринолога.',
      child: Row(
        children: [
          Expanded(
            child: _DaysField(
              controller: labDaysController,
              label: 'Анализы, дней',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _DaysField(
              controller: doctorDaysController,
              label: 'Врач, дней',
            ),
          ),
        ],
      ),
    );
  }
}

class _StepFrame extends StatelessWidget {
  const _StepFrame({
    required this.title,
    required this.subtitle,
    required this.child,
    this.image,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? image;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.lg),
        if (image != null) ...[
          image!,
          const SizedBox(height: AppSpacing.xl),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.muted,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppCard(child: child),
      ],
    );
  }
}

class _OnboardingImage extends StatelessWidget {
  const _OnboardingImage();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Image.asset(
          'assets/images/onboarding_health.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const DecoratedBox(
              decoration: BoxDecoration(color: AppColors.azureSoft),
              child: Center(
                child: Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColors.azureDeep,
                  size: 72,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({
    required this.currentStep,
    required this.steps,
  });

  final int currentStep;
  final int steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < steps; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: i == currentStep ? 22 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color:
                  i == currentStep ? AppColors.azure : AppColors.borderStrong,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
      ],
    );
  }
}

class _DecimalField extends StatelessWidget {
  const _DecimalField({
    required this.controller,
    required this.label,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (!required && (value == null || value.trim().isEmpty)) {
          return null;
        }
        return _parseNumber(value ?? '') == null ? 'Введите число' : null;
      },
    );
  }
}

class _DaysField extends StatelessWidget {
  const _DaysField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
      validator: _positiveIntRequired,
    );
  }
}

class _DateTextField extends StatelessWidget {
  const _DateTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.onPick,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final VoidCallback onPick;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.done,
      inputFormatters: const [DateInputFormatter()],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          onPressed: onPick,
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ),
      onChanged: onChanged,
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

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Заполните поле';
  }
  return null;
}

String? _positiveIntRequired(String? value) {
  final parsed = int.tryParse(value ?? '');
  if (parsed == null || parsed <= 0) {
    return 'Введите число';
  }
  return null;
}

double? _parseNumber(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.'));
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

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
