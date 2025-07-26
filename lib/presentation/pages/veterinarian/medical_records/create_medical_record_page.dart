import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/medical_constants.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../data/models/medical_records/medical_record_with_treatments_model.dart';
import '../../../../domain/entities/appointment.dart' as domain;

class CreateMedicalRecordPage extends StatefulWidget {
  final MedicalRecordWithTreatmentsModel? medicalRecordToEdit;

  const CreateMedicalRecordPage({super.key, this.medicalRecordToEdit});

  @override
  State<CreateMedicalRecordPage> createState() =>
      _CreateMedicalRecordPageState();
}

class _CreateMedicalRecordPageState extends State<CreateMedicalRecordPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get _isEditMode => widget.medicalRecordToEdit != null;

  final _chiefComplaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  // Datos de la cita y mascota
  domain.Appointment? appointment;
  Map<String, dynamic> patientInfo = {};
  Map<String, dynamic> ownerInfo = {};
  
  UrgencyLevel selectedUrgencyLevel = UrgencyLevel.LOW;
  MedicalRecordStatus selectedStatus = MedicalRecordStatus.DRAFT;
  DateTime visitDate = DateTime.now();

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
    
    // Siempre cargar datos de argumentos (para mascota y propietario)
    _loadAppointmentData();
    
    // Si es modo edición, también cargar datos del registro médico
    if (_isEditMode) {
      _loadMedicalRecordData();
    }
  }

  void _loadMedicalRecordData() {
    if (widget.medicalRecordToEdit != null) {
      final record = widget.medicalRecordToEdit!;
      
      setState(() {
        _chiefComplaintController.text = record.chiefComplaint;
        _diagnosisController.text = record.diagnosis;
        _notesController.text = record.notes ?? '';
        visitDate = record.visitDate;
        selectedUrgencyLevel = MedicalConstants.urgencyLevelFromString(record.urgencyLevel);
        selectedStatus = MedicalConstants.statusFromString(record.status);
      });
    }
  }

  void _loadAppointmentData() {
    // Recibir argumentos pasados desde appointment_detail_vet_page o patient_history_page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      
      print('🔧 CREATE MEDICAL RECORD: Iniciando carga de datos');
      print('🔍 Arguments: $arguments');
      print('🔍 Arguments type: ${arguments.runtimeType}');
      
      if (arguments != null) {
        if (arguments is Map<String, dynamic>) {
          print('🔧 CREATE MEDICAL RECORD: Argumentos como mapa recibidos');
          print('🔍 Arguments keys: ${arguments.keys}');
          
          setState(() {
            if (arguments.containsKey('medicalRecord')) {
              print('🔧 MODO EDICIÓN: Cargando datos del registro médico');
              final record = arguments['medicalRecord'] as MedicalRecordWithTreatmentsModel;
              _chiefComplaintController.text = record.chiefComplaint;
              _diagnosisController.text = record.diagnosis;
              _notesController.text = record.notes ?? '';
              visitDate = record.visitDate;
              selectedUrgencyLevel = MedicalConstants.urgencyLevelFromString(record.urgencyLevel);
              selectedStatus = MedicalConstants.statusFromString(record.status);
            } else {
              print('🔧 MODO CREACIÓN: Cargando datos de la cita');
              appointment = arguments['appointment'] as domain.Appointment?;
            }
            
            // Cargar información del paciente y propietario
            final rawPetInfo = arguments['petInfo'];
            final rawOwnerInfo = arguments['ownerInfo'];
            
            print('🔍 RAW PET INFO RECIBIDO: $rawPetInfo');
            print('🔍 RAW OWNER INFO RECIBIDO: $rawOwnerInfo');
            
            // Normalizar petInfo - manejar tanto formato nuevo como legado
            final Map<String, dynamic> receivedPetInfo = arguments['petInfo'] as Map<String, dynamic>? ?? {};
            patientInfo = {
              'id': receivedPetInfo['id'] ?? '',
              'name': receivedPetInfo['name'] ?? 'Paciente',
              'type': receivedPetInfo['type'] ?? 'Mascota',
              'breed': receivedPetInfo['breed'] ?? 'N/A',
              'age': receivedPetInfo['age'] ?? 'N/A',
              'gender': receivedPetInfo['gender'] ?? 'Sin especificar',
              'status': receivedPetInfo['status'] ?? 'Sin especificar',
              // Manejar tanto imageUrl como image_url
              'imageUrl': receivedPetInfo['imageUrl'] ?? receivedPetInfo['image_url'] ?? '',
              'birthDate': receivedPetInfo['birthDate'],
              'description': receivedPetInfo['description'] ?? '',
            };
            
            // Normalizar ownerInfo - manejar tanto formato nuevo como legado
            final Map<String, dynamic> receivedOwnerInfo = arguments['ownerInfo'] as Map<String, dynamic>? ?? {};
            ownerInfo = {
              'id': receivedOwnerInfo['id'] ?? '',
              'name': receivedOwnerInfo['name'] ?? 'Propietario',
              'firstName': receivedOwnerInfo['firstName'] ?? '',
              'lastName': receivedOwnerInfo['lastName'] ?? '',
              'phone': receivedOwnerInfo['phone'],
              'email': receivedOwnerInfo['email'],
              // Manejar tanto profilePhoto como profile_photo
              'profilePhoto': receivedOwnerInfo['profilePhoto'] ?? receivedOwnerInfo['profile_photo'] ?? '',
            };
            
            print('🔍 DATOS FINALES ASIGNADOS EN MEDICAL RECORD:');
            print('🐕 Patient Info final: $patientInfo');
            print('👤 Owner Info final: $ownerInfo');
            print('🖼️ Image URL final: ${patientInfo['imageUrl']}');
          });
        } else if (arguments is MedicalRecordWithTreatmentsModel) {
          print('🔧 MODO LEGACY: Argumentos como MedicalRecordWithTreatmentsModel');
          final record = arguments;
          setState(() {
            _chiefComplaintController.text = record.chiefComplaint;
            _diagnosisController.text = record.diagnosis;
            _notesController.text = record.notes ?? '';
            visitDate = record.visitDate;
            selectedUrgencyLevel = MedicalConstants.urgencyLevelFromString(record.urgencyLevel);
            selectedStatus = MedicalConstants.statusFromString(record.status);
            
            patientInfo = {
              'name': 'Paciente',
              'type': 'Mascota',
              'breed': 'N/A',
              'age': 'N/A',
            };
            ownerInfo = {
              'name': 'Propietario',
            };
          });
        }
      } else {
        print('🔧 SIN ARGUMENTOS: Usando datos de ejemplo');
        setState(() {
          patientInfo = {
            'name': 'Paciente de ejemplo',
            'type': 'Perro',
            'breed': 'Sin especificar',
            'age': 'Sin especificar',
            'diagnosis': 'Sin diagnóstico',
          };
          ownerInfo = {
            'name': 'Propietario de ejemplo',
          };
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chiefComplaintController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
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
                    Expanded(child: _buildFormContent()),
                    _buildSaveButton(),
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
                _isEditMode ? 'Editar Registro Médico' : 'Nuevo Registro Médico',
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
              icon: const Icon(Icons.save_outlined, color: AppColors.white),
              onPressed: _saveRecord,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    // Log de debug para ver qué datos tiene la UI disponibles
    print('🎨 RENDERIZANDO UI CREATE MEDICAL RECORD:');
    print('🐕 patientInfo en UI: $patientInfo');
    print('👤 ownerInfo en UI: $ownerInfo');
    print('🖼️ imageUrl en UI: ${patientInfo['imageUrl']}');
    
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
              gradient: patientInfo['imageUrl'] != null && patientInfo['imageUrl'].toString().isNotEmpty
                  ? null
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              image: patientInfo['imageUrl'] != null && patientInfo['imageUrl'].toString().isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(patientInfo['imageUrl'].toString()),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: patientInfo['imageUrl'] == null || patientInfo['imageUrl'].toString().isEmpty
                ? const Icon(Icons.pets, color: AppColors.white, size: 30)
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
                  'Dueño: ${ownerInfo['name'] ?? 'Sin propietario'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (ownerInfo['phone'] != null && ownerInfo['phone'].toString().isNotEmpty)
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Consulta',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '${visitDate.day}/${visitDate.month}/${visitDate.year}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormSection(
              'Motivo Principal de Consulta',
              Icons.help_outline,
              child: TextFormField(
                controller: _chiefComplaintController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Describe el motivo principal por el cual se trae la mascota...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildFormSection(
              'Diagnóstico',
              Icons.medical_information,
              child: TextFormField(
                controller: _diagnosisController,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Indica el diagnóstico basado en los síntomas y examen físico...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildFormSection(
              'Notas Adicionales',
              Icons.note,
              child: TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Observaciones adicionales, recomendaciones para el propietario...',
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildFormSection(
              'Nivel de Urgencia',
              Icons.priority_high,
              child: DropdownButtonFormField<UrgencyLevel>(
                value: selectedUrgencyLevel,
                style: const TextStyle(color: AppColors.textPrimary),
                items: MedicalConstants.urgencyLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(MedicalConstants.getUrgencyDisplayName(level)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUrgencyLevel = value!;
                  });
                },
                decoration: _buildInputDecoration(null),
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildFormSection(
              'Estado',
              Icons.assignment_turned_in,
              child: DropdownButtonFormField<MedicalRecordStatus>(
                value: selectedStatus,
                style: const TextStyle(color: AppColors.textPrimary),
                items: MedicalConstants.statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(MedicalConstants.getStatusDisplayName(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
                decoration: _buildInputDecoration(null),
              ),
            ),
          ],
        ),
      ),
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
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSizes.spaceS),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),
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
    );
  }

  Widget _buildSaveButton() {
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
      child: Container(
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
          onPressed: _isLoading ? null : _saveRecord,
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
          label: Text(_isLoading ? 'Guardando...' : (_isEditMode ? 'Actualizar Registro' : 'Guardar Registro')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
        ),
      ),
    );
  }



  void _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor completa todos los campos obligatorios',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Obtener datos necesarios
      final token = await SharedPreferencesHelper.getToken();
      final vetId = await SharedPreferencesHelper.getUserId();

      if (token == null || vetId == null) {
        throw Exception('No se encontraron credenciales de autenticación');
      }

      // Preparar datos según el DTO (todos los campos son opcionales en edición)
      final medicalRecordData = <String, dynamic>{};
      
      if (_isEditMode) {
        // En modo edición, solo enviar campos que han cambiado o que no estén vacíos
        if (_chiefComplaintController.text.trim().isNotEmpty) {
          medicalRecordData['chief_complaint'] = _chiefComplaintController.text.trim();
        }
        if (_diagnosisController.text.trim().isNotEmpty) {
          medicalRecordData['diagnosis'] = _diagnosisController.text.trim();
        }
        if (_notesController.text.trim().isNotEmpty) {
          medicalRecordData['notes'] = _notesController.text.trim();
        }
        medicalRecordData['visit_date'] = visitDate.toIso8601String();
        medicalRecordData['urgency_level'] = MedicalConstants.urgencyLevelToString(selectedUrgencyLevel);
        medicalRecordData['status'] = MedicalConstants.statusToString(selectedStatus);
      } else {
        // En modo creación, todos los campos obligatorios
        medicalRecordData['pet_id'] = appointment?.petId ?? patientInfo['id'] ?? '';
        medicalRecordData['vet_id'] = vetId;
        medicalRecordData['appointment_id'] = appointment?.id; // Puede ser null si no hay cita específica
        medicalRecordData['visit_date'] = visitDate.toIso8601String();
        medicalRecordData['chief_complaint'] = _chiefComplaintController.text.trim();
        medicalRecordData['diagnosis'] = _diagnosisController.text.trim();
        medicalRecordData['notes'] = _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim();
        medicalRecordData['urgency_level'] = MedicalConstants.urgencyLevelToString(selectedUrgencyLevel);
        medicalRecordData['status'] = MedicalConstants.statusToString(selectedStatus);
      }

      print('🔧 ENVIANDO PETICIÓN ${_isEditMode ? "PATCH" : "POST"}');
      print('🎯 URL: ${_isEditMode ? ApiEndpoints.updateMedicalRecordUrl(widget.medicalRecordToEdit!.id) : ApiEndpoints.createMedicalRecordUrl}');
      print('💾 Data: ${json.encode(medicalRecordData)}');
      
      // Realizar request según el modo
      final response = _isEditMode 
          ? await http.patch(
              Uri.parse(ApiEndpoints.updateMedicalRecordUrl(widget.medicalRecordToEdit!.id)),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode(medicalRecordData),
            )
          : await http.post(
              Uri.parse(ApiEndpoints.createMedicalRecordUrl),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode(medicalRecordData),
            );

      print('📡 RESPUESTA DEL SERVIDOR:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al ${_isEditMode ? 'actualizar' : 'guardar'} registro médico: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al ${_isEditMode ? 'actualizar' : 'guardar'} registro médico: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
        );
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
                  _isEditMode ? '¡Registro Actualizado!' : '¡Registro Guardado!',
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
                      ? 'El registro médico ha sido actualizado exitosamente.'
                      : 'El registro médico ha sido guardado exitosamente.',
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
                            _createNewRecord();
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
                          child: Text(_isEditMode ? 'Editar Otro' : 'Nuevo Registro'),
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
                            Navigator.pop(context, true); // Devolver true para indicar éxito
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

  void _createNewRecord() {
    setState(() {
      selectedUrgencyLevel = UrgencyLevel.LOW;
      selectedStatus = MedicalRecordStatus.DRAFT;
      visitDate = DateTime.now();
    });

    _chiefComplaintController.clear();
    _diagnosisController.clear();
    _notesController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Listo para crear un nuevo registro médico'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }
}
