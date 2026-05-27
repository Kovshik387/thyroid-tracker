import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../data/local/app_database.dart';
import '../core/domain/reference_range.dart';
import '../features/doctor/domain/doctor_visit.dart';
import '../features/labs/domain/lab_result.dart';
import '../features/media/domain/medical_media.dart';
import '../features/medication/domain/medication_plan.dart';
import '../features/profile/domain/user_profile.dart';
import '../features/sleep/domain/sleep_log.dart';
import '../features/weight/domain/weight_log.dart';

class AppState extends ChangeNotifier {
  AppState({AppDatabase? database}) : _database = database ?? AppDatabase() {
    _load();
  }

  final AppDatabase _database;
  final List<LabResult> _labs = [];
  final List<MedicationPlan> _medicationPlans = [];
  final List<DoctorVisit> _doctorVisits = [];
  final List<MedicalMedia> _medicalMedia = [];
  final List<SleepLog> _sleepLogs = [];
  final List<WeightLog> _weightLogs = [];
  final List<MedicationIntake> _medicationIntakes = [];
  final Set<String> _takenMedicationDates = {};
  final Set<DateTime> _takenMedicationDays = {};
  UserProfile? _userProfile;

  var _isLoaded = false;
  var _hasCompletedOnboarding = false;
  var _labControlDays = 90;
  var _doctorControlDays = 180;
  var _medicationNotificationsEnabled = true;
  var _doctorNotificationsEnabled = true;
  var _tshMin = 0.4;
  var _tshMax = 4.0;
  var _freeT4Min = 9.0;
  var _freeT4Max = 22.0;
  var _freeT3Min = 3.1;
  var _freeT3Max = 6.8;
  var _demoDataEnabled = false;
  var _demoSleepDataEnabled = false;
  var _demoWeightDataEnabled = false;
  var _demoMedicationDataEnabled = false;
  var _isSeedingDemoData = false;

  bool get isLoaded => _isLoaded;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  UserProfile? get userProfile => _userProfile;

  int get labControlDays => _labControlDays;

  int get doctorControlDays => _doctorControlDays;

  bool get medicationNotificationsEnabled => _medicationNotificationsEnabled;

  bool get doctorNotificationsEnabled => _doctorNotificationsEnabled;

  ReferenceRange get tshRange =>
      ReferenceRange(min: _tshMin, max: _tshMax, unit: 'мМЕ/л');

  ReferenceRange get freeT4Range =>
      ReferenceRange(min: _freeT4Min, max: _freeT4Max, unit: 'пмоль/л');

  ReferenceRange get freeT3Range =>
      ReferenceRange(min: _freeT3Min, max: _freeT3Max, unit: 'пмоль/л');

  bool get demoDataEnabled => _demoDataEnabled;

  bool get demoSleepDataEnabled => _demoSleepDataEnabled;

  bool get demoWeightDataEnabled => _demoWeightDataEnabled;

  bool get demoMedicationDataEnabled => _demoMedicationDataEnabled;

  List<LabResult> get labs => List.unmodifiable(
        [..._labs]..sort((a, b) => a.date.compareTo(b.date)),
      );

  List<MedicationPlan> get medicationPlans =>
      List.unmodifiable(_medicationPlans);

  List<DoctorVisit> get doctorVisits => List.unmodifiable(
        [..._doctorVisits]..sort((a, b) => b.date.compareTo(a.date)),
      );

