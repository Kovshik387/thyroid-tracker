import '../../medication/domain/medication_plan.dart';

enum LabForecastMetric {
  tsh,
  freeT4,
  freeT3,
}

class LabForecastSample {
  const LabForecastSample({
    required this.day,
    required this.value,
  });

  final double day;
  final double value;
}

class LabForecastPoint {
  const LabForecastPoint({
    required this.day,
    required this.value,
  });

  final double day;
  final double value;
}

class LabForecastResult {
  const LabForecastResult({
    required this.points,
    required this.methodNote,
    this.medicationNote,
  });

  final List<LabForecastPoint> points;
  final String methodNote;
  final String? medicationNote;
}

class LabForecastEngine {
  const LabForecastEngine({
    this.trendWeight = 0.7,
    this.forecastHorizonDays = 42,
  });

  final double trendWeight;
  final int forecastHorizonDays;

  LabForecastResult predict(
    List<LabForecastSample> samples, {
    required LabForecastMetric metric,
    required List<MedicationPlan> medicationPlans,
    required DateTime startDate,
  }) {
    final source = [...samples]..sort((a, b) => a.day.compareTo(b.day));
    if (source.length < 3) {
      return const LabForecastResult(points: [], methodNote: '');
    }

    final lastThree = source.sublist(source.length - 3);
    final trend = _movingTrend(
      lastThree[0].value,
      lastThree[1].value,
      lastThree[2].value,
    );
    final doseChange = _doseChange(
      medicationPlans: medicationPlans,
      startDate: startDate,
      lastSampleDay: source.last.day,
    );
    final doseEffect = _doseCoefficient(metric) * doseChange;
    final forecastValue =
        (lastThree[2].value + trendWeight * trend + doseEffect)
            .clamp(0.0, double.infinity);
    if (forecastValue.isNaN || forecastValue.isInfinite) {
      return const LabForecastResult(points: [], methodNote: '');
    }

    return LabForecastResult(
      points: [
        LabForecastPoint(day: source.last.day, value: source.last.value),
        LabForecastPoint(
          day: source.last.day + forecastHorizonDays,
          value: forecastValue,
        ),
      ],
      methodNote:
          'Модель на 6 недель: Xпрогноз = Xn + 0.7 * Trend + K * ΔDose. Trend берется по 3 последним анализам.',
      medicationNote: _medicationNote(
        metric: metric,
        doseChange: doseChange,
        coefficient: _doseCoefficient(metric),
      ),
    );
  }

  double _movingTrend(double first, double second, double third) {
    return ((third - second) + (second - first)) / 2;
  }

  double _doseCoefficient(LabForecastMetric metric) {
    return switch (metric) {
      LabForecastMetric.tsh => -0.03,
      LabForecastMetric.freeT4 => 0.04,
      LabForecastMetric.freeT3 => 0.01,
    };
  }

  double _doseChange({
    required List<MedicationPlan> medicationPlans,
    required DateTime startDate,
    required double lastSampleDay,
  }) {
    if (medicationPlans.isEmpty) {
      return 0;
    }

    final lastDate = startDate.add(Duration(days: lastSampleDay.round()));
    final forecastDate = lastDate.add(Duration(days: forecastHorizonDays));
    final currentPlan = _activeMedicationPlan(medicationPlans, lastDate);
    final forecastPlan = _activeMedicationPlan(medicationPlans, forecastDate) ??
        _activeMedicationPlan(medicationPlans, DateTime.now()) ??
        currentPlan;
    final currentDose =
        currentPlan?.doseMcg ?? _parseDoseMcg(currentPlan?.dosage);
    final forecastDose =
        forecastPlan?.doseMcg ?? _parseDoseMcg(forecastPlan?.dosage);
    if (currentDose == null || forecastDose == null) {
      return 0;
    }
    return forecastDose - currentDose;
  }

  String? _medicationNote({
    required LabForecastMetric metric,
    required double doseChange,
    required double coefficient,
  }) {
    if (doseChange.abs() < 0.001) {
      return null;
    }
    final label = switch (metric) {
      LabForecastMetric.tsh => 'ТТГ',
      LabForecastMetric.freeT4 => 'свободного Т4',
      LabForecastMetric.freeT3 => 'свободного Т3',
    };
    final effect = coefficient * doseChange;
    return 'Учтено изменение дозы левотироксина на ${_formatDose(doseChange)} мкг: вклад в прогноз $label ${_formatSigned(effect)}.';
  }
}

MedicationPlan? _activeMedicationPlan(
  List<MedicationPlan> plans,
  DateTime date,
) {
  final active = plans.where((plan) => plan.isActiveOn(date)).toList()
    ..sort((a, b) {
      final aStart = a.startedAt ?? DateTime(1900);
      final bStart = b.startedAt ?? DateTime(1900);
      return bStart.compareTo(aStart);
    });
  if (active.isNotEmpty) {
    return active.first;
  }
  return null;
}

double? _parseDoseMcg(String? value) {
  if (value == null) {
    return null;
  }
  final match =
      RegExp(r'(\d+(?:[,.]\d+)?)').firstMatch(value.replaceAll(',', '.'));
  if (match == null) {
    return null;
  }
  return double.tryParse(match.group(1)!);
}

String _formatDose(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}

String _formatSigned(double value) {
  final sign = value > 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(2)}';
}
