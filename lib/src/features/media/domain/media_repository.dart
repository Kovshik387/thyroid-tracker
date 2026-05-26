import 'medical_media.dart';

abstract interface class MediaRepository {
  Future<List<MedicalMedia>> watchAll();

  Future<void> save(MedicalMedia media);

  Future<void> delete(String id);
}
