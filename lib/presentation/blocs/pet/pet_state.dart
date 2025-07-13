import 'package:equatable/equatable.dart';
import '../../../domain/entities/pet.dart';

abstract class PetState extends Equatable {
  const PetState();

  @override
  List<Object?> get props => [];
}

class PetInitial extends PetState {}

class PetLoading extends PetState {}

class PetsLoaded extends PetState {
  final List<Pet> pets;

  const PetsLoaded({required this.pets});

  @override
  List<Object?> get props => [pets];
}

class PetLoaded extends PetState {
  final Pet pet;

  const PetLoaded({required this.pet});

  @override
  List<Object?> get props => [pet];
}

class PetOperationSuccess extends PetState {
  final String message;

  const PetOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class PetError extends PetState {
  final String message;

  const PetError({required this.message});

  @override
  List<Object?> get props => [message];
}