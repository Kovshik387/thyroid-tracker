class MedicationPlan {
  const MedicationPlan({
    required this.id,
    required this.name,
    required this.dosage,
    required this.intakeTime,
    this.doseMcg,
    this.startedAt,
    this.endedAt,
    this.note,
  });

  final String id;
  final String name;
  final String dosage;
  final DateTime intakeTime;
  final double? doseMcg;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? note;

  bool isActiveOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = startedAt == null
        ? null
        : DateTime(startedAt!.year, startedAt!.month, startedAt!.day);
    final end = endedAt == null
        ? null
        : DateTime(endedAt!.year, endedAt!.month, endedAt!.day);
    if (start != null && day.isBefore(start)) {
      return false;
    }
    if (end != null && day.isAfter(end)) {
      return false;
    }
    return true;
  }
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
