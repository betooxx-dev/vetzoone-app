import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

class GetUpcomingAppointmentsUseCase {
  final AppointmentRepository repository;

  GetUpcomingAppointmentsUseCase(this.repository);

  Future<List<Appointment>> call(String userId, DateTime dateFrom, DateTime dateTo) async {
    try {
      return await repository.getUpcomingAppointmentsByUserId(
        userId,
        dateFrom,
        dateTo,
      );
    } catch (e) {
      throw Exception('Error getting upcoming appointments: $e');
    }
  }
}

class GetPastAppointmentsUseCase {
  final AppointmentRepository repository;

  GetPastAppointmentsUseCase(this.repository);

  Future<List<Appointment>> call(String userId, DateTime dateFrom, DateTime dateTo) async {
    try {
      return await repository.getUpcomingAppointmentsByUserId(
        userId,
        dateFrom,
        dateTo,
      );
    } catch (e) {
      throw Exception('Error getting past appointments: $e');
    }
  }
}

class GetAllAppointmentsUseCase {
  final AppointmentRepository repository;

  GetAllAppointmentsUseCase(this.repository);

  Future<List<Appointment>> call(String userId) async {
    try {
      return await repository.getAllAppointmentsByUserId(userId);
    } catch (e) {
      throw Exception('Error getting all appointments: $e');
    }
  }
}

class GetVetAppointmentsUseCase {
  final AppointmentRepository repository;

  GetVetAppointmentsUseCase(this.repository);

  Future<List<Appointment>> call(String vetId) async {
    try {
      return await repository.getAppointmentsByVetId(vetId);
    } catch (e) {
      throw Exception('Error getting vet appointments: $e');
    }
  }
} 