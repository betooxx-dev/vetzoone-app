import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

class CreateAppointmentUseCase {
  final AppointmentRepository repository;

  CreateAppointmentUseCase({required this.repository});

  Future<Appointment> call(Map<String, dynamic> appointmentData) async {
    return await repository.createAppointment(appointmentData);
  }
} 