import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment/appointment_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Appointment>> getUpcomingAppointmentsByUserId(
    String userId,
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    try {
      final appointmentModels = await remoteDataSource.getUpcomingAppointmentsByUserId(
        userId,
        dateFrom,
        dateTo,
      );
      return appointmentModels;
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<Appointment>> getAppointmentsByPetId(String petId) async {
    final models = await remoteDataSource.getAppointmentsByPetId(petId);
    return models;
  }

  @override
  Future<List<Appointment>> getAllAppointmentsByUserId(String userId) async {
    final models = await remoteDataSource.getAllAppointmentsByUserId(userId);
    return models;
  }

  @override
  Future<Appointment> getAppointmentById(String appointmentId) async {
    try {
      final model = await remoteDataSource.getAppointmentById(appointmentId);
      return model;
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<Appointment> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final appointmentModel = await remoteDataSource.createAppointment(appointmentData);
      return appointmentModel;
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
} 