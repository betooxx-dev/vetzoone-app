import 'package:equatable/equatable.dart';

enum PetType { 
  DOG, 
  CAT, 
  BIRD, 
  RABBIT, 
  HAMSTER, 
  FISH, 
  REPTILE, 
  OTHER 
}

enum PetGender { 
  MALE, 
  FEMALE, 
  UNKNOWN 
}

enum PetStatus { 
  HEALTHY, 
  TREATMENT, 
  ATTENTION 
}

class Pet extends Equatable {
  final String id;
  final String name;
  final PetType type;
  final String breed;
  final PetGender gender;
  final PetStatus? status;
  final String? description;
  final DateTime birthDate;
  final String? imageUrl;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.birthDate,
    required this.userId,
    this.status,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        breed,
        gender,
        status,
        description,
        birthDate,
        imageUrl,
        userId,
        createdAt,
        updatedAt,
      ];

  Pet copyWith({
    String? id,
    String? name,
    PetType? type,
    String? breed,
    PetGender? gender,
    PetStatus? status,
    String? description,
    DateTime? birthDate,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      description: description ?? this.description,
      birthDate: birthDate ?? this.birthDate,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}