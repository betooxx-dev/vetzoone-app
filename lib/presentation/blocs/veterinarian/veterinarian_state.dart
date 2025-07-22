import 'package:equatable/equatable.dart';
import '../../../domain/entities/veterinarian.dart';

abstract class VeterinarianState extends Equatable {
  const VeterinarianState();

  @override
  List<Object?> get props => [];
}

class VeterinarianInitial extends VeterinarianState {}

class VeterinarianLoading extends VeterinarianState {}

class VeterinarianSearchSuccess extends VeterinarianState {
  final List<Veterinarian> veterinarians;

  const VeterinarianSearchSuccess(this.veterinarians);

  @override
  List<Object?> get props => [veterinarians];
}

class VeterinarianProfileLoaded extends VeterinarianState {
  final Veterinarian veterinarian;

  const VeterinarianProfileLoaded(this.veterinarian);

  @override
  List<Object?> get props => [veterinarian];
}

class VeterinarianError extends VeterinarianState {
  final String message;

  const VeterinarianError(this.message);

  @override
  List<Object?> get props => [message];
}

class FeaturedVeterinariansLoaded extends VeterinarianState {
  final List<Veterinarian> veterinarians;

  const FeaturedVeterinariansLoaded(this.veterinarians);

  @override
  List<Object?> get props => [veterinarians];
}