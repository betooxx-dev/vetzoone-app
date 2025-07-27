import 'lib/domain/entities/pet.dart';
import 'lib/core/constants/veterinary_constants.dart';

void main() {
  print('=== Prueba de nombres de tipos en PetCard ===');
  
  // Simular como se verían los tipos en las tarjetas
  for (PetType type in PetType.values) {
    final animalType = AnimalType.fromPetTypeCode(type.name);
    final displayName = animalType?.displayName ?? 'No mapeado';
    
    print('${type.name.padRight(10)} -> $displayName');
  }
}
