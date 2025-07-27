import '../../repositories/appointment_repository.dart';

class ConfirmAppointmentUseCase {
  final AppointmentRepository repository;

  ConfirmAppointmentUseCase({required this.repository});

  Future<void> call(String appointmentId) async {
    if (appointmentId.isEmpty) {
      throw Exception('ID de cita requerido');
    }

    try {
      await repository.confirmAppointment(appointmentId);
    } catch (e) {
      throw Exception('Error al confirmar la cita: $e');
    }
  }
}
