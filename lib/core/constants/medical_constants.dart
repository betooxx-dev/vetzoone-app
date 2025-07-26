enum UrgencyLevel {
  LOW,
  MEDIUM,
  HIGH,
  EMERGENCY,
}

enum MedicalRecordStatus {
  DRAFT,
  FINAL,
}

enum TreatmentStatus {
  ACTIVE,
  COMPLETED,
  SUSPENDED,
}

class MedicalConstants {
  // Mapas para mostrar los textos en español
  static const Map<UrgencyLevel, String> urgencyLevelDisplayNames = {
    UrgencyLevel.LOW: 'Baja',
    UrgencyLevel.MEDIUM: 'Media',
    UrgencyLevel.HIGH: 'Alta',
    UrgencyLevel.EMERGENCY: 'Emergencia',
  };

  static const Map<MedicalRecordStatus, String> statusDisplayNames = {
    MedicalRecordStatus.DRAFT: 'Borrador',
    MedicalRecordStatus.FINAL: 'Final',
  };

  static const Map<TreatmentStatus, String> treatmentStatusDisplayNames = {
    TreatmentStatus.ACTIVE: 'Activo',
    TreatmentStatus.COMPLETED: 'Completado',
    TreatmentStatus.SUSPENDED: 'Suspendido',
  };

  // Métodos helper para conversión
  static UrgencyLevel urgencyLevelFromString(String level) {
    switch (level.toUpperCase()) {
      case 'LOW':
        return UrgencyLevel.LOW;
      case 'MEDIUM':
        return UrgencyLevel.MEDIUM;
      case 'HIGH':
        return UrgencyLevel.HIGH;
      case 'EMERGENCY':
        return UrgencyLevel.EMERGENCY;
      default:
        return UrgencyLevel.LOW;
    }
  }

  static String urgencyLevelToString(UrgencyLevel level) {
    return level.name;
  }

  static MedicalRecordStatus statusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return MedicalRecordStatus.DRAFT;
      case 'FINAL':
        return MedicalRecordStatus.FINAL;
      default:
        return MedicalRecordStatus.DRAFT;
    }
  }

  static String statusToString(MedicalRecordStatus status) {
    return status.name;
  }

  static TreatmentStatus treatmentStatusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return TreatmentStatus.ACTIVE;
      case 'COMPLETED':
        return TreatmentStatus.COMPLETED;
      case 'SUSPENDED':
        return TreatmentStatus.SUSPENDED;
      default:
        return TreatmentStatus.ACTIVE;
    }
  }

  static String treatmentStatusToString(TreatmentStatus status) {
    return status.name;
  }

  static String getUrgencyDisplayName(UrgencyLevel level) {
    return urgencyLevelDisplayNames[level] ?? level.name;
  }

  static String getStatusDisplayName(MedicalRecordStatus status) {
    return statusDisplayNames[status] ?? status.name;
  }

  static String getTreatmentStatusDisplayName(TreatmentStatus status) {
    return treatmentStatusDisplayNames[status] ?? status.name;
  }

  // Lista de opciones para dropdowns
  static List<UrgencyLevel> get urgencyLevels => UrgencyLevel.values;
  static List<MedicalRecordStatus> get statusOptions => MedicalRecordStatus.values;
  static List<TreatmentStatus> get treatmentStatusOptions => TreatmentStatus.values;
} 