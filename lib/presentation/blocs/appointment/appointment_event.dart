import 'package:equatable/equatable.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object> get props => [];
}

class LoadUpcomingAppointmentsEvent extends AppointmentEvent {
  final String userId;
  final DateTime dateFrom;
  final DateTime dateTo;

  const LoadUpcomingAppointmentsEvent({required this.userId, required this.dateFrom, required this.dateTo});

  @override
  List<Object> get props => [userId, dateFrom, dateTo];
}

class LoadPastAppointmentsEvent extends AppointmentEvent {
  final String userId;
  final DateTime dateFrom;
  final DateTime dateTo;

  const LoadPastAppointmentsEvent({required this.userId, required this.dateFrom, required this.dateTo});

  @override
  List<Object> get props => [userId, dateFrom, dateTo];
}

class LoadAllAppointmentsEvent extends AppointmentEvent {
  final String userId;
  const LoadAllAppointmentsEvent({required this.userId});
  @override
  List<Object> get props => [userId];
} 