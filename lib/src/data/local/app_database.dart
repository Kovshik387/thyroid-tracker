import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class LabResultEntries extends Table {
  TextColumn get id => text()();

  DateTimeColumn get date => dateTime()();

  RealColumn get tsh => real().nullable()();

  RealColumn get freeT4 => real().nullable()();

  RealColumn get freeT3 => real().nullable()();

  TextColumn get comment => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class DoctorVisitEntries extends Table {
  TextColumn get id => text()();

  DateTimeColumn get date => dateTime()();

  TextColumn get doctorName => text().nullable()();

  TextColumn get specialization => text().nullable()();

  TextColumn get recommendations => text().nullable()();

  DateTimeColumn get nextControlDate => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MedicationPlanEntries extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get dosage => text()();

  DateTimeColumn get intakeTime => dateTime()();

  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MedicationIntakeEntries extends Table {
  TextColumn get id => text()();

  TextColumn get planId => text()();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get takenAt => dateTime().nullable()();

  BoolColumn get taken => boolean()();

  BoolColumn get countsForStreak =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettingEntries extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class UserProfileEntries extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  IntColumn get age => integer().nullable()();

  DateTimeColumn get birthDate => dateTime().nullable()();

  RealColumn get weightKg => real().nullable()();

  RealColumn get heightCm => real().nullable()();

  TextColumn get sex => text().nullable()();

  TextColumn get diagnosis => text().nullable()();

  TextColumn get avatarData => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MedicalMediaEntries extends Table {
  TextColumn get id => text()();

  TextColumn get title => text().nullable()();

  TextColumn get category => text()();

  TextColumn get data => text()();

  TextColumn get mimeType => text().nullable()();

  TextColumn get comment => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SleepLogEntries extends Table {
  TextColumn get id => text()();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get sleepStart => dateTime().nullable()();

  DateTimeColumn get sleepEnd => dateTime().nullable()();

  IntColumn get quality => integer().nullable()();

  TextColumn get comment => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class WeightLogEntries extends Table {
  TextColumn get id => text()();

  DateTimeColumn get date => dateTime()();

  RealColumn get weightKg => real()();

  TextColumn get comment => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LabResultEntries,
    DoctorVisitEntries,
    MedicationPlanEntries,
    MedicationIntakeEntries,
    AppSettingEntries,
    UserProfileEntries,
    MedicalMediaEntries,
    SleepLogEntries,
    WeightLogEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: 'thyroid_tracker',
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.dart.js'),
                ),
                native: const DriftNativeOptions(
                  shareAcrossIsolates: true,
                ),
              ),
        );

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(appSettingEntries);
          }
          if (from < 3) {
            await m.createTable(userProfileEntries);
          }
          if (from < 4) {
            await m.addColumn(
                userProfileEntries, userProfileEntries.avatarData);
          }
          if (from < 5) {
            await m.createTable(medicalMediaEntries);
          }
          if (from < 6) {
            await m.addColumn(userProfileEntries, userProfileEntries.birthDate);
          }
          if (from < 7) {
            await m.createTable(sleepLogEntries);
          }
          if (from < 8) {
            await m.createTable(weightLogEntries);
          }
          if (from < 9) {
            await m.addColumn(
                medicationIntakeEntries, medicationIntakeEntries.takenAt);
            await m.addColumn(
              medicationIntakeEntries,
              medicationIntakeEntries.countsForStreak,
            );
          }
        },
      );

  Future<List<LabResultEntry>> getLabResults() {
    return (select(labResultEntries)
          ..orderBy([(table) => OrderingTerm.asc(table.date)]))
        .get();
  }

  Future<List<DoctorVisitEntry>> getDoctorVisits() {
    return (select(doctorVisitEntries)
          ..orderBy([(table) => OrderingTerm.desc(table.date)]))
        .get();
  }

  Future<List<MedicationPlanEntry>> getMedicationPlans() {
    return select(medicationPlanEntries).get();
  }

  Future<List<MedicationIntakeEntry>> getMedicationIntakes() {
    return select(medicationIntakeEntries).get();
  }

  Future<Map<String, String>> getSettings() async {
    final rows = await select(appSettingEntries).get();
    return {
      for (final row in rows) row.key: row.value,
    };
  }

  Future<UserProfileEntry?> getUserProfile() {
    return select(userProfileEntries).getSingleOrNull();
  }

  Future<List<MedicalMediaEntry>> getMedicalMedia() {
    return (select(medicalMediaEntries)
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
  }

  Future<List<SleepLogEntry>> getSleepLogs() {
    return (select(sleepLogEntries)
          ..orderBy([(table) => OrderingTerm.desc(table.date)]))
        .get();
  }

  Future<List<WeightLogEntry>> getWeightLogs() {
    return (select(weightLogEntries)
          ..orderBy([(table) => OrderingTerm.desc(table.date)]))
        .get();
  }

  Future<void> saveLabResult(LabResultEntriesCompanion entry) {
    return into(labResultEntries).insertOnConflictUpdate(entry);
  }

  Future<void> saveDoctorVisit(DoctorVisitEntriesCompanion entry) {
    return into(doctorVisitEntries).insertOnConflictUpdate(entry);
  }

  Future<void> saveMedicationPlan(MedicationPlanEntriesCompanion entry) {
    return into(medicationPlanEntries).insertOnConflictUpdate(entry);
  }

  Future<void> saveMedicationIntake(MedicationIntakeEntriesCompanion entry) {
    return into(medicationIntakeEntries).insertOnConflictUpdate(entry);
  }

  Future<void> saveSetting(String key, String value) {
    return into(appSettingEntries).insertOnConflictUpdate(
      AppSettingEntriesCompanion.insert(key: key, value: value),
    );
  }

  Future<void> saveUserProfile(UserProfileEntriesCompanion entry) {
    return into(userProfileEntries).insertOnConflictUpdate(entry);
  }

  Future<void> saveMedicalMedia(MedicalMediaEntriesCompanion entry) {
    return into(medicalMediaEntries).insertOnConflictUpdate(entry);
  }

  Future<void> saveSleepLog(SleepLogEntriesCompanion entry) {
    return into(sleepLogEntries).insertOnConflictUpdate(entry);
  }

  Future<void> saveWeightLog(WeightLogEntriesCompanion entry) {
    return into(weightLogEntries).insertOnConflictUpdate(entry);
  }

  Future<void> deleteLabResult(String id) {
    return (delete(labResultEntries)..where((row) => row.id.equals(id))).go();
  }

  Future<void> deleteLabResultsByIdPrefix(String prefix) {
    return (delete(labResultEntries)..where((row) => row.id.like('$prefix%')))
        .go();
  }

  Future<void> deleteMedicalMedia(String id) {
    return (delete(medicalMediaEntries)..where((row) => row.id.equals(id)))
        .go();
  }

  Future<void> deleteSleepLog(String id) {
    return (delete(sleepLogEntries)..where((row) => row.id.equals(id))).go();
  }

  Future<void> deleteSleepLogsByIdPrefix(String prefix) {
    return (delete(sleepLogEntries)..where((row) => row.id.like('$prefix%')))
        .go();
  }

  Future<void> deleteWeightLog(String id) {
    return (delete(weightLogEntries)..where((row) => row.id.equals(id))).go();
  }

  Future<void> deleteWeightLogsByIdPrefix(String prefix) {
    return (delete(weightLogEntries)..where((row) => row.id.like('$prefix%')))
        .go();
  }

  Future<void> deleteMedicationPlan(String id) {
    return transaction(() async {
      await (delete(medicationIntakeEntries)
            ..where((row) => row.planId.equals(id)))
          .go();
      await (delete(medicationPlanEntries)..where((row) => row.id.equals(id)))
          .go();
    });
  }

  Future<void> deleteMedicationIntakesByIdPrefix(String prefix) {
    return (delete(medicationIntakeEntries)
          ..where((row) => row.id.like('$prefix%')))
        .go();
  }

  Future<void> resetAll() {
    return transaction(() async {
      await delete(medicationIntakeEntries).go();
      await delete(medicationPlanEntries).go();
      await delete(doctorVisitEntries).go();
      await delete(labResultEntries).go();
      await delete(medicalMediaEntries).go();
      await delete(sleepLogEntries).go();
      await delete(weightLogEntries).go();
      await delete(appSettingEntries).go();
      await delete(userProfileEntries).go();
    });
  }
}
