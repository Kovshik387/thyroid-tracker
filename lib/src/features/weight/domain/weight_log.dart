class WeightLog {
  const WeightLog({
    required this.id,
    required this.date,
    required this.weightKg,
    this.comment,
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final String? comment;
}
