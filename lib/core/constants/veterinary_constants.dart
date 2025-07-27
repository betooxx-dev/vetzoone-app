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

  // 🤖 ESPECIALIDADES DEL MODELO DE IA - Coinciden exactamente con el entrenamiento
  // Estas son las 20 especialidades con las que se entrenó el modelo SVM
  static const List<VeterinarySpecialty> aiModelSpecialties = [
    VeterinarySpecialty.dermatologia,
    VeterinarySpecialty.cardiologia,
    VeterinarySpecialty.neurologia,
    VeterinarySpecialty.traumatologia,
    VeterinarySpecialty.medicinaInterna,
    VeterinarySpecialty.oftalmologia,
    VeterinarySpecialty.reproduccion,
    VeterinarySpecialty.medicinaPreventiva,
    VeterinarySpecialty.oncologia,
    VeterinarySpecialty.anestesiologia,
    VeterinarySpecialty.cirugia,
    VeterinarySpecialty.endocrinologia,
    VeterinarySpecialty.nefrologia,
    VeterinarySpecialty.gastroenterologia,
    VeterinarySpecialty.radiologia,
    VeterinarySpecialty.laboratorioClinico,
    VeterinarySpecialty.medicinaExotica,
    VeterinarySpecialty.odontologiaVeterinaria,
    VeterinarySpecialty.nutricion,
    VeterinarySpecialty.etologia,
  ];

  // Lista de especialidades para mostrar en el frontend (con "Todas las especialidades")
  static List<String> get veterinarySpecialties {
    List<String> specialties = ['Todas las especialidades'];
    specialties.addAll(aiModelSpecialties.map((s) => s.displayName));
    return specialties;
  }

  // Métodos helper
  static String? getLocationForApi(String location) {
    if (location == 'Todas las ubicaciones') return null;
    return location;
  }

  static String? getSpecialtyForApi(String specialty) {
    if (specialty == 'Todas las especialidades') return null;
    // 🤖 Convertir el nombre de display al código de IA
    return getSpecialtyCodeForAI(specialty);
  }

  // 🤖 Convierte el nombre mostrado al código del modelo de IA
  static String? getSpecialtyCodeForAI(String displayName) {
    try {
      final specialty = aiModelSpecialties.firstWhere(
        (s) => s.displayName == displayName,
      );
      return specialty.aiCode;
    } catch (e) {
      return null;
    }
  }

  // 🤖 Convierte el código del modelo de IA al nombre mostrado
  static String getDisplayNameFromAICode(String aiCode) {
    try {
      final specialty = aiModelSpecialties.firstWhere(
        (s) => s.aiCode == aiCode,
      );
      return specialty.displayName;
    } catch (e) {
      return aiCode.replaceAll('_', ' ').toTitleCase();
    }
  }
}

// 🤖 ENUM DE ESPECIALIDADES VETERINARIAS
// Coincide exactamente con las especialidades del modelo de IA entrenado
enum VeterinarySpecialty {
  dermatologia('dermatologia', 'Dermatología Veterinaria'),
  cardiologia('cardiologia', 'Cardiología Veterinaria'),
  neurologia('neurologia', 'Neurología Veterinaria'),
  traumatologia('traumatologia', 'Traumatología y Ortopedia'),
  medicinaInterna('medicina_interna', 'Medicina Interna'),
  oftalmologia('oftalmologia', 'Oftalmología Veterinaria'),
  reproduccion('reproduccion', 'Reproducción Animal'),
  medicinaPreventiva('medicina_preventiva', 'Medicina Preventiva'),
  oncologia('oncologia', 'Oncología Veterinaria'),
  anestesiologia('anestesiologia', 'Anestesiología Veterinaria'),
  cirugia('cirugia', 'Cirugía Veterinaria'),
  endocrinologia('endocrinologia', 'Endocrinología Veterinaria'),
  nefrologia('nefrologia', 'Nefrología Veterinaria'),
  gastroenterologia('gastroenterologia', 'Gastroenterología Veterinaria'),
  radiologia('radiologia', 'Radiología Veterinaria'),
  laboratorioClinico('laboratorio_clinico', 'Laboratorio Clínico'),
  medicinaExotica('medicina_exotica', 'Medicina de Animales Exóticos'),
  odontologiaVeterinaria('odontologia_veterinaria', 'Odontología Veterinaria'),
  nutricion('nutricion', 'Nutrición Animal'),
  etologia('etologia', 'Etología y Comportamiento Animal');

  const VeterinarySpecialty(this.aiCode, this.displayName);

  /// Código usado en el modelo de IA (coincide con Config.SPECIALTIES del notebook)
  final String aiCode;
  
  /// Nombre que se muestra al usuario en la interfaz
  final String displayName;
}

// Constantes para los días de la semana
class WeekDays {
  static const Map<String, String> dayNames = {
    'monday': 'Lunes',
    'tuesday': 'Martes', 
    'wednesday': 'Miércoles',
    'thursday': 'Jueves',
    'friday': 'Viernes',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  static const List<String> orderedDays = [
    'monday',
    'tuesday', 
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static String getDisplayName(String dayKey) {
    return dayNames[dayKey] ?? dayKey;
  }
}

// Constantes para horarios de trabajo
class WorkingHours {
  static const List<String> availableHours = [
    '06:00', '06:30', '07:00', '07:30', '08:00', '08:30', '09:00', '09:30',
    '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
    '18:00', '18:30', '19:00', '19:30', '20:00', '20:30', '21:00', '21:30',
    '22:00', '22:30', '23:00'
  ];

  static String formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      
      if (hour == 0) return '12:$minute AM';
      if (hour < 12) return '$hour:$minute AM';
      if (hour == 12) return '12:$minute PM';
      return '${hour - 12}:$minute PM';
    } catch (e) {
      return time;
    }
  }
}

// Extensión para convertir strings a TitleCase
extension StringExtension on String {
  String toTitleCase() {
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
} 