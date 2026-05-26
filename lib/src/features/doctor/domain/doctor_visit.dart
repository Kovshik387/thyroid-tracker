class DoctorVisit {
  const DoctorVisit({
    required this.id,
    required this.date,
    this.doctorName,
    this.specialization,
    this.recommendations,
    this.nextControlDate,
  });

  final String id;
  final DateTime date;
  final String? doctorName;
  final String? specialization;
  final String? recommendations;
  final DateTime? nextControlDate;
}
