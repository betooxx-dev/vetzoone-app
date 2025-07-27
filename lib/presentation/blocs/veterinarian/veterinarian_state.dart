import 'package:equatable/equatable.dart';
import '../../../domain/entities/veterinarian.dart';

// Modelo para la información de predicción de IA
class AIPrediction extends Equatable {
  final String originalQuery;
  final String predictedSpecialty;
  final double confidence;
  final String specialtyCode;

  const AIPrediction({
    required this.originalQuery,
    required this.predictedSpecialty,
    required this.confidence,
    required this.specialtyCode,
  });

  @override
  List<Object?> get props => [originalQuery, predictedSpecialty, confidence, specialtyCode];
}

abstract class VeterinarianState extends Equatable {
  const VeterinarianState();

  @override
  List<Object?> get props => [];
}

class VeterinarianInitial extends VeterinarianState {}

class VeterinarianLoading extends VeterinarianState {}

class VeterinarianSearchSuccess extends VeterinarianState {
  final List<Veterinarian> veterinarians;
  final AIPrediction? aiPrediction; // Nueva propiedad opcional

  const VeterinarianSearchSuccess(this.veterinarians, {this.aiPrediction});

  @override
  List<Object?> get props => [veterinarians, aiPrediction];
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