import 'package:flutter_test/flutter_test.dart';
import 'package:thyroid_tracker/src/features/labs/domain/lab_forecast.dart';
import 'package:thyroid_tracker/src/features/medication/domain/medication_plan.dart';

void main() {
  test('predicts TSH from three-point trend and dose change', () {
    final result = const LabForecastEngine().predict(
      const [
        LabForecastSample(day: 0, value: 6.5),
        LabForecastSample(day: 30, value: 5.0),
        LabForecastSample(day: 59, value: 5.0),
      ],
      metric: LabForecastMetric.tsh,
      medicationPlans: [
        MedicationPlan(
          id: 'old',
          name: 'Левотироксин',
          dosage: '75 мкг',
          doseMcg: 75,
          intakeTime: DateTime(2026, 1, 1, 8),
          startedAt: DateTime(2026, 1),
          endedAt: DateTime(2026, 3, 1),
        ),
        MedicationPlan(
          id: 'new',
          name: 'Левотироксин',
          dosage: '100 мкг',
          doseMcg: 100,
          intakeTime: DateTime(2026, 1, 1, 8),
          startedAt: DateTime(2026, 3, 2),
        ),
      ],
      startDate: DateTime(2026, 1),
    );

    expect(result.points, hasLength(2));
    expect(result.points.last.day, 101);
    expect(result.points.last.value, closeTo(3.725, 0.001));
  });

  test('does not forecast without three samples', () {
    final result = const LabForecastEngine().predict(
      const [
        LabForecastSample(day: 0, value: 6.5),
        LabForecastSample(day: 30, value: 5.0),
      ],
      metric: LabForecastMetric.tsh,
      medicationPlans: const [],
      startDate: DateTime(2026, 1),
    );

    expect(result.points, isEmpty);
  });

  test('keeps sharply falling TSH forecast above display floor', () {
    final result = const LabForecastEngine().predict(
      const [
        LabForecastSample(day: 0, value: 5.2),
        LabForecastSample(day: 365, value: 3.0),
        LabForecastSample(day: 730, value: 0.055),
      ],
      metric: LabForecastMetric.tsh,
      medicationPlans: const [],
      startDate: DateTime(2024, 1),
    );

    expect(result.points.last.value, greaterThanOrEqualTo(0.05));
  });
}
