import 'medical_record_model.dart';
import 'treatment_model.dart';

class MedicalRecordWithTreatmentsModel extends MedicalRecordModel {
  final List<TreatmentModel> treatments;

  const MedicalRecordWithTreatmentsModel({
    required super.id,
    required super.petId,
    required super.vetId,
    super.appointmentId,
    required super.visitDate,
    required super.chiefComplaint,
    required super.diagnosis,
    super.notes,
    required super.urgencyLevel,
    required super.status,
    required this.treatments,
  });

  factory MedicalRecordWithTreatmentsModel.fromJson(Map<String, dynamic> json) {
    final treatments = (json['treatments'] as List<dynamic>? ?? [])
        .map((treatmentJson) => TreatmentModel.fromJson(treatmentJson as Map<String, dynamic>))
        .toList();

    return MedicalRecordWithTreatmentsModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      vetId: json['vet_id'] as String,
      appointmentId: json['appointment_id'] as String?,
      visitDate: DateTime.parse(json['visit_date'] as String),
      chiefComplaint: json['chief_complaint'] as String,
      diagnosis: json['diagnosis'] as String,
      notes: json['notes'] as String?,
      urgencyLevel: json['urgency_level'] as String,
      status: json['status'] as String,
      treatments: treatments,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['treatments'] = treatments.map((treatment) => treatment.toJson()).toList();
    return json;
  }
} 