import '../../../domain/entities/vaccination.dart';

class VaccinationModel extends Vaccination {
  const VaccinationModel({
    required super.id,
    required super.petId,
    required super.vetId,
    required super.vaccineName,
    required super.manufacturer,
    required super.batchNumber,
    required super.administeredDate,
    required super.nextDueDate,
    super.notes,
  });

  factory VaccinationModel.fromJson(Map<String, dynamic> json) {
    return VaccinationModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      vetId: json['vet_id'] as String,
      vaccineName: json['vaccine_name'] as String,
      manufacturer: json['manufacturer'] as String,
      batchNumber: json['batch_number'] as String,
      administeredDate: DateTime.parse(json['administered_date'] as String),
      nextDueDate: DateTime.parse(json['next_due_date'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'vet_id': vetId,
      'vaccine_name': vaccineName,
      'manufacturer': manufacturer,
      'batch_number': batchNumber,
      'administered_date': administeredDate.toIso8601String().split('T')[0],
      'next_due_date': nextDueDate.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }
}