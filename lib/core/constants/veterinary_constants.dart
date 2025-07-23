class VeterinaryConstants {
  // Ciudades más importantes de Chiapas
  static const List<String> chiapasLocations = [
    'Todas las ubicaciones',
    'Tuxtla Gutiérrez',
    'San Cristóbal de las Casas',
    'Tapachula',
    'Comitán de Domínguez',
    'Palenque',
    'Ocosingo',
    'Villaflores',
    'Tonalá',
    'Chiapa de Corzo',
    'Pichucalco',
    'Yajalón',
    'Las Margaritas',
  ];

  // Especialidades veterinarias más comunes
  static const List<String> veterinarySpecialties = [
    'Todas las especialidades',
    'Medicina General',
    'Cirugía',
    'Cardiología Veterinaria',
    'Dermatología Veterinaria',
    'Oftalmología Veterinaria',
    'Neurología Veterinaria',
    'Oncología Veterinaria',
    'Ortopedia y Traumatología',
    'Medicina Interna',
    'Emergencias y Cuidados Intensivos',
    'Reproducción Animal',
    'Medicina de Animales Exóticos',
    'Nutrición Animal',
    'Patología Veterinaria',
    'Radiología Veterinaria',
  ];

  // Métodos helper
  static String? getLocationForApi(String location) {
    if (location == 'Todas las ubicaciones') return null;
    return location;
  }

  static String? getSpecialtyForApi(String specialty) {
    if (specialty == 'Todas las especialidades') return null;
    return specialty;
  }
} 