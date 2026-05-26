import 'lab_result.dart';

abstract interface class LabsRepository {
  Future<List<LabResult>> watchAll();

  Future<void> save(LabResult result);

  Future<void> delete(String id);
}
