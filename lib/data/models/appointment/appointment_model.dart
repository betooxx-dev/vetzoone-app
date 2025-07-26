import '../../../domain/entities/appointment.dart';
import '../veterinarian/veterinarian_model.dart';
import '../pet/pet_model.dart';
import '../auth/user_model.dart';

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
    super.veterinarian,
    super.pet,
    super.user,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing JSON: $json');
    
    try {
      final appointment = AppointmentModel(
        id: json['id']?.toString() ?? '',
        status: _parseAppointmentStatus(json['status']?.toString() ?? 'pending'),
        notes: json['notes']?.toString(),
        appointmentDate: _parseDateTime(json['appointmentDate']),
        userId: json['user_id']?.toString() ?? '',
        vetId: json['vet_id']?.toString() ?? '',
        petId: json['pet_id']?.toString() ?? '',
        createdAt: _parseDateTime(json['created_at']),
        veterinarian: json['vet'] != null ? VeterinarianModel.fromJson(json['vet']) : null,
        pet: json['pet'] != null ? PetModel.fromJson(json['pet']) : null,
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      );
      
      print('✅ Appointment parseado exitosamente: ${appointment.id}');
      if (appointment.veterinarian != null) {
        print('✅ Veterinario incluido: ${appointment.veterinarian!.fullName}');
      }
      if (appointment.user != null) {
        print('✅ Usuario incluido: ${appointment.user!.fullName}');
      }
      return appointment;
    } catch (e) {
      print('❌ Error parseando appointment: $e');
      rethrow;
    }
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      } else {
        print('⚠️ Formato de fecha inesperado: $dateValue');
        return DateTime.now();
      }
    } catch (e) {
      print('❌ Error parseando fecha: $dateValue - $e');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'status': _getBackendStatus(status),
      'notes': notes,
      'appointmentDate': appointmentDate.toIso8601String(),
      'user_id': userId,
      'vet_id': vetId,
      'pet_id': petId,
      'created_at': createdAt.toIso8601String(),
    };

    if (veterinarian != null) {
      json['vet'] = (veterinarian as VeterinarianModel).toJson();
    }

    if (pet != null) {
      json['pet'] = (pet as PetModel).toJson();
    }

    if (user != null) {
      json['user'] = (user as UserModel).toJson();
    }

    return json;
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