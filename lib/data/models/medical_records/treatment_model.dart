class TreatmentModel {
  final String id;
  final String petId;
  final String medicalRecordId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final String instructions;
  final String status;
  final String vetId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TreatmentModel({
    required this.id,
    required this.petId,
    required this.medicalRecordId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.instructions,
    required this.status,
    required this.vetId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      medicalRecordId: json['medical_record_id'] as String,
      medicationName: json['medication_name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      durationDays: json['duration_days'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      instructions: json['instructions'] as String,
      status: json['status'] as String,
      vetId: json['vet_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'medical_record_id': medicalRecordId,
      'medication_name': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'duration_days': durationDays,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'instructions': instructions,
      'status': status,
      'vet_id': vetId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 