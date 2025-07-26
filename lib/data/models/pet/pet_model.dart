import '../../../domain/entities/pet.dart';
import '../../../domain/entities/medical_record.dart';
import '../medical_records/medical_record_model.dart';

class PetModel extends Pet {
  const PetModel({
    required super.id,
    required super.name,
    required super.type,
    required super.breed,
    required super.gender,
    required super.birthDate,
    required super.userId,
    super.status,
    super.description,
    super.imageUrl,
    super.createdAt,
    super.updatedAt,
    super.medicalRecords,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    print('🐕 PARSEANDO PET JSON: ${json.keys}');
    print('🏥 Medical Records en JSON: ${json['medical_records']}');
    print('🗓️ Birth date fields: birthDate=${json['birthDate']}, birth_date=${json['birth_date']}');
    
    // Parsear medical records si existen
    List<MedicalRecord>? medicalRecords;
    if (json['medical_records'] != null) {
      print('📝 Parseando ${(json['medical_records'] as List).length} medical records...');
      try {
        medicalRecords = (json['medical_records'] as List)
            .map((recordJson) {
              print('📋 Parseando record: $recordJson');
              return MedicalRecordModel.fromJson(recordJson as Map<String, dynamic>);
            })
            .toList();
        print('✅ Medical records parseados exitosamente: ${medicalRecords.length}');
      } catch (e) {
        print('❌ Error parseando medical records: $e');
        medicalRecords = [];
      }
    } else {
      print('⚠️ No hay medical_records en el JSON del pet');
      medicalRecords = null;
    }

    return PetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: _parsePetType(json['type'] ?? 'OTHER'),
      breed: json['breed'] ?? '',
      gender: _parsePetGender(json['gender'] ?? 'UNKNOWN'),
      status: _parsePetStatus(json['status']),
      description: json['description'],
      birthDate: _parseBirthDate(json),
      imageUrl: json['image_url'],
      userId: json['user_id'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      medicalRecords: medicalRecords,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'name': name,
      'type': _getBackendPetType(type),
      'breed': breed,
      'gender': _getBackendGender(gender),
      'birthDate': birthDate.toIso8601String(),
      'user_id': userId,
    };

    if (status != null) {
      json['status'] = _getBackendStatus(status!);
    }

    if (description != null && description!.isNotEmpty) {
      json['description'] = description!;
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      json['image_url'] = imageUrl!;
    }

    return json;
  }

  Map<String, dynamic> toCreateJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'type': _getBackendPetType(type),
      'breed': breed,
      'gender': _getBackendGender(gender),
      'status': _getBackendStatus(status ?? PetStatus.HEALTHY),
      'birthDate': birthDate.toIso8601String(),
      'user_id': userId,
    };

    if (description != null && description!.isNotEmpty) {
      json['description'] = description!;
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      json['image_url'] = imageUrl!;
    }

    print('📤 Pet JSON to send: $json');
    return json;
  }

  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'type': _getBackendPetType(type),
      'breed': breed,
      'gender': _getBackendGender(gender),
      'birthDate': birthDate.toIso8601String(),
      'user_id': userId,
    };

    if (status != null) {
      json['status'] = _getBackendStatus(status!);
    }

    if (description != null && description!.isNotEmpty) {
      json['description'] = description!;
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      json['image_url'] = imageUrl!;
    }

    print('📤 Pet Update JSON to send: $json');
    return json;
  }

  static String _getBackendPetType(PetType type) {
    switch (type) {
      case PetType.DOG:
        return 'dog';
      case PetType.CAT:
        return 'cat';
      case PetType.BIRD:
        return 'bird';
      case PetType.RABBIT:
        return 'rabbit';
      case PetType.HAMSTER:
        return 'other';
      case PetType.FISH:
        return 'fish';
      case PetType.REPTILE:
        return 'exotic';
      case PetType.OTHER:
        return 'other';
    }
  }

  static String _getBackendGender(PetGender gender) {
    switch (gender) {
      case PetGender.MALE:
        return 'male';
      case PetGender.FEMALE:
        return 'female';
      case PetGender.UNKNOWN:
        return 'unknown';
    }
  }

  static String _getBackendStatus(PetStatus status) {
    switch (status) {
      case PetStatus.HEALTHY:
        return 'healthy';
      case PetStatus.TREATMENT:
        return 'treatment';
      case PetStatus.ATTENTION:
        return 'attention';
    }
  }

  static PetType _parsePetType(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
        return PetType.DOG;
      case 'cat':
        return PetType.CAT;
      case 'bird':
        return PetType.BIRD;
      case 'rabbit':
        return PetType.RABBIT;
      case 'fish':
        return PetType.FISH;
      case 'exotic':
        return PetType.REPTILE;
      case 'other':
        return PetType.OTHER;
      default:
        return PetType.OTHER;
    }
  }

  static PetGender _parsePetGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return PetGender.MALE;
      case 'female':
        return PetGender.FEMALE;
      case 'unknown':
        return PetGender.UNKNOWN;
      default:
        return PetGender.UNKNOWN;
    }
  }

  static PetStatus? _parsePetStatus(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase()) {
      case 'healthy':
        return PetStatus.HEALTHY;
      case 'treatment':
        return PetStatus.TREATMENT;
      case 'attention':
        return PetStatus.ATTENTION;
      default:
        return PetStatus.HEALTHY;
    }
  }

  static DateTime _parseBirthDate(Map<String, dynamic> json) {
    // Try different possible field names for birth date
    final possibleFields = ['birthDate', 'birth_date', 'dateOfBirth', 'date_of_birth'];
    
    for (final field in possibleFields) {
      if (json[field] != null) {
        try {
          return DateTime.parse(json[field]);
        } catch (e) {
          print('⚠️ Error parsing date from field $field: ${json[field]}');
          continue;
        }
      }
    }
    
    // Fallback to current date if no valid birth date found
    print('⚠️ No valid birth date found in JSON, using current date');
    return DateTime.now();
  }
}