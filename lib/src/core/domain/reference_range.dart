class ReferenceRange {
  const ReferenceRange({
    required this.min,
    required this.max,
    required this.unit,
  });

  final double min;
  final double max;
  final String unit;

  bool contains(double value) => value >= min && value <= max;
}
