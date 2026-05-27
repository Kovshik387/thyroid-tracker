class MedicationPlan {
  const MedicationPlan({
    required this.id,
    required this.name,
    required this.dosage,
    required this.intakeTime,
    this.note,
  });

  final String id;
  final String name;
  final String dosage;
  final DateTime intakeTime;
  final String? note;
}

class MedicationIntake {
  const MedicationIntake({
    required this.id,
    required this.planId,
    required this.date,
    required this.taken,
    required this.countsForStreak,
    this.takenAt,
  });

  final String id;
  final String planId;
  final DateTime date;
  final DateTime? takenAt;
  final bool taken;
  final bool countsForStreak;
}
