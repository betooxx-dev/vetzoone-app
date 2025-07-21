import 'package:equatable/equatable.dart';

class MedicalRecord extends Equatable {
  final String id;
  final String petId;
  final String vetId;
  final String? appointmentId;
  final DateTime visitDate;
  final String chiefComplaint;
  final String diagnosis;
  final String? notes;
  final String urgencyLevel;
  final String status;

  const MedicalRecord({
    required this.id,
    required this.petId,
    required this.vetId,
    this.appointmentId,
    required this.visitDate,
    required this.chiefComplaint,
    required this.diagnosis,
    this.notes,
    required this.urgencyLevel,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        petId,
        vetId,
        appointmentId,
        visitDate,
        chiefComplaint,
        diagnosis,
        notes,
        urgencyLevel,
        status,
      ];
}