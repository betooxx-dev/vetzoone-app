import 'package:equatable/equatable.dart';
import 'veterinarian.dart';
import 'pet.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}

class Appointment extends Equatable {
  final String id;
  final AppointmentStatus status;
  final String? notes;
  final DateTime appointmentDate;
  final String userId;
  final String vetId;
  final String petId;
  final DateTime createdAt;
  final Veterinarian? veterinarian;
  final Pet? pet;

  const Appointment({
    required this.id,
    required this.status,
    required this.appointmentDate,
    required this.userId,
    required this.vetId,
    required this.petId,
    required this.createdAt,
    this.notes,
    this.veterinarian,
    this.pet,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        notes,
        appointmentDate,
        userId,
        vetId,
        petId,
        createdAt,
        veterinarian,
        pet,
      ];

  Appointment copyWith({
    String? id,
    AppointmentStatus? status,
    String? notes,
    DateTime? appointmentDate,
    String? userId,
    String? vetId,
    String? petId,
    DateTime? createdAt,
    Veterinarian? veterinarian,
    Pet? pet,
  }) {
    return Appointment(
      id: id ?? this.id,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      userId: userId ?? this.userId,
      vetId: vetId ?? this.vetId,
      petId: petId ?? this.petId,
      createdAt: createdAt ?? this.createdAt,
      veterinarian: veterinarian ?? this.veterinarian,
      pet: pet ?? this.pet,
    );
  }
} 