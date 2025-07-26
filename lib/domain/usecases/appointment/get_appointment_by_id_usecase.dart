import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

class GetAppointmentByIdUseCase {
  final AppointmentRepository repository;

  GetAppointmentByIdUseCase(this.repository);

  Future<Appointment> call(String appointmentId) async {
    return await repository.getAppointmentById(appointmentId);
  }
} 