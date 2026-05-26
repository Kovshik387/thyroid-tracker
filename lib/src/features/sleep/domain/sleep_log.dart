class SleepLog {
  const SleepLog({
    required this.id,
    required this.date,
    this.sleepStart,
    this.sleepEnd,
    this.quality,
    this.comment,
  });

  final String id;
  final DateTime date;
  final DateTime? sleepStart;
  final DateTime? sleepEnd;
  final int? quality;
  final String? comment;

  Duration? get duration {
    final start = sleepStart;
    final end = sleepEnd;
    if (start == null || end == null) {
      return null;
    }
    final normalizedEnd =
        end.isBefore(start) ? end.add(const Duration(days: 1)) : end;
    return normalizedEnd.difference(start);
  }
}
