import 'medication_plan.dart';

abstract interface class MedicationRepository {
  Future<List<MedicationPlan>> watchPlans();

  Future<List<MedicationIntake>> watchIntakes();

  Future<void> savePlan(MedicationPlan plan);

  Future<void> markIntake(MedicationIntake intake);
}
