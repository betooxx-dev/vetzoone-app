import 'package:equatable/equatable.dart';

class Vaccination extends Equatable {
  final String id;
  final String petId;
  final String vetId;
  final String vaccineName;
  final String manufacturer;
  final String batchNumber;
  final DateTime administeredDate;
  final DateTime nextDueDate;
  final String? notes;

  const Vaccination({
    required this.id,
    required this.petId,
    required this.vetId,
    required this.vaccineName,
    required this.manufacturer,
    required this.batchNumber,
    required this.administeredDate,
    required this.nextDueDate,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        petId,
        vetId,
        vaccineName,
        manufacturer,
        batchNumber,
        administeredDate,
        nextDueDate,
        notes,
      ];
}