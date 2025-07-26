// Interfaces para servicios veterinarios y disponibilidad
class VetService {
  final String id;
  final String name;
  final double price;
  final int duration; // en minutos
  final String? description;
  final bool isActive;

  const VetService({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    this.description,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
      'is_active': isActive,
    };
  }

  factory VetService.fromJson(Map<String, dynamic> json) {
    return VetService(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class VetAvailability {
  final String day; // 'monday', 'tuesday', etc.
  final String startTime; // '09:00'
  final String endTime; // '17:00'

  const VetAvailability({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  factory VetAvailability.fromJson(Map<String, dynamic> json) {
    return VetAvailability(
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}

// DTO para actualizar disponibilidad del veterinario
class UpdateVetAvailabilityDto {
  final List<VetAvailability> availability;

  const UpdateVetAvailabilityDto({
    required this.availability,
  });

  Map<String, dynamic> toJson() {
    return {
      'availability': availability.map((e) => e.toJson()).toList(),
    };
  }
}

class VeterinaryConstants {
  // Mapeo de días en español a inglés para la API
  static const Map<String, String> dayMapping = {
    'monday': 'Lunes',
    'tuesday': 'Martes',
    'wednesday': 'Miércoles',
    'thursday': 'Jueves',
    'friday': 'Viernes',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  // Días de la semana en orden
  static const List<String> weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

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