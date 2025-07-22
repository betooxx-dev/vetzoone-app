import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getUpcomingAppointmentsByUserId(
    String userId,
    DateTime dateFrom,
    DateTime dateTo,
  );
  Future<List<Appointment>> getAppointmentsByPetId(String petId);
  Future<List<Appointment>> getAllAppointmentsByUserId(String userId);
  Future<Appointment> getAppointmentById(String appointmentId);
} 