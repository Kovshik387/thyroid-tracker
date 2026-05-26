enum MedicalMediaCategory {
  ultrasound,
  ecg,
  labs,
  conclusion,
  other,
}

class MedicalMedia {
  const MedicalMedia({
    required this.id,
    required this.data,
    required this.category,
    required this.createdAt,
    this.title,
    this.mimeType,
    this.comment,
  });

  final String id;
  final String data;
  final MedicalMediaCategory category;
  final DateTime createdAt;
  final String? title;
  final String? mimeType;
  final String? comment;
}
