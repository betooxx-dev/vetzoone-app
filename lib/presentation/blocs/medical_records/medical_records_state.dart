import 'package:equatable/equatable.dart';
import '../../../domain/entities/medical_record.dart';
import '../../../domain/entities/vaccination.dart';

abstract class MedicalRecordsState extends Equatable {
  const MedicalRecordsState();

  @override
  List<Object> get props => [];
}

class MedicalRecordsInitial extends MedicalRecordsState {}

class MedicalRecordsLoading extends MedicalRecordsState {}

class MedicalRecordsLoaded extends MedicalRecordsState {
  final List<MedicalRecord> medicalRecords;

  const MedicalRecordsLoaded(this.medicalRecords);

  @override
  List<Object> get props => [medicalRecords];
}

class VaccinationsLoading extends MedicalRecordsState {}

class VaccinationsLoaded extends MedicalRecordsState {
  final List<Vaccination> vaccinations;

  const VaccinationsLoaded(this.vaccinations);

  @override
  List<Object> get props => [vaccinations];
}

class MedicalRecordsAndVaccinationsLoaded extends MedicalRecordsState {
  final List<MedicalRecord> medicalRecords;
  final List<Vaccination> vaccinations;

  const MedicalRecordsAndVaccinationsLoaded({
    required this.medicalRecords,
    required this.vaccinations,
  });

  @override
  List<Object> get props => [medicalRecords, vaccinations];
}

class MedicalRecordsError extends MedicalRecordsState {
  final String message;

  const MedicalRecordsError(this.message);

  @override
  List<Object> get props => [message];
}