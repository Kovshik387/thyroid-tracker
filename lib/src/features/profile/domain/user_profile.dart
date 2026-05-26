class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.createdAt,
    int? age,
    this.birthDate,
    this.weightKg,
    this.heightCm,
    this.sex,
    this.diagnosis,
    this.avatarData,
  }) : legacyAge = age;

  final String id;
  final String name;
  final DateTime createdAt;
  final int? legacyAge;
  final DateTime? birthDate;
  final double? weightKg;
  final double? heightCm;
  final String? sex;
  final String? diagnosis;
  final String? avatarData;

  int? get age {
    final date = birthDate;
    if (date == null) {
      return legacyAge;
    }
    final now = DateTime.now();
    var years = now.year - date.year;
    final hasBirthdayPassed = now.month > date.month ||
        (now.month == date.month && now.day >= date.day);
    if (!hasBirthdayPassed) {
      years--;
    }
    return years < 0 ? null : years;
  }
}
