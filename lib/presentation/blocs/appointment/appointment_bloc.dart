import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/appointment/get_upcoming_appointments_usecase.dart';
import '../../../domain/usecases/appointment/get_upcoming_appointments_usecase.dart' show GetPastAppointmentsUseCase, GetAllAppointmentsUseCase;
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final GetUpcomingAppointmentsUseCase getUpcomingAppointmentsUseCase;
  final GetPastAppointmentsUseCase getPastAppointmentsUseCase;
  final GetAllAppointmentsUseCase getAllAppointmentsUseCase;

  AppointmentBloc({
    required this.getUpcomingAppointmentsUseCase,
    required this.getPastAppointmentsUseCase,
    required this.getAllAppointmentsUseCase,
  }) : super(const AppointmentsOverviewState()) {
    on<LoadUpcomingAppointmentsEvent>(_onLoadUpcomingAppointments);
    on<LoadPastAppointmentsEvent>(_onLoadPastAppointments);
    on<LoadAllAppointmentsEvent>(_onLoadAllAppointments);
  }

  Future<void> _onLoadUpcomingAppointments(
    LoadUpcomingAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state is AppointmentsOverviewState ? state as AppointmentsOverviewState : const AppointmentsOverviewState();
    emit(current.copyWith(loadingUpcoming: true, errorUpcoming: null));
    try {
      final appointments = await getUpcomingAppointmentsUseCase(
        event.userId,
        event.dateFrom,
        event.dateTo,
      );
      print('🔵 [Bloc] Respuesta próximas citas:  [1m${appointments.length} citas');
      emit(current.copyWith(upcoming: appointments, loadingUpcoming: false, errorUpcoming: null));
    } catch (error) {
      print('🔴 [Bloc] Error próximas citas: $error');
      emit(current.copyWith(loadingUpcoming: false, errorUpcoming: error.toString()));
    }
  }

  Future<void> _onLoadPastAppointments(
    LoadPastAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state is AppointmentsOverviewState ? state as AppointmentsOverviewState : const AppointmentsOverviewState();
    emit(current.copyWith(loadingPast: true, errorPast: null));
    try {
      final pastAppointments = await getPastAppointmentsUseCase(
        event.userId,
        event.dateFrom,
        event.dateTo,
      );
      print('🟠 [Bloc] Respuesta citas pasadas: ${pastAppointments.length} citas');
      emit(current.copyWith(past: pastAppointments, loadingPast: false, errorPast: null));
    } catch (error) {
      print('🔴 [Bloc] Error citas pasadas: $error');
      emit(current.copyWith(loadingPast: false, errorPast: error.toString()));
    }
  }

  Future<void> _onLoadAllAppointments(
    LoadAllAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state is AppointmentsOverviewState ? state as AppointmentsOverviewState : const AppointmentsOverviewState();
    emit(current.copyWith(loadingAll: true, errorAll: null));
    try {
      final appointments = await getAllAppointmentsUseCase.repository.getAllAppointmentsByUserId(event.userId);
      print('🟢 [Bloc] Respuesta todas las citas: ${appointments.length} citas');
      emit(current.copyWith(all: appointments, loadingAll: false, errorAll: null));
    } catch (error) {
      print('🔴 [Bloc] Error todas las citas: $error');
      emit(current.copyWith(loadingAll: false, errorAll: error.toString()));
    }
  }
} 