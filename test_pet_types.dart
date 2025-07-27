import 'lib/domain/entities/pet.dart';
import 'lib/core/constants/veterinary_constants.dart';

void main() {
  print('=== Prueba de conversión de tipos de mascotas ===');
  
  // Probamos todos los tipos de PetType
  for (PetType type in PetType.values) {
    final animalType = AnimalType.fromPetTypeCode(type.name);
    print('PetType.${type.name} -> ${animalType?.displayName ?? "No mapeado"}');
  }
  
  print('\n=== Todos los tipos de animales disponibles en el enum ===');
  print('AnimalType.allAnimalNames: ${AnimalType.allAnimalNames}');
  
  print('\n=== Solo mascotas domésticas ===');
  print('AnimalType.domesticPetNames: ${AnimalType.domesticPetNames}');
}
