import '../../../domain/entities/medical_record.dart';

class MedicalRecordModel extends MedicalRecord {
  const MedicalRecordModel({
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
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'vet_id': vetId,
      'appointment_id': appointmentId,
      'visit_date': visitDate.toIso8601String(),
      'chief_complaint': chiefComplaint,
      'diagnosis': diagnosis,
      'notes': notes,
      'urgency_level': urgencyLevel,
      'status': status,
    };
  }
}