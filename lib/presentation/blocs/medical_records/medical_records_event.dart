import 'package:equatable/equatable.dart';

abstract class MedicalRecordsEvent extends Equatable {
  const MedicalRecordsEvent();

  @override
  List<Object> get props => [];
}

class LoadMedicalRecords extends MedicalRecordsEvent {
  final String petId;

  const LoadMedicalRecords(this.petId);

  @override
  List<Object> get props => [petId];
}

class LoadVaccinations extends MedicalRecordsEvent {
  final String petId;

  const LoadVaccinations(this.petId);

  @override
  List<Object> get props => [petId];
}

class LoadAllMedicalData extends MedicalRecordsEvent {
  final String petId;

  const LoadAllMedicalData(this.petId);

  @override
  List<Object> get props => [petId];
}