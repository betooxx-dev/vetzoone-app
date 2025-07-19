import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class UpcomingAppointmentsLoaded extends AppointmentState {
  final List<Appointment> appointments;

  const UpcomingAppointmentsLoaded(this.appointments);

  @override
  List<Object> get props => [appointments];
}

class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError(this.message);

  @override
  List<Object> get props => [message];
}

class PastAppointmentsLoaded extends AppointmentState {
  final List<Appointment> appointments;
  const PastAppointmentsLoaded(this.appointments);
  @override
  List<Object> get props => [appointments];
}

class AllAppointmentsLoaded extends AppointmentState {
  final List<Appointment> appointments;
  const AllAppointmentsLoaded(this.appointments);
  @override
  List<Object> get props => [appointments];
}

class AppointmentsOverviewState extends AppointmentState {
  final List<Appointment> upcoming;
  final List<Appointment> past;
  final List<Appointment> all;
  final bool loadingUpcoming;
  final bool loadingPast;
  final bool loadingAll;
  final String? errorUpcoming;
  final String? errorPast;
  final String? errorAll;

  const AppointmentsOverviewState({
    this.upcoming = const [],
    this.past = const [],
    this.all = const [],
    this.loadingUpcoming = false,
    this.loadingPast = false,
    this.loadingAll = false,
    this.errorUpcoming,
    this.errorPast,
    this.errorAll,
  });

  AppointmentsOverviewState copyWith({
    List<Appointment>? upcoming,
    List<Appointment>? past,
    List<Appointment>? all,
    bool? loadingUpcoming,
    bool? loadingPast,
    bool? loadingAll,
    String? errorUpcoming,
    String? errorPast,
    String? errorAll,
  }) {
    return AppointmentsOverviewState(
      upcoming: upcoming ?? this.upcoming,
      past: past ?? this.past,
      all: all ?? this.all,
      loadingUpcoming: loadingUpcoming ?? this.loadingUpcoming,
      loadingPast: loadingPast ?? this.loadingPast,
      loadingAll: loadingAll ?? this.loadingAll,
      errorUpcoming: errorUpcoming,
      errorPast: errorPast,
      errorAll: errorAll,
    );
  }

  @override
  List<Object> get props => [upcoming, past, all, loadingUpcoming, loadingPast, loadingAll, errorUpcoming ?? '', errorPast ?? '', errorAll ?? ''];
} 