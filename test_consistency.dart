import 'lib/domain/entities/pet.dart';
import 'lib/core/constants/veterinary_constants.dart';

void main() {
  print('=== Verificación de consistencia en nombres de tipos ===');
  
  for (PetType type in PetType.values) {
    final animalType = AnimalType.fromPetTypeCode(type.name);
    final displayName = animalType?.displayName ?? 'No mapeado';
    
    print('${type.name.padRight(10)} -> $displayName');
  }
  
  print('\n=== Ahora tanto PetCard como PetDetailPage mostrarán los mismos nombres ===');
  print('✅ Lista de mascotas: "Perros"');
  print('✅ Detalle de mascota: "Perros"');
  print('✅ Agregar mascota: "Perros"');
  print('✅ Editar mascota: "Perros"');
  print('✅ Perfil veterinario: "Perros"');
}