  List<MedicalMedia> get medicalMedia => List.unmodifiable(
        [..._medicalMedia]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  List<SleepLog> get sleepLogs => List.unmodifiable(
        [..._sleepLogs]..sort((a, b) => b.date.compareTo(a.date)),
      );

  List<WeightLog> get weightLogs => List.unmodifiable(
        [..._weightLogs]..sort((a, b) => b.date.compareTo(a.date)),
      );

  List<MedicationIntake> get medicationIntakes => List.unmodifiable(
        [..._medicationIntakes]..sort((a, b) => b.date.compareTo(a.date)),
      );

  Set<DateTime> get takenMedicationDays =>
      Set.unmodifiable(_takenMedicationDays);

  int get medicationStreakDays {
    if (_takenMedicationDays.isEmpty) {
      return 0;
    }

    var cursor = _dateOnly(DateTime.now());
    if (!_takenMedicationDays.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (_takenMedicationDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  LabResult? get latestLab {
    if (_labs.isEmpty) {
      return null;
    }
    return labs.last;
  }

  MedicationPlan? get primaryMedication {
    if (_medicationPlans.isEmpty) {
      return null;
    }
    return _medicationPlans.first;
  }

  DoctorVisit? get latestDoctorVisit {
    if (_doctorVisits.isEmpty) {
      return null;
    }
    return doctorVisits.first;
  }

  bool get isPrimaryMedicationTakenToday {
    final medication = primaryMedication;
    if (medication == null) {
      return false;
    }
    return isMedicationTakenToday(medication.id);
  }

  bool isMedicationTakenToday(String medicationId) {
    return _takenMedicationDates
        .contains(_intakeKey(medicationId, DateTime.now()));
  }

  bool get needsLabControl {
    final latest = latestLab;
    if (latest == null) {
      return true;
    }
    return DateTime.now().difference(latest.date).inDays > _labControlDays;
  }

  bool get needsDoctorVisit {
    final latest = latestDoctorVisit;
    if (latest == null) {
      return true;
    }
    return DateTime.now().difference(latest.date).inDays > _doctorControlDays;
  }

  Future<void> completeOnboarding({
    required String name,
    DateTime? birthDate,
    double? weightKg,
    double? heightCm,
    String? sex,
    String? diagnosis,
    String? avatarData,
    required String medicationName,
    required String dosage,
    required DateTime intakeTime,
    required int labControlDays,
    required int doctorControlDays,
  }) async {
    await _database.saveUserProfile(
      UserProfileEntriesCompanion.insert(
        id: 'profile',
        name: name,
        age: const Value.absent(),
        birthDate: Value(birthDate),
        weightKg: Value(weightKg),
        heightCm: Value(heightCm),
        sex: Value(sex),
        diagnosis: Value(diagnosis),
        avatarData: Value(avatarData),
        createdAt: DateTime.now(),
      ),
    );
    await _database.saveMedicationPlan(
      MedicationPlanEntriesCompanion.insert(
        id: 'med-1',
        name: medicationName,
        dosage: dosage,
        intakeTime: intakeTime,
      ),
    );
    await _database.saveSetting('onboardingCompleted', 'true');
    await _database.saveSetting('labControlDays', labControlDays.toString());
    await _database.saveSetting(
        'doctorControlDays', doctorControlDays.toString());
    if (weightKg != null && weightKg > 0) {
      await _database.saveWeightLog(
        WeightLogEntriesCompanion.insert(
          id: 'weight-${DateTime.now().microsecondsSinceEpoch}',
          date: DateTime.now(),
          weightKg: weightKg,
          comment: const Value('Первый запуск'),
        ),
      );
    }
    await _load();
  }

  Future<void> addLab({
    required DateTime date,
    double? tsh,
    double? freeT4,
    double? freeT3,
    List<LabMetric> extraMetrics = const [],
    String? comment,
  }) async {
    await _database.saveLabResult(
      LabResultEntriesCompanion.insert(
        id: 'lab-${DateTime.now().microsecondsSinceEpoch}',
        date: date,
        tsh: Value(tsh),
        freeT4: Value(freeT4),
        freeT3: Value(freeT3),
        comment: Value(comment),
      ),
    );
    await _load();
  }

  Future<void> updateLab({
    required String id,
    required DateTime date,
    double? tsh,
    double? freeT4,
    double? freeT3,
    String? comment,
  }) async {
    await _database.saveLabResult(
      LabResultEntriesCompanion.insert(
        id: id,
        date: date,
        tsh: Value(tsh),
        freeT4: Value(freeT4),
        freeT3: Value(freeT3),
        comment: Value(comment),
      ),
    );
    await _load();
  }

  Future<void> deleteLab(String id) async {
    await _database.deleteLabResult(id);
    await _load();
  }

  Future<void> markPrimaryMedicationTakenToday() async {
    final medication = primaryMedication;
    if (medication == null) {
      return;
    }
    await markMedicationTakenToday(medication.id);
  }

  Future<void> markMedicationTakenToday(String medicationId) async {
    final now = DateTime.now();
    await markMedicationTaken(
      medicationId: medicationId,
      date: now,
      takenAt: now,
    );
  }

  Future<void> markMedicationTaken({
    required String medicationId,
    required DateTime date,
    DateTime? takenAt,
  }) async {
    final normalizedDate = _dateOnly(date);
    final now = DateTime.now();
    final today = _dateOnly(now);
    final actualTakenAt = takenAt ??
        DateTime(
          normalizedDate.year,
          normalizedDate.month,
          normalizedDate.day,
          now.hour,
          now.minute,
        );
    await _database.saveMedicationIntake(
      MedicationIntakeEntriesCompanion.insert(
        id: _intakeKey(medicationId, normalizedDate),
        planId: medicationId,
        date: normalizedDate,
        takenAt: Value(actualTakenAt),
        taken: true,
        countsForStreak: Value(normalizedDate == today),
      ),
    );
    await _load();
  }

  Future<void> addMedicationPlan({
    required String name,
    required String dosage,
    required DateTime intakeTime,
    String? note,
  }) async {
    await _database.saveMedicationPlan(
      MedicationPlanEntriesCompanion.insert(
        id: 'med-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        dosage: dosage,
        intakeTime: intakeTime,
        note: Value(note),
      ),
    );
    await _load();
  }

  Future<void> deleteMedicationPlan(String id) async {
    await _database.deleteMedicationPlan(id);
    await _load();
  }

  Future<void> updatePrimaryMedicationTime(DateTime intakeTime) async {
    final medication = primaryMedication;
    if (medication == null) {
      return;
    }

    await _database.saveMedicationPlan(
      MedicationPlanEntriesCompanion.insert(
        id: medication.id,
        name: medication.name,
        dosage: medication.dosage,
        intakeTime: intakeTime,
        note: Value(medication.note),
      ),
    );
    await _load();
  }

  Future<void> addDoctorVisit({
    required DateTime date,
    String? doctorName,
    String? specialization,
    String? recommendations,
    DateTime? nextControlDate,
  }) async {
    await _database.saveDoctorVisit(
      DoctorVisitEntriesCompanion.insert(
        id: 'visit-${DateTime.now().microsecondsSinceEpoch}',
        date: date,
        doctorName: Value(doctorName),
        specialization: Value(specialization),
        recommendations: Value(recommendations),
        nextControlDate: Value(nextControlDate),
      ),
    );
    await _load();
  }

  Future<void> resetToDefaults() async {
    await _database.resetAll();
    _labs.clear();
    _medicationPlans.clear();
    _doctorVisits.clear();
    _medicalMedia.clear();
    _sleepLogs.clear();
    _weightLogs.clear();
    _medicationIntakes.clear();
    _takenMedicationDates.clear();
    _takenMedicationDays.clear();
    _userProfile = null;
    _hasCompletedOnboarding = false;
    _labControlDays = 90;
    _doctorControlDays = 180;
    _medicationNotificationsEnabled = true;
    _doctorNotificationsEnabled = true;
    _tshMin = 0.4;
    _tshMax = 4.0;
    _freeT4Min = 9.0;
    _freeT4Max = 22.0;
    _freeT3Min = 3.1;
    _freeT3Max = 6.8;
    _demoDataEnabled = false;
    _demoSleepDataEnabled = false;
    _demoWeightDataEnabled = false;
    _demoMedicationDataEnabled = false;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateControlIntervals({
    required int labControlDays,
    required int doctorControlDays,
  }) async {
    await _database.saveSetting('labControlDays', labControlDays.toString());
    await _database.saveSetting(
        'doctorControlDays', doctorControlDays.toString());
    await _load();
  }

  Future<void> updateSettings({
    required int labControlDays,
    required int doctorControlDays,
    required bool medicationNotificationsEnabled,
    required bool doctorNotificationsEnabled,
    required ReferenceRange tshRange,
    required ReferenceRange freeT4Range,
    required ReferenceRange freeT3Range,
  }) async {
    await _database.saveSetting('labControlDays', labControlDays.toString());
    await _database.saveSetting(
        'doctorControlDays', doctorControlDays.toString());
    await _database.saveSetting(
      'medicationNotificationsEnabled',
      medicationNotificationsEnabled.toString(),
    );
    await _database.saveSetting(
      'doctorNotificationsEnabled',
      doctorNotificationsEnabled.toString(),
    );
    await _database.saveSetting('tshMin', tshRange.min.toString());
    await _database.saveSetting('tshMax', tshRange.max.toString());
    await _database.saveSetting('freeT4Min', freeT4Range.min.toString());
    await _database.saveSetting('freeT4Max', freeT4Range.max.toString());
    await _database.saveSetting('freeT3Min', freeT3Range.min.toString());
    await _database.saveSetting('freeT3Max', freeT3Range.max.toString());
    await _load();
  }

  Future<void> updateProfile({
    DateTime? birthDate,
    double? weightKg,
  }) async {
    final profile = _userProfile;
    if (profile == null) {
      return;
    }

    await _database.saveUserProfile(
      UserProfileEntriesCompanion.insert(
        id: profile.id,
        name: profile.name,
        age: const Value.absent(),
        birthDate: Value(birthDate),
        weightKg: Value(weightKg),
        heightCm: Value(profile.heightCm),
        sex: Value(profile.sex),
        diagnosis: Value(profile.diagnosis),
        avatarData: Value(profile.avatarData),
        createdAt: profile.createdAt,
      ),
    );
    await _load();
  }

  Future<void> setDemoDataEnabled(bool enabled) async {
    const demoLabDataVersion = '2';
    await _database.saveSetting('demoDataEnabled', enabled.toString());
    if (enabled) {
      await _seedDemoLabResults();
      await _database.saveSetting('demoLabDataVersion', demoLabDataVersion);
    } else {
      await _database.deleteLabResultsByIdPrefix('demo-lab-');
    }
    await _load();
  }

  Future<void> setDemoSleepDataEnabled(bool enabled) async {
    await _database.saveSetting('demoSleepDataEnabled', enabled.toString());
    if (enabled) {
      await _seedDemoSleepLogs();
    } else {
      await _database.deleteSleepLogsByIdPrefix('demo-sleep-');
    }
    await _load();
  }

  Future<void> setDemoWeightDataEnabled(bool enabled) async {
    await _database.saveSetting('demoWeightDataEnabled', enabled.toString());
    if (enabled) {
      await _seedDemoWeightLogs();
    } else {
      await _database.deleteWeightLogsByIdPrefix('demo-weight-');
    }
    await _load();
  }

  Future<void> setDemoMedicationDataEnabled(bool enabled) async {
    await _database.saveSetting(
        'demoMedicationDataEnabled', enabled.toString());
    if (enabled) {
      await _seedDemoMedicationIntakes();
    } else {
      await _database.deleteMedicationIntakesByIdPrefix('demo-intake-');
    }
    await _load();
  }

  Future<void> addMedicalMedia({
    required String data,
    required MedicalMediaCategory category,
    required String title,
    String? mimeType,
    String? comment,
  }) async {
    await _database.saveMedicalMedia(
      MedicalMediaEntriesCompanion.insert(
        id: 'media-${DateTime.now().microsecondsSinceEpoch}',
        title: Value(title),
        category: category.name,
        data: data,
        mimeType: Value(mimeType),
        comment: Value(comment),
        createdAt: DateTime.now(),
      ),
    );
    await _load();
  }

  Future<void> deleteMedicalMedia(String id) async {
    await _database.deleteMedicalMedia(id);
    await _load();
  }

  Future<void> addSleepLog({
    required DateTime date,
    DateTime? sleepStart,
    DateTime? sleepEnd,
    int? quality,
    String? comment,
  }) async {
    await _database.saveSleepLog(
      SleepLogEntriesCompanion.insert(
        id: 'sleep-${DateTime.now().microsecondsSinceEpoch}',
        date: date,
        sleepStart: Value(sleepStart),
        sleepEnd: Value(sleepEnd),
        quality: Value(quality),
        comment: Value(comment),
      ),
    );
    await _load();
  }

  Future<void> updateSleepLog({
    required String id,
    required DateTime date,
    DateTime? sleepStart,
    DateTime? sleepEnd,
    int? quality,
    String? comment,
  }) async {
    await _database.saveSleepLog(
      SleepLogEntriesCompanion.insert(
        id: id,
        date: date,
        sleepStart: Value(sleepStart),
        sleepEnd: Value(sleepEnd),
        quality: Value(quality),
        comment: Value(comment),
      ),
    );
    await _load();
  }

  Future<void> deleteSleepLog(String id) async {
    await _database.deleteSleepLog(id);
    await _load();
  }

  Future<void> addWeightLog({
    required DateTime date,
    required double weightKg,
    String? comment,
  }) async {
    final profile = _userProfile;
    if (profile != null) {
      await _database.saveUserProfile(
        UserProfileEntriesCompanion.insert(
          id: profile.id,
          name: profile.name,
          age: const Value.absent(),
          birthDate: Value(profile.birthDate),
          weightKg: Value(weightKg),
          heightCm: Value(profile.heightCm),
          sex: Value(profile.sex),
          diagnosis: Value(profile.diagnosis),
          avatarData: Value(profile.avatarData),
          createdAt: profile.createdAt,
        ),
      );
    }

    await _database.saveWeightLog(
      WeightLogEntriesCompanion.insert(
        id: 'weight-${DateTime.now().microsecondsSinceEpoch}',
        date: date,
        weightKg: weightKg,
        comment: Value(comment),
      ),
    );
    await _load();
  }

  Future<void> updateWeightLog({
    required String id,
    required DateTime date,
    required double weightKg,
    String? comment,
  }) async {
    final profile = _userProfile;
    if (profile != null) {
      final latestOther = _weightLogs
          .where((log) => log.id != id)
          .fold<WeightLog?>(null, (latest, log) {
        if (latest == null || log.date.isAfter(latest.date)) {
          return log;
        }
        return latest;
      });
      final shouldUpdateProfile =
          latestOther == null || !latestOther.date.isAfter(date);
      if (shouldUpdateProfile) {
        await _database.saveUserProfile(
          UserProfileEntriesCompanion.insert(
            id: profile.id,
            name: profile.name,
            age: const Value.absent(),
            birthDate: Value(profile.birthDate),
            weightKg: Value(weightKg),
            heightCm: Value(profile.heightCm),
            sex: Value(profile.sex),
            diagnosis: Value(profile.diagnosis),
            avatarData: Value(profile.avatarData),
            createdAt: profile.createdAt,
          ),
        );
      }
    }

    await _database.saveWeightLog(
      WeightLogEntriesCompanion.insert(
        id: id,
        date: date,
        weightKg: weightKg,
        comment: Value(comment),
      ),
    );
    await _load();
  }

  Future<void> deleteWeightLog(String id) async {
    await _database.deleteWeightLog(id);
    await _load();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await _database.getSettings();
    final labs = await _database.getLabResults();
    final plans = await _database.getMedicationPlans();
    final visits = await _database.getDoctorVisits();
    final intakes = await _database.getMedicationIntakes();
    final profile = await _database.getUserProfile();
    final media = await _database.getMedicalMedia();
    final sleepLogs = await _database.getSleepLogs();
    final weightLogs = await _database.getWeightLogs();

    _hasCompletedOnboarding = settings['onboardingCompleted'] == 'true';
    _labControlDays = int.tryParse(settings['labControlDays'] ?? '') ?? 90;
    _doctorControlDays =
        int.tryParse(settings['doctorControlDays'] ?? '') ?? 180;
    _medicationNotificationsEnabled =
        settings['medicationNotificationsEnabled'] != 'false';
    _doctorNotificationsEnabled =
        settings['doctorNotificationsEnabled'] != 'false';
    _tshMin = double.tryParse(settings['tshMin'] ?? '') ?? 0.4;
    _tshMax = double.tryParse(settings['tshMax'] ?? '') ?? 4.0;
    _freeT4Min = double.tryParse(settings['freeT4Min'] ?? '') ?? 9.0;
    _freeT4Max = double.tryParse(settings['freeT4Max'] ?? '') ?? 22.0;
    _freeT3Min = double.tryParse(settings['freeT3Min'] ?? '') ?? 3.1;
    _freeT3Max = double.tryParse(settings['freeT3Max'] ?? '') ?? 6.8;
    _demoDataEnabled = settings['demoDataEnabled'] == 'true';
    _demoSleepDataEnabled = settings['demoSleepDataEnabled'] == 'true';
    _demoWeightDataEnabled = settings['demoWeightDataEnabled'] == 'true';
    _demoMedicationDataEnabled =
        settings['demoMedicationDataEnabled'] == 'true';

    const demoLabDataVersion = '2';
    if (_demoDataEnabled &&
        !_isSeedingDemoData &&
        (settings['demoLabDataVersion'] != demoLabDataVersion ||
            labs.every((lab) => !lab.id.startsWith('demo-lab-')))) {
      _isSeedingDemoData = true;
      await _seedDemoLabResults();
      await _database.saveSetting('demoLabDataVersion', demoLabDataVersion);
      _isSeedingDemoData = false;
      return _load();
    }

    if (_demoSleepDataEnabled &&
        sleepLogs.every((log) => !log.id.startsWith('demo-sleep-'))) {
      await _seedDemoSleepLogs();
      return _load();
    }

    if (_demoWeightDataEnabled &&
        weightLogs.every((log) => !log.id.startsWith('demo-weight-'))) {
      await _seedDemoWeightLogs();
      return _load();
    }

    if (_demoMedicationDataEnabled &&
        intakes.every((intake) => !intake.id.startsWith('demo-intake-'))) {
      await _seedDemoMedicationIntakes();
      return _load();
    }

    _labs
      ..clear()
      ..addAll(labs.map(_labFromRow));
    _medicationPlans
      ..clear()
      ..addAll(plans.map(_medicationPlanFromRow));
    _doctorVisits
      ..clear()
      ..addAll(visits.map(_doctorVisitFromRow));
    _medicalMedia
      ..clear()
      ..addAll(media.map(_medicalMediaFromRow));
    _sleepLogs
      ..clear()
      ..addAll(sleepLogs.map(_sleepLogFromRow));
    _weightLogs
      ..clear()
      ..addAll(weightLogs.map(_weightLogFromRow));
    _medicationIntakes
      ..clear()
      ..addAll(intakes.map(_medicationIntakeFromRow));
    _userProfile = profile == null ? null : _userProfileFromRow(profile);
    _takenMedicationDates
      ..clear()
      ..addAll(
          intakes.where((intake) => intake.taken).map((intake) => intake.id));
    _takenMedicationDays
      ..clear()
      ..addAll(
        intakes
            .where((intake) => intake.taken && intake.countsForStreak)
            .map((intake) => _dateOnly(intake.date)),
      );

    _isLoaded = true;
    notifyListeners();
  }

  String _intakeKey(String medicationId, DateTime date) {
    return '$medicationId-${date.year}-${date.month}-${date.day}';
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> _seedDemoLabResults() async {
    await _database.deleteLabResultsByIdPrefix('demo-lab-');

    final today = _dateOnly(DateTime.now());
    final start = DateTime(today.year, today.month - 30, today.day);
    const stepDays = 14;
    const totalDays = 900;

    for (var day = 0, index = 0; day <= totalDays; day += stepDays, index++) {
      final progress = day / totalDays;
      final seasonal = _demoWave(index, 0.28) * 0.55;
      final shortWave = _demoWave(index, 0.83) * 0.18;
      final therapyDrop = progress < 0.55 ? progress / 0.55 : 1.0;
      final recentDrift = progress < 0.78 ? 0.0 : (progress - 0.78) * 1.35;

      final tsh = (6.2 - therapyDrop * 4.4 + recentDrift + seasonal + shortWave)
          .clamp(0.35, 7.2);
      final freeT4 =
          (8.6 + therapyDrop * 7.8 - recentDrift * 1.7 - seasonal * 0.75)
              .clamp(7.4, 19.5);
      final freeT3 = (3.0 +
              therapyDrop * 1.7 -
              recentDrift * 0.2 +
              _demoWave(index, 0.9) * 0.22)
          .clamp(2.8, 5.4);

      await _database.saveLabResult(
        LabResultEntriesCompanion.insert(
          id: 'demo-lab-$index',
          date: start.add(Duration(days: day)),
          tsh: Value(_roundDemo(tsh)),
          freeT4: Value(_roundDemo(freeT4)),
          freeT3: Value(_roundDemo(freeT3)),
          comment: const Value(
              'Демо-данные для проверки графика, фильтров и страниц истории'),
        ),
      );
    }
  }

  Future<void> _seedDemoSleepLogs() async {
    await _database.deleteSleepLogsByIdPrefix('demo-sleep-');

    final today = _dateOnly(DateTime.now());
    const totalDays = 180;

    for (var day = totalDays, index = 0; day >= 0; day -= 3, index++) {
      final date = today.subtract(Duration(days: day));
      final weekdayShift = date.weekday >= DateTime.saturday ? 0.7 : 0.0;
      final wave = _demoWave(index, 0.73);
      final durationHours = (7.1 + weekdayShift + wave * 0.85).clamp(5.2, 9.4);
      final startHour = 23 + (_demoWave(index, 1.11) * 0.65);
      final startMinuteTotal = (startHour * 60).round();
      final sleepStart = DateTime(date.year, date.month, date.day)
          .add(Duration(minutes: startMinuteTotal));
      final sleepEnd =
          sleepStart.add(Duration(minutes: (durationHours * 60).round()));
      final quality = durationHours >= 7.2
          ? 4 + (wave > 0.45 ? 1 : 0)
          : durationHours < 6.2
              ? 2
              : 3;

      await _database.saveSleepLog(
        SleepLogEntriesCompanion.insert(
          id: 'demo-sleep-$index',
          date: date,
          sleepStart: Value(sleepStart),
          sleepEnd: Value(sleepEnd),
          quality: Value(quality.clamp(1, 5).toInt()),
          comment: const Value('Демо-запись сна для проверки графика'),
        ),
      );
    }
  }

  Future<void> _seedDemoWeightLogs() async {
    await _database.deleteWeightLogsByIdPrefix('demo-weight-');

    final today = _dateOnly(DateTime.now());
    const totalDays = 180;
    var latestWeight = _userProfile?.weightKg ?? 76.0;

    for (var day = totalDays, index = 0; day >= 0; day -= 7, index++) {
      final progress = 1 - day / totalDays;
      final date = today.subtract(Duration(days: day));
      final wave = _demoWave(index, 0.91) * 0.65;
      final weight = (78.4 - progress * 3.2 + wave).clamp(52.0, 140.0);
      latestWeight = _roundDemo(weight);

      await _database.saveWeightLog(
        WeightLogEntriesCompanion.insert(
          id: 'demo-weight-$index',
          date: date,
          weightKg: latestWeight,
          comment: const Value('Демо-запись веса для проверки графика'),
        ),
      );
    }

    final profile = _userProfile;
    if (profile != null) {
      await _database.saveUserProfile(
        UserProfileEntriesCompanion.insert(
          id: profile.id,
          name: profile.name,
          age: const Value.absent(),
          birthDate: Value(profile.birthDate),
          weightKg: Value(latestWeight),
          heightCm: Value(profile.heightCm),
          sex: Value(profile.sex),
          diagnosis: Value(profile.diagnosis),
          avatarData: Value(profile.avatarData),
          createdAt: profile.createdAt,
        ),
      );
    }
  }

  Future<void> _seedDemoMedicationIntakes() async {
    await _database.deleteMedicationIntakesByIdPrefix('demo-intake-');

    final plans = await _database.getMedicationPlans();
    if (plans.isEmpty) {
      return;
    }

    final plan = plans.first;
    final today = _dateOnly(DateTime.now());
    const totalDays = 180;
    for (var day = totalDays, index = 0; day >= 0; day--, index++) {
      if (index % 13 == 0 || index % 29 == 0) {
        continue;
      }
      final date = today.subtract(Duration(days: day));
      final routineDrift = index < 55 ? 28 : (index < 120 ? 12 : 4);
      final waveOffset = (((index * 19) % 61) - 30);
      final occasionalDelay = index % 17 == 0 ? 45 : 0;
      final earlyCorrection = index > 130 && index % 9 == 0 ? -18 : 0;
      final offsetMinutes =
          routineDrift + waveOffset + occasionalDelay + earlyCorrection;
      final takenAt = DateTime(
        date.year,
        date.month,
        date.day,
        plan.intakeTime.hour,
        plan.intakeTime.minute,
      ).add(Duration(minutes: offsetMinutes));

      await _database.saveMedicationIntake(
        MedicationIntakeEntriesCompanion.insert(
          id: 'demo-intake-$index',
          planId: plan.id,
          date: date,
          takenAt: Value(takenAt),
          taken: true,
          countsForStreak: Value(date == today),
        ),
      );
    }
  }
}

double _demoWave(int index, double speed) {
  final value = ((index * 37 * speed) % 100) / 100;
  return (value - 0.5) * 2;
}

double _roundDemo(num value) => (value * 10).roundToDouble() / 10;

UserProfile _userProfileFromRow(UserProfileEntry row) {
  return UserProfile(
    id: row.id,
    name: row.name,
    age: row.age,
    birthDate: row.birthDate,
    weightKg: row.weightKg,
    heightCm: row.heightCm,
    sex: row.sex,
    diagnosis: row.diagnosis,
    avatarData: row.avatarData,
    createdAt: row.createdAt,
  );
}

SleepLog _sleepLogFromRow(SleepLogEntry row) {
  return SleepLog(
    id: row.id,
    date: row.date,
    sleepStart: row.sleepStart,
    sleepEnd: row.sleepEnd,
    quality: row.quality,
    comment: row.comment,
  );
}

WeightLog _weightLogFromRow(WeightLogEntry row) {
  return WeightLog(
    id: row.id,
    date: row.date,
    weightKg: row.weightKg,
    comment: row.comment,
  );
}

MedicationIntake _medicationIntakeFromRow(MedicationIntakeEntry row) {
  return MedicationIntake(
    id: row.id,
    planId: row.planId,
    date: row.date,
    takenAt: row.takenAt,
    taken: row.taken,
    countsForStreak: row.countsForStreak,
  );
}

LabResult _labFromRow(LabResultEntry row) {
  return LabResult(
    id: row.id,
    date: row.date,
    tsh: row.tsh,
    freeT4: row.freeT4,
    freeT3: row.freeT3,
    comment: row.comment,
  );
}

MedicationPlan _medicationPlanFromRow(MedicationPlanEntry row) {
  return MedicationPlan(
    id: row.id,
    name: row.name,
    dosage: row.dosage,
    intakeTime: row.intakeTime,
    note: row.note,
  );
}

DoctorVisit _doctorVisitFromRow(DoctorVisitEntry row) {
  return DoctorVisit(
    id: row.id,
    date: row.date,
    doctorName: row.doctorName,
    specialization: row.specialization,
    recommendations: row.recommendations,
    nextControlDate: row.nextControlDate,
  );
}

MedicalMedia _medicalMediaFromRow(MedicalMediaEntry row) {
  return MedicalMedia(
    id: row.id,
    title: row.title,
    category: MedicalMediaCategory.values.firstWhere(
      (category) => category.name == row.category,
      orElse: () => MedicalMediaCategory.other,
    ),
    data: row.data,
    mimeType: row.mimeType,
    comment: row.comment,
    createdAt: row.createdAt,
  );
}
