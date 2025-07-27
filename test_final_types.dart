import 'lib/domain/entities/pet.dart';
import 'lib/core/constants/veterinary_constants.dart';

void main() {
  print('=== Prueba FINAL de tipos de mascotas actualizados ===');
  
  // Probamos todos los tipos de PetType actualizados
  for (PetType type in PetType.values) {
    final animalType = AnimalType.fromPetTypeCode(type.name);
    print('PetType.${type.name} -> ${animalType?.displayName ?? "No mapeado"}');
  }
  
  print('\n=== Todos los tipos de animales para veterinarios ===');
  print('AnimalType.allAnimalNames: ${AnimalType.allAnimalNames}');
  
  print('\n=== Solo mascotas domésticas ===');
  print('AnimalType.domesticPetNames: ${AnimalType.domesticPetNames}');
  
  print('\n=== Animales especiales (granja, exóticos, etc.) ===');
  print('AnimalType.specialPetNames: ${AnimalType.specialPetNames}');
}
