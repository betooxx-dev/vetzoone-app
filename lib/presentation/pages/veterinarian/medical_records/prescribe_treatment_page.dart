import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/medical_constants.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../data/models/medical_records/treatment_model.dart';
import '../../../../domain/entities/appointment.dart' as domain;

class PrescribeTreatmentPage extends StatefulWidget {
  final TreatmentModel? treatmentToEdit;

  const PrescribeTreatmentPage({super.key, this.treatmentToEdit});

  @override
  State<PrescribeTreatmentPage> createState() => _PrescribeTreatmentPageState();
}

class _PrescribeTreatmentPageState extends State<PrescribeTreatmentPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool get _isEditMode => widget.treatmentToEdit != null;

  domain.Appointment? appointment;
  Map<String, dynamic> patientInfo = {};
  Map<String, dynamic> ownerInfo = {};
  List<Map<String, dynamic>> prescribedMedications = [];

  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _instructionsController = TextEditingController();

  TreatmentStatus selectedStatus = TreatmentStatus.ACTIVE;
  int durationDays = 7;
  DateTime startDate = DateTime.now();
  String? selectedMedicalRecordId;
  final List<int> durationOptions = [1, 3, 5, 7, 10, 14, 21, 30, 60, 90];

  List<Map<String, dynamic>> medicalRecords = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadAppointmentData();

    if (_isEditMode) {
      _loadTreatmentData();
    }
  }

  void _loadTreatmentData() {
    if (widget.treatmentToEdit != null) {
      final treatment = widget.treatmentToEdit!;

      setState(() {
        _medicationNameController.text = treatment.medicationName;
        _dosageController.text = treatment.dosage;
        _frequencyController.text = treatment.frequency;
        _instructionsController.text = treatment.instructions;
        durationDays = treatment.durationDays;
        startDate = treatment.startDate;
        selectedStatus = MedicalConstants.treatmentStatusFromString(
          treatment.status,
        );
        selectedMedicalRecordId = treatment.medicalRecordId;

        medicalRecords = [
          {
            'id': treatment.medicalRecordId,
            'date':
                '${treatment.startDate.day.toString().padLeft(2, '0')}/${treatment.startDate.month.toString().padLeft(2, '0')}/${treatment.startDate.year}',
            'diagnosis': 'Registro médico asociado',
            'chief_complaint': 'Tratamiento en edición',
          },
        ];
      });
    }
  }

  void _loadAppointmentData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;

      if (arguments != null) {
        if (arguments is Map<String, dynamic>) {
          setState(() {
            if (arguments.containsKey('treatmentToEdit')) {
              final treatment = arguments['treatmentToEdit'] as TreatmentModel;

              _medicationNameController.text = treatment.medicationName;
              _dosageController.text = treatment.dosage;
              _frequencyController.text = treatment.frequency;
              _instructionsController.text = treatment.instructions;
              durationDays = treatment.durationDays;
              startDate = treatment.startDate;
              selectedStatus = MedicalConstants.treatmentStatusFromString(
                treatment.status,
              );
              selectedMedicalRecordId = treatment.medicalRecordId;

              medicalRecords = [
                {
                  'id': treatment.medicalRecordId,
                  'date':
                      '${treatment.startDate.day.toString().padLeft(2, '0')}/${treatment.startDate.month.toString().padLeft(2, '0')}/${treatment.startDate.year}',
                  'diagnosis': 'Registro médico asociado',
                  'chief_complaint': 'Tratamiento en edición',
                },
              ];
            } else {
              appointment = arguments['appointment'] as domain.Appointment?;

              final rawMedicalRecords = arguments['medicalRecords'];
              final realMedicalRecords =
                  arguments['medicalRecords'] as List? ?? [];

              if (realMedicalRecords.isNotEmpty) {
                try {
                  medicalRecords =
                      realMedicalRecords.map((record) {
                        final visitDate = DateTime.parse(record['visit_date']);
                        return {
                          'id': record['id'],
                          'date':
                              '${visitDate.day.toString().padLeft(2, '0')}/${visitDate.month.toString().padLeft(2, '0')}/${visitDate.year}',
                          'diagnosis': record['diagnosis'] ?? 'Sin diagnóstico',
                          'chief_complaint':
                              record['chief_complaint'] ??
                              'Sin motivo especificado',
                        };
                      }).toList();
                } catch (e) {
                  medicalRecords = [];
                }
              } else {
                medicalRecords = [];
              }

              if (appointment != null) {
                startDate = appointment!.appointmentDate;
              }
            }

            final Map<String, dynamic> receivedPetInfo =
                arguments['petInfo'] as Map<String, dynamic>? ?? {};
            patientInfo = {
              'id': receivedPetInfo['id'] ?? '',
              'name': receivedPetInfo['name'] ?? 'Paciente',
              'type': receivedPetInfo['type'] ?? 'Mascota',
              'breed': receivedPetInfo['breed'] ?? 'N/A',
              'age': receivedPetInfo['age'] ?? 'N/A',
              'gender': receivedPetInfo['gender'] ?? 'Sin especificar',
              'status': receivedPetInfo['status'] ?? 'Sin especificar',
              'imageUrl':
                  receivedPetInfo['imageUrl'] ??
                  receivedPetInfo['image_url'] ??
                  '',
              'birthDate': receivedPetInfo['birthDate'],
              'description': receivedPetInfo['description'] ?? '',
            };

            final Map<String, dynamic> receivedOwnerInfo =
                arguments['ownerInfo'] as Map<String, dynamic>? ?? {};
            ownerInfo = {
              'id': receivedOwnerInfo['id'] ?? '',
              'name': receivedOwnerInfo['name'] ?? 'Propietario',
              'firstName': receivedOwnerInfo['firstName'] ?? '',
              'lastName': receivedOwnerInfo['lastName'] ?? '',
              'phone': receivedOwnerInfo['phone'],
              'email': receivedOwnerInfo['email'],
              'profilePhoto':
                  receivedOwnerInfo['profilePhoto'] ??
                  receivedOwnerInfo['profile_photo'] ??
                  '',
            };
          });
        } else if (arguments is TreatmentModel) {
          final treatment = arguments;
          setState(() {
            _medicationNameController.text = treatment.medicationName;
            _dosageController.text = treatment.dosage;
            _frequencyController.text = treatment.frequency;
            _instructionsController.text = treatment.instructions;
            durationDays = treatment.durationDays;
            startDate = treatment.startDate;
            selectedStatus = MedicalConstants.treatmentStatusFromString(
              treatment.status,
            );
            selectedMedicalRecordId = treatment.medicalRecordId;

            patientInfo = {
              'name': 'Paciente',
              'type': 'Mascota',
              'breed': 'N/A',
              'age': 'N/A',
            };
            ownerInfo = {'name': 'Propietario'};

            medicalRecords = [
              {
                'id': treatment.medicalRecordId,
                'date':
                    '${treatment.startDate.day}/${treatment.startDate.month}/${treatment.startDate.year}',
                'diagnosis': 'Tratamiento asociado',
                'chief_complaint': 'Edición de tratamiento',
              },
            ];
          });
        }
      } else {
        setState(() {
          patientInfo = {
            'name': 'Paciente de ejemplo',
            'type': 'Perro',
            'breed': 'Sin especificar',
            'age': 'Sin especificar',
            'diagnosis': 'Sin diagnóstico',
          };
          ownerInfo = {'name': 'Propietario de ejemplo'};

          medicalRecords = [
            {
              'id': 'example-1',
              'date': '20/01/2025',
              'diagnosis': 'Revisión general (Ejemplo)',
              'chief_complaint': 'Control de rutina (Ejemplo)',
            },
          ];
        });
      }
    });
  }

  DateTime get endDate => startDate.add(Duration(days: durationDays));

  @override
  void dispose() {
    _animationController.dispose();
    _medicationNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  bool _isValidUUID(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(value);
  }

  String? _validateMedicationName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre del medicamento es obligatorio';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (value.trim().length > 100) {
      return 'El nombre no puede exceder 100 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-\(\)\d]+$').hasMatch(value.trim())) {
      return 'El nombre contiene caracteres no válidos';
    }
    return null;
  }

  String? _validateDosage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dosificación es obligatoria';
    }
    if (value.trim().length < 2) {
      return 'La dosificación debe tener al menos 2 caracteres';
    }
    if (value.trim().length > 50) {
      return 'La dosificación no puede exceder 50 caracteres';
    }
    if (!RegExp(
      r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-\d\.\/\,]+$',
    ).hasMatch(value.trim())) {
      return 'La dosificación contiene caracteres no válidos';
    }
    return null;
  }

  String? _validateFrequency(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La frecuencia es obligatoria';
    }
    if (value.trim().length < 3) {
      return 'La frecuencia debe tener al menos 3 caracteres';
    }
    if (value.trim().length > 100) {
      return 'La frecuencia no puede exceder 100 caracteres';
    }
    if (!RegExp(
      r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-\d\.\/\,\:]+$',
    ).hasMatch(value.trim())) {
      return 'La frecuencia contiene caracteres no válidos';
    }
    return null;
  }

  String? _validateInstructions(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Las instrucciones son obligatorias';
    }
    if (value.trim().length < 5) {
      return 'Las instrucciones deben tener al menos 5 caracteres';
    }
    if (value.trim().length > 500) {
      return 'Las instrucciones no pueden exceder 500 caracteres';
    }
    return null;
  }

  String? _validateDurationDays(int? value) {
    if (value == null) {
      return 'La duración es obligatoria';
    }
    if (value < 1) {
      return 'La duración debe ser al menos 1 día';
    }
    if (value > 365) {
      return 'La duración no puede exceder 365 días';
    }
    return null;
  }

  String? _validateMedicalRecordId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Debe seleccionar un registro médico';
    }
    if (!_isValidUUID(value)) {
      return 'ID de registro médico no válido';
    }
    return null;
  }

  String? _validatePetId(String? value) {
    if (value == null || value.isEmpty) {
      return 'ID de mascota es obligatorio';
    }
    if (!_isValidUUID(value)) {
      return 'ID de mascota no válido';
    }
    return null;
  }

  String? _validateStartDate(DateTime? value) {
    if (value == null) {
      return 'La fecha de inicio es obligatoria';
    }
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 365));
    final minDate = now.subtract(const Duration(days: 30));

    if (value.isBefore(minDate)) {
      return 'La fecha no puede ser anterior a 30 días';
    }
    if (value.isAfter(maxDate)) {
      return 'La fecha no puede ser posterior a 1 año';
    }
    return null;
  }

  String? _validateEndDate(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return null;
    }
    if (endDate.isBefore(startDate)) {
      return 'La fecha de fin no puede ser anterior a la de inicio';
    }
    return null;
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    final petIdValidation = _validatePetId(patientInfo['id']);
    if (petIdValidation != null) {
      _showValidationError('Error de datos de paciente: $petIdValidation');
      return false;
    }

    final medicalRecordValidation = _validateMedicalRecordId(
      selectedMedicalRecordId,
    );
    if (medicalRecordValidation != null) {
      _showValidationError(medicalRecordValidation);
      return false;
    }

    final durationValidation = _validateDurationDays(durationDays);
    if (durationValidation != null) {
      _showValidationError(durationValidation);
      return false;
    }

    final startDateValidation = _validateStartDate(startDate);
    if (startDateValidation != null) {
      _showValidationError(startDateValidation);
      return false;
    }

    final endDateValidation = _validateEndDate(startDate, endDate);
    if (endDateValidation != null) {
      _showValidationError(endDateValidation);
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundShapes(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildModernAppBar(),
                    _buildPatientInfo(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.paddingL),
                        child: Column(
                          children: [
                            _buildPrescriptionForm(),
                            const SizedBox(height: AppSizes.spaceL),
                            if (prescribedMedications.isNotEmpty) ...[
                              _buildPrescribedMedicationsList(),
                              const SizedBox(height: AppSizes.spaceL),
                            ],
                          ],
                        ),
                      ),
                    ),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: AppSizes.decorativeShapeXL,
            height: AppSizes.decorativeShapeXL,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(125),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: -80,
          child: Container(
            width: AppSizes.decorativeShapeL,
            height: AppSizes.decorativeShapeL,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(90),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -60,
          child: Container(
            width: AppSizes.decorativeShapeM,
            height: AppSizes.decorativeShapeM,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Text(
              _isEditMode ? 'Editar Tratamiento' : 'Prescribir Tratamiento',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              icon: const Icon(Icons.medication, color: AppColors.white),
              onPressed: _savePrescription,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient:
                  patientInfo['imageUrl'] != null &&
                          patientInfo['imageUrl'].toString().isNotEmpty
                      ? null
                      : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              image:
                  patientInfo['imageUrl'] != null &&
                          patientInfo['imageUrl'].toString().isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(patientInfo['imageUrl'].toString()),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                patientInfo['imageUrl'] == null ||
                        patientInfo['imageUrl'].toString().isEmpty
                    ? const Icon(
                      Icons.medication,
                      color: AppColors.white,
                      size: 30,
                    )
                    : null,
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientInfo['name'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${patientInfo['breed'] ?? 'Sin raza'} • ${patientInfo['age'] ?? 'Sin edad'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${patientInfo['type'] ?? 'Mascota'} • ${patientInfo['gender'] ?? 'Sin especificar'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Propietario: ${ownerInfo['name'] ?? 'Sin propietario'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (ownerInfo['phone'] != null &&
                    ownerInfo['phone'].toString().isNotEmpty)
                  Text(
                    'Tel: ${ownerInfo['phone']}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.medication,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${prescribedMedications.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionForm() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              _isEditMode ? 'Editar Medicamento' : 'Agregar Medicamento',
              _isEditMode
                  ? 'Modifica la información del medicamento'
                  : 'Completa la información del medicamento',
              _isEditMode ? Icons.edit : Icons.add_circle,
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildFormSection(
              'Registro Médico Asociado',
              Icons.assignment,
              child: Builder(
                builder: (context) {
                  if (medicalRecords.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No hay registros médicos disponibles para esta mascota. Cree un registro médico primero.',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: selectedMedicalRecordId,
                    style: const TextStyle(color: AppColors.textPrimary),
                    isExpanded: true,
                    items:
                        medicalRecords.map<DropdownMenuItem<String>>((record) {
                          return DropdownMenuItem<String>(
                            value: record['id'],
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      record['date'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      record['diagnosis'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMedicalRecordId = value;
                      });
                    },
                    decoration: _buildInputDecoration(
                      'Selecciona un registro médico',
                    ),
                    validator: _validateMedicalRecordId,
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Nombre del Medicamento',
              Icons.medication,
              child: TextFormField(
                controller: _medicationNameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Ej: Omeprazol, Amoxicilina, Meloxicam...',
                ),
                validator: _validateMedicationName,
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Dosificación',
              Icons.local_pharmacy,
              child: TextFormField(
                controller: _dosageController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Ej: 10mg, 2 tabletas, 5ml...',
                ),
                validator: _validateDosage,
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Duración (días)',
              Icons.timer,
              child: DropdownButtonFormField<int>(
                value: durationDays,
                style: const TextStyle(color: AppColors.textPrimary),
                items:
                    durationOptions.map((days) {
                      return DropdownMenuItem(
                        value: days,
                        child: Text('$days días'),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    durationDays = value!;
                  });
                },
                decoration: _buildInputDecoration(null),
                validator: (value) => _validateDurationDays(value),
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Frecuencia',
              Icons.schedule,
              child: TextFormField(
                controller: _frequencyController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Ej: Una vez al día, Cada 8 horas, Dos veces al día...',
                ),
                validator: _validateFrequency,
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Instrucciones',
              Icons.info,
              child: TextFormField(
                controller: _instructionsController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Ej: Tomar 30 minutos antes del desayuno, Con alimento...',
                ),
                validator: _validateInstructions,
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Estado',
              Icons.assignment_turned_in,
              child: DropdownButtonFormField<TreatmentStatus>(
                value: selectedStatus,
                style: const TextStyle(color: AppColors.textPrimary),
                items:
                    MedicalConstants.treatmentStatusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          MedicalConstants.getTreatmentStatusDisplayName(
                            status,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
                decoration: _buildInputDecoration(null),
                validator: (value) {
                  if (value == null) {
                    return 'Debe seleccionar un estado';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Fecha de Inicio',
              Icons.event,
              child: InkWell(
                onTap: () => _selectStartDate(),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSizes.spaceS),
                      Text(
                        '${startDate.day}/${startDate.month}/${startDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isEditMode ? _updateMedication : _addMedication,
                icon: Icon(_isEditMode ? Icons.save : Icons.add),
                label: Text(
                  _isEditMode
                      ? 'Actualizar Medicamento'
                      : 'Agregar Medicamento',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescribedMedicationsList() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Medicamentos Prescritos',
            '${prescribedMedications.length} medicamento${prescribedMedications.length != 1 ? 's' : ''} agregado${prescribedMedications.length != 1 ? 's' : ''}',
            Icons.list_alt,
          ),
          const SizedBox(height: AppSizes.spaceL),
          ...prescribedMedications.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> medication = entry.value;
            return _buildMedicationItem(medication, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  medication['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(medication['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  _getStatusDisplayName(medication['status']),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(medication['status']),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _removeMedication(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceS),
          _buildMedicationInfoRow('Dosificación', medication['dosage']),
          _buildMedicationInfoRow('Frecuencia', medication['frequency']),
          _buildMedicationInfoRow(
            'Duración',
            '${medication['duration_days']} días',
          ),
          _buildMedicationInfoRow('Fecha inicio', medication['start_date']),
          _buildMedicationInfoRow('Fecha fin', medication['end_date']),
          _buildMedicationInfoRow('Instrucciones', medication['instructions']),
        ],
      ),
    );
  }

  Widget _buildMedicationInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingS),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Icon(icon, color: AppColors.white, size: 20),
        ),
        const SizedBox(width: AppSizes.spaceM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(
    String title,
    IconData icon, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: AppSizes.spaceXS),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceS),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration(String? hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: OutlinedButton.icon(
                onPressed: _clearForm,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: Colors.transparent),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _savePrescription,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Guardando...' : 'Guardar Prescripción',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String statusString) {
    final status = MedicalConstants.treatmentStatusFromString(statusString);
    switch (status) {
      case TreatmentStatus.ACTIVE:
        return AppColors.success;
      case TreatmentStatus.COMPLETED:
        return AppColors.primary;
      case TreatmentStatus.SUSPENDED:
        return AppColors.error;
    }
  }

  String _getStatusDisplayName(String statusString) {
    final status = MedicalConstants.treatmentStatusFromString(statusString);
    return MedicalConstants.getTreatmentStatusDisplayName(status);
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != startDate) {
      final validation = _validateStartDate(picked);
      if (validation != null) {
        _showValidationError(validation);
        return;
      }
      setState(() {
        startDate = picked;
      });
    }
  }

  void _addMedication() {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      prescribedMedications.add({
        'name': _medicationNameController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'frequency': _frequencyController.text.trim(),
        'duration_days': durationDays,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'instructions': _instructionsController.text.trim(),
        'status': MedicalConstants.treatmentStatusToString(selectedStatus),
      });
    });

    _clearMedicationForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_medicationNameController.text} agregado a la prescripción',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  void _updateMedication() async {
    if (!_validateForm()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await SharedPreferencesHelper.getToken();

      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final treatmentData = {
        'pet_id': patientInfo['id'],
        'medical_record_id': selectedMedicalRecordId!,
        'medication_name': _medicationNameController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'frequency': _frequencyController.text.trim(),
        'duration_days': durationDays,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'instructions': _instructionsController.text.trim(),
        'status': MedicalConstants.treatmentStatusToString(selectedStatus),
      };

      final response = await http.patch(
        Uri.parse(ApiEndpoints.updateTreatmentUrl(widget.treatmentToEdit!.id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(treatmentData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final updatedTreatment = responseData['data'];

        setState(() {
          _medicationNameController.text =
              updatedTreatment['medication_name']?.toString() ??
              _medicationNameController.text;
          _dosageController.text =
              updatedTreatment['dosage']?.toString() ?? _dosageController.text;
          _frequencyController.text =
              updatedTreatment['frequency']?.toString() ??
              _frequencyController.text;
          _instructionsController.text =
              updatedTreatment['instructions']?.toString() ??
              _instructionsController.text;

          if (updatedTreatment['duration_days'] != null) {
            durationDays =
                int.tryParse(updatedTreatment['duration_days'].toString()) ??
                durationDays;
          }

          if (updatedTreatment['start_date'] != null) {
            try {
              startDate = DateTime.parse(
                updatedTreatment['start_date'].toString(),
              );
            } catch (e) {
              // Keep current date if parsing fails
            }
          }

          if (updatedTreatment['status'] != null) {
            selectedStatus = MedicalConstants.treatmentStatusFromString(
              updatedTreatment['status'].toString(),
            );
          }
        });

        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        final errorBody =
            response.body.isNotEmpty ? response.body : 'Sin detalles del error';
        throw Exception(
          'Error del servidor: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      if (mounted) {
        _showValidationError(
          'Error al actualizar tratamiento: ${e.toString()}',
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeMedication(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            title: const Text(
              'Eliminar Medicamento',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar "${prescribedMedications[index]['name']}" de la prescripción?',
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    prescribedMedications.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Medicamento eliminado'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _clearMedicationForm() {
    _medicationNameController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _instructionsController.clear();
    setState(() {
      selectedStatus = TreatmentStatus.ACTIVE;
      durationDays = 7;
      startDate = DateTime.now();
    });
  }

  void _clearForm() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            title: const Text(
              'Limpiar Formulario',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            content: const Text(
              '¿Estás seguro de que quieres limpiar toda la prescripción? Se perderán todos los medicamentos agregados.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    prescribedMedications.clear();
                  });
                  _clearMedicationForm();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Formulario limpiado'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                ),
                child: const Text('Limpiar'),
              ),
            ],
          ),
    );
  }

  void _savePrescription() async {
    if (_isEditMode) {
      _updateMedication();
      return;
    }

    if (prescribedMedications.isEmpty) {
      _showValidationError('Agrega al menos un medicamento antes de guardar');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await SharedPreferencesHelper.getToken();

      if (token == null) {
        throw Exception('No se encontraron credenciales de autenticación');
      }

      for (int i = 0; i < prescribedMedications.length; i++) {
        final medication = prescribedMedications[i];

        final treatmentData = {
          'pet_id': patientInfo['id'] ?? '',
          'medical_record_id': selectedMedicalRecordId ?? '',
          'medication_name': medication['name'],
          'dosage': medication['dosage'] ?? '',
          'frequency': medication['frequency'],
          'duration_days': medication['duration_days'],
          'start_date': medication['start_date'],
          'end_date': medication['end_date'],
          'instructions': medication['instructions'],
          'status': medication['status'],
        };

        final response = await http.post(
          Uri.parse(ApiEndpoints.createTreatmentUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(treatmentData),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          final errorBody =
              response.body.isNotEmpty
                  ? response.body
                  : 'Sin detalles del error';
          throw Exception(
            'Error del servidor para tratamiento ${i + 1}: ${response.statusCode} - $errorBody',
          );
        }
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showValidationError('Error al guardar tratamientos: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceL),
                Text(
                  _isEditMode
                      ? '¡Tratamiento Actualizado!'
                      : '¡Prescripción Guardada!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceS),
                Text(
                  _isEditMode
                      ? 'El tratamiento ha sido actualizado exitosamente y estará disponible en el expediente del paciente.'
                      : 'La prescripción ha sido guardada exitosamente y estará disponible en el expediente del paciente.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceXL),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (_isEditMode) {
                              _createNewPrescription();
                            } else {
                              _createNewPrescription();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: Colors.transparent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                            ),
                          ),
                          child: Text(
                            _isEditMode ? 'Editar Otro' : 'Nueva Prescripción',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceM),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success,
                              AppColors.success.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context, {
                              'success': true,
                              'action': _isEditMode ? 'updated' : 'created',
                              'treatmentId': widget.treatmentToEdit?.id,
                              'timestamp': DateTime.now().toIso8601String(),
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                            ),
                          ),
                          child: const Text('Finalizar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _createNewPrescription() {
    setState(() {
      prescribedMedications.clear();
      selectedMedicalRecordId = null;
    });
    _clearMedicationForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Listo para crear una nueva prescripción'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }
}
