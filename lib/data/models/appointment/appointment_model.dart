import '../../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.status,
    required super.appointmentDate,
    required super.userId,
    required super.vetId,
    required super.petId,
    required super.createdAt,
    super.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      status: _parseAppointmentStatus(json['status'] ?? 'pending'),
      notes: json['notes'],
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.parse(json['appointmentDate'])
          : DateTime.now(),
      userId: json['user_id'] ?? '',
      vetId: json['vet_id'] ?? '',
      petId: json['pet_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': _getBackendStatus(status),
      'notes': notes,
      'appointmentDate': appointmentDate.toIso8601String(),
      'user_id': userId,
      'vet_id': vetId,
      'pet_id': petId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static AppointmentStatus _parseAppointmentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'in_progress':
      case 'inprogress':
        return AppointmentStatus.inProgress;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'rescheduled':
        return AppointmentStatus.rescheduled;
      default:
        return AppointmentStatus.pending;
    }
  }

  static String _getBackendStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.inProgress:
        return 'in_progress';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.rescheduled:
        return 'rescheduled';
    }
  }
} 