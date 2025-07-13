import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/pet.dart';

abstract class PetEvent extends Equatable {
  const PetEvent();

  @override
  List<Object?> get props => [];
}

class LoadPetsEvent extends PetEvent {
  final String userId;

  const LoadPetsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddPetEvent extends PetEvent {
  final Pet pet;
  final File? imageFile;

  const AddPetEvent({required this.pet, this.imageFile});

  @override
  List<Object?> get props => [pet, imageFile];
}

class UpdatePetEvent extends PetEvent {
  final String petId;
  final Pet pet;
  final File? imageFile;

  const UpdatePetEvent({required this.petId, required this.pet, this.imageFile});

  @override
  List<Object?> get props => [petId, pet, imageFile];
}

class DeletePetEvent extends PetEvent {
  final String petId;

  const DeletePetEvent({required this.petId});

  @override
  List<Object?> get props => [petId];
}

class GetPetByIdEvent extends PetEvent {
  final String petId;

  const GetPetByIdEvent({required this.petId});

  @override
  List<Object?> get props => [petId];
}