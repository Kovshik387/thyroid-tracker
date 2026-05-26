class LabResult {
  const LabResult({
    required this.id,
    required this.date,
    this.tsh,
    this.freeT4,
    this.freeT3,
    this.extraMetrics = const [],
    this.comment,
  });

  final String id;
  final DateTime date;
  final double? tsh;
  final double? freeT4;
  final double? freeT3;
  final List<LabMetric> extraMetrics;
  final String? comment;
}

class LabMetric {
  const LabMetric({
    required this.name,
    required this.value,
    this.unit,
  });

  final String name;
  final double value;
  final String? unit;
}
