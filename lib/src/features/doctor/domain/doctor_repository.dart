import 'doctor_visit.dart';

abstract interface class DoctorRepository {
  Future<List<DoctorVisit>> watchVisits();

  Future<void> save(DoctorVisit visit);

  Future<void> delete(String id);
}
