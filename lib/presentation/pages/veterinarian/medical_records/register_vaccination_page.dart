import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../domain/entities/appointment.dart' as domain;

class RegisterVaccinationPage extends StatefulWidget {
  const RegisterVaccinationPage({super.key});

  @override
  State<RegisterVaccinationPage> createState() =>
      _RegisterVaccinationPageState();
}

class _RegisterVaccinationPageState extends State<RegisterVaccinationPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _reminderScheduled = false;

  Map<String, dynamic> patientInfo = {};
  Map<String, dynamic> ownerInfo = {};
  domain.Appointment? appointment;

  final _vaccineNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime administeredDate = DateTime.now();
  DateTime nextDueDate = DateTime.now().add(const Duration(days: 365));

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointmentData();
    });
    _animationController.forward();
  }

  void _loadAppointmentData() {
    print('🏥 CARGANDO DATOS DE APPOINTMENT PARA VACUNA');

    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      print('✅ ARGUMENTOS RECIBIDOS: ${arguments.keys}');

      final appointmentData = arguments['appointment'];
      if (appointmentData is domain.Appointment) {
        appointment = appointmentData;
      } else if (appointmentData is Map<String, dynamic>) {
        print('🏥 Appointment recibido como Map, extrayendo datos necesarios');
        appointment = null;
      }

      final petInfo = arguments['petInfo'] as Map<String, dynamic>?;
      final ownerData = arguments['ownerInfo'] as Map<String, dynamic>?;

      print('🐕 Pet Info: $petInfo');
      print('👤 Owner Info: $ownerData');
      print('🏥 Appointment: ${appointment?.id}');

      setState(() {
        if (petInfo != null) {
          patientInfo = {
            'id': petInfo['id'] ?? '',
            'name': petInfo['name'] ?? '',
            'breed': petInfo['breed'] ?? '',
            'age': _calculateAge(petInfo['birthDate']),
            'type': petInfo['type'] ?? '',
            'gender': petInfo['gender'] ?? '',
            'status': petInfo['status'] ?? '',
            'imageUrl': petInfo['imageUrl'] ?? petInfo['image_url'] ?? '',
            'birthDate': petInfo['birthDate'],
            'description': petInfo['description'] ?? '',
          };
        }

        if (ownerData != null) {
          print('🔍 PROCESANDO OWNER DATA (DUEÑO DE LA MASCOTA):');
          print('   - Raw ownerData: $ownerData');
          print('   - ID extraído: ${ownerData['id']}');
          print('   - Email extraído: ${ownerData['email']}');
          print('   - FirstName extraído: ${ownerData['firstName']}');
          print('   - LastName extraído: ${ownerData['lastName']}');
          print('   - Phone extraído: ${ownerData['phone']}');

          ownerInfo = {
            'id': ownerData['id'] ?? '',
            'name':
                ownerData['name'] ??
                '${ownerData['firstName'] ?? ''} ${ownerData['lastName'] ?? ''}'
                    .trim(),
            'firstName':
                ownerData['firstName'] ?? ownerData['first_name'] ?? '',
            'lastName': ownerData['lastName'] ?? ownerData['last_name'] ?? '',
            'phone': ownerData['phone'] ?? '',
            'email': ownerData['email'] ?? '',
            'profilePhoto':
                ownerData['profilePhoto'] ?? ownerData['profile_photo'] ?? '',
          };

          print('🔍 OWNER INFO FINAL (PARA RECORDATORIOS):');
          print('   - ID: ${ownerInfo['id']}');
          print('   - Name: ${ownerInfo['name']}');
          print('   - FirstName: ${ownerInfo['firstName']}');
          print('   - LastName: ${ownerInfo['lastName']}');
          print('   - Phone: ${ownerInfo['phone']}');
          print('   - Email: ${ownerInfo['email']}');
          print('   - ProfilePhoto: ${ownerInfo['profilePhoto']}');
        } else {
          print('⚠️ NO SE RECIBIERON DATOS DEL PROPIETARIO');
        }
      });

      print('📊 DATOS FINALES CARGADOS:');
      print('   - Pet: ${patientInfo['name']}');
      print('   - Owner: ${ownerInfo['name']}');
      print('   - Owner ID: ${ownerInfo['id']}');
      print('   - Owner Email: ${ownerInfo['email']}');
      print('   - Owner First Name: ${ownerInfo['firstName']}');
      print('   - Appointment ID: ${appointment?.id}');
    } else {
      print('⚠️ NO SE RECIBIERON ARGUMENTOS - USANDO DATOS DE EJEMPLO');

      setState(() {
        patientInfo = {
          'name': 'Max',
          'breed': 'Labrador Retriever',
          'age': '3 años',
          'type': 'Perro',
        };
        ownerInfo = {
          'name': 'Juan Pérez',
          'phone': '5551234567',
          'email': 'juan@correo.com',
        };
      });
    }
  }

  String _calculateAge(String? birthDateStr) {
    if (birthDateStr == null) return 'N/A';

    try {
      final birthDate = DateTime.parse(birthDateStr);
      final now = DateTime.now();
      final difference = now.difference(birthDate);
      final years = (difference.inDays / 365).floor();
      final months = ((difference.inDays % 365) / 30).floor();

      if (years > 0) {
        return '$years año${years > 1 ? 's' : ''}';
      } else if (months > 0) {
        return '$months mes${months > 1 ? 'es' : ''}';
      } else {
        final days = difference.inDays;
        return '$days día${days > 1 ? 's' : ''}';
      }
    } catch (e) {
      print('❌ Error calculando edad: $e');
      return 'N/A';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _vaccineNameController.dispose();
    _manufacturerController.dispose();
    _batchNumberController.dispose();
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildModernAppBar(),
                      _buildPatientInfo(),
                      Expanded(child: _buildFormContent()),
                      _buildActionButtons(),
                    ],
                  ),
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
          const Expanded(
            child: Text(
              'Registrar Vacuna',
              style: TextStyle(
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
              icon: const Icon(Icons.vaccines, color: AppColors.white),
              onPressed: _saveVaccination,
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
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              child:
                  patientInfo['imageUrl'] != null &&
                          patientInfo['imageUrl'].toString().isNotEmpty
                      ? Image.network(
                        patientInfo['imageUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusRound,
                              ),
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: AppColors.white,
                              size: 30,
                            ),
                          );
                        },
                      )
                      : Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusRound,
                          ),
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientInfo['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${patientInfo['breed']} • ${patientInfo['age']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Dueño: ${ownerInfo['name']}',
                  style: const TextStyle(
                    fontSize: 12,
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
                'Aplicación',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '${administeredDate.day}/${administeredDate.month}/${administeredDate.year}',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormSection(
            'Información de la Vacuna',
            Icons.vaccines,
            child: Column(
              children: [
                TextFormField(
                  controller: _vaccineNameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _buildInputDecoration(
                    'Nombre de la vacuna',
                    'Ej: Triple Viral Canina, Antirrábica, Parvovirus...',
                    Icons.medical_information,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre de la vacuna es obligatorio';
                    }
                    if (value.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    if (value.trim().length > 100) {
                      return 'El nombre no puede exceder 100 caracteres';
                    }
                    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'El nombre no puede contener caracteres especiales';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spaceM),
                TextFormField(
                  controller: _manufacturerController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _buildInputDecoration(
                    'Laboratorio/Fabricante',
                    'Ej: Pfizer, Merck, Zoetis, Boehringer...',
                    Icons.business,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El fabricante es obligatorio';
                    }
                    if (value.trim().length < 2) {
                      return 'El fabricante debe tener al menos 2 caracteres';
                    }
                    if (value.trim().length > 100) {
                      return 'El fabricante no puede exceder 100 caracteres';
                    }
                    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'El fabricante no puede contener caracteres especiales';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spaceM),
                TextFormField(
                  controller: _batchNumberController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _buildInputDecoration(
                    'Número de Lote',
                    'Ej: TV2024-001, VX2024-123...',
                    Icons.confirmation_number,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El número de lote es obligatorio';
                    }
                    if (value.trim().length < 3) {
                      return 'El número de lote debe tener al menos 3 caracteres';
                    }
                    if (value.trim().length > 50) {
                      return 'El número de lote no puede exceder 50 caracteres';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(value.trim())) {
                      return 'El lote solo puede contener letras, números, guiones y guiones bajos';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceL),
          _buildFormSection(
            'Fechas de Aplicación',
            Icons.calendar_today,
            child: Column(
              children: [
                InkWell(
                  onTap: () => _selectAdministeredDate(),
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
                        Icon(Icons.event, color: AppColors.primary),
                        const SizedBox(width: AppSizes.spaceM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha de Aplicación',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${administeredDate.day}/${administeredDate.month}/${administeredDate.year}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceM),
                InkWell(
                  onTap: () => _selectNextDueDate(),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color:
                            nextDueDate.isBefore(administeredDate)
                                ? AppColors.error
                                : AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color:
                                  nextDueDate.isBefore(administeredDate)
                                      ? AppColors.error
                                      : AppColors.primary,
                            ),
                            const SizedBox(width: AppSizes.spaceM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Próxima Dosis (Vencimiento)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${nextDueDate.day}/${nextDueDate.month}/${nextDueDate.year}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          nextDueDate.isBefore(administeredDate)
                                              ? AppColors.error
                                              : AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color:
                                  nextDueDate.isBefore(administeredDate)
                                      ? AppColors.error
                                      : AppColors.primary,
                            ),
                          ],
                        ),
                        if (nextDueDate.isBefore(administeredDate))
                          const Padding(
                            padding: EdgeInsets.only(top: AppSizes.spaceS),
                            child: Text(
                              'La fecha de vencimiento debe ser posterior a la aplicación',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
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
                'Observaciones',
                'Aplicada en el muslo derecho, reacciones observadas, próximas vacunas...',
                null,
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (value.trim().length < 5) {
                    return 'Las notas deben tener al menos 5 caracteres';
                  }
                  if (value.trim().length > 500) {
                    return 'Las notas no pueden exceder 500 caracteres';
                  }
                  if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Las notas no pueden contener caracteres especiales';
                  }
                }
                return null;
              },
            ),
          ),
        ],
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

  InputDecoration _buildInputDecoration(
    String label,
    String hint,
    IconData? icon,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
      labelStyle: TextStyle(color: AppColors.textSecondary),
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
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      errorStyle: const TextStyle(
        fontSize: 11,
        color: AppColors.error,
        height: 1.3,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingM,
      ),
    );
  }

  Widget _buildActionButtons() {
    final bool hasValidationErrors = nextDueDate.isBefore(administeredDate);

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
                gradient:
                    hasValidationErrors ? null : AppColors.primaryGradient,
                color:
                    hasValidationErrors
                        ? AppColors.textSecondary.withOpacity(0.3)
                        : null,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow:
                    hasValidationErrors
                        ? null
                        : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: ElevatedButton.icon(
                onPressed:
                    (_isLoading || hasValidationErrors)
                        ? null
                        : _saveVaccination,
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
                        : const Icon(Icons.vaccines),
                label: Text(_isLoading ? 'Guardando...' : 'Registrar Vacuna'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor:
                      hasValidationErrors
                          ? AppColors.textSecondary
                          : AppColors.white,
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

  void _selectAdministeredDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: administeredDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != administeredDate) {
      setState(() {
        administeredDate = picked;
        if (nextDueDate.isBefore(picked)) {
          nextDueDate = picked.add(const Duration(days: 365));
        }
      });
    }
  }

  void _selectNextDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          nextDueDate.isBefore(administeredDate)
              ? administeredDate.add(const Duration(days: 365))
              : nextDueDate,
      firstDate: administeredDate,
      lastDate: administeredDate.add(const Duration(days: 1095)),
    );

    if (picked != null && picked != nextDueDate) {
      setState(() {
        nextDueDate = picked;
      });
    }
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
              '¿Estás seguro de que quieres limpiar todos los datos del formulario?',
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
                  _resetForm();
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

  void _resetForm() {
    setState(() {
      administeredDate = DateTime.now();
      nextDueDate = DateTime.now().add(const Duration(days: 365));
    });

    _vaccineNameController.clear();
    _manufacturerController.clear();
    _batchNumberController.clear();
    _notesController.clear();
  }

  void _saveVaccination() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor completa todos los campos obligatorios correctamente',
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

    if (nextDueDate.isBefore(administeredDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha de vencimiento debe ser posterior a la fecha de aplicación',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('💉 INICIANDO CREACIÓN DE VACUNA');

      final token = await SharedPreferencesHelper.getToken();
      final vetId = await SharedPreferencesHelper.getVetId();

      if (token == null || vetId == null) {
        throw Exception(
          'No se encontró token de autenticación o ID de veterinario',
        );
      }

      print('🔑 Token obtenido: ${token.substring(0, 10)}...');
      print('👨‍⚕️ Vet ID: $vetId');
      print('🐕 Pet ID from appointment: ${appointment?.petId}');
      print('🐕 Pet ID from patientInfo: ${patientInfo['id']}');

      String petId = appointment?.petId ?? patientInfo['id'] ?? '';

      if (petId.isEmpty) {
        throw Exception('No se pudo obtener el ID de la mascota');
      }

      print('🎯 Pet ID final utilizado: $petId');

      final vaccinationData = {
        'pet_id': petId,
        'vet_id': vetId,
        'vaccine_name': _vaccineNameController.text.trim(),
        'manufacturer': _manufacturerController.text.trim(),
        'batch_number': _batchNumberController.text.trim(),
        'administered_date': administeredDate.toIso8601String().split('T')[0],
        'next_due_date': nextDueDate.toIso8601String().split('T')[0],
        'notes':
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      };

      print('📋 DATOS DE VACUNA A ENVIAR:');
      print('Pet ID: ${vaccinationData['pet_id']}');
      print('Vet ID: ${vaccinationData['vet_id']}');
      print('Vaccine Name: ${vaccinationData['vaccine_name']}');
      print('Manufacturer: ${vaccinationData['manufacturer']}');
      print('Batch Number: ${vaccinationData['batch_number']}');
      print('Administered Date: ${vaccinationData['administered_date']}');
      print('Next Due Date: ${vaccinationData['next_due_date']}');
      print('Notes: ${vaccinationData['notes']}');

      final response = await http.post(
        Uri.parse(ApiEndpoints.createVaccinationUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(vaccinationData),
      );

      print('📡 RESPUESTA DEL SERVIDOR:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ VACUNA CREADA EXITOSAMENTE');

        print('🔔 LLAMANDO AL MÉTODO _scheduleVaccinationReminder...');
        _reminderScheduled = await _scheduleVaccinationReminder(
          vaccinationData,
        );
        print('🔔 RESULTADO DEL RECORDATORIO: $_reminderScheduled');

        if (mounted) {
          setState(() => _isLoading = false);
          _showSuccessDialog();
        }
      } else {
        print('❌ ERROR EN LA RESPUESTA DEL SERVIDOR');
        throw Exception(
          'Error del servidor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ ERROR CREANDO VACUNA: $e');

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar la vacuna: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<bool> _scheduleVaccinationReminder(
    Map<String, dynamic> vaccinationData,
  ) async {
    try {
      print('🔔 INICIANDO PROGRAMACIÓN DE RECORDATORIO DE VACUNA');
      print('📊 Estado actual de ownerInfo: $ownerInfo');
      print('📊 Estado actual de patientInfo: $patientInfo');
      print('📊 Datos de vacuna recibidos: $vaccinationData');

      if (ownerInfo['id'] == null || ownerInfo['email'] == null) {
        print(
          '⚠️ NO SE PUEDE PROGRAMAR RECORDATORIO: Faltan datos del usuario',
        );
        print('   - User ID: ${ownerInfo['id']}');
        print('   - Email: ${ownerInfo['email']}');
        print('   - OwnerInfo completo: $ownerInfo');
        return false;
      }

      final token = await SharedPreferencesHelper.getToken();
      if (token == null) {
        print(
          '❌ NO SE PUEDE PROGRAMAR RECORDATORIO: Sin token de autenticación',
        );
        return false;
      }

      print(
        '🔑 Token obtenido para recordatorio: ${token.substring(0, 10)}...',
      );

      print('📅 Procesando fecha: ${vaccinationData['next_due_date']}');
      DateTime nextDueDate = DateTime.parse(vaccinationData['next_due_date']);
      DateTime scheduledFor = DateTime(
        nextDueDate.year,
        nextDueDate.month,
        nextDueDate.day,
        18, // 6:00 PM
        0,
        0,
      );

      print('⏰ Fecha programada final: ${scheduledFor.toIso8601String()}');

      final reminderData = {
        "user_id": ownerInfo['id'],
        "type": "VACCINATION_REMINDER",
        "scheduled_for": scheduledFor.toIso8601String(),
        "metadata": {
          "email": ownerInfo['email'],
          "notificationData": {
            "ownerName": ownerInfo['firstName'] ?? ownerInfo['name'],
            "petName": patientInfo['name'],
            "vaccineName": vaccinationData['vaccine_name'],
            "dueDate": scheduledFor.toIso8601String(),
          },
        },
      };

      print('📋 DATOS DEL RECORDATORIO A ENVIAR:');
      print('User ID: ${reminderData['user_id']}');
      print('Type: ${reminderData['type']}');
      print('Scheduled For: ${reminderData['scheduled_for']}');
      print('Email: ${reminderData['metadata']['email']}');
      print(
        'Owner Name: ${reminderData['metadata']['notificationData']['ownerName']}',
      );
      print(
        'Pet Name: ${reminderData['metadata']['notificationData']['petName']}',
      );
      print(
        'Vaccine Name: ${reminderData['metadata']['notificationData']['vaccineName']}',
      );

      print(
        '🌐 URL del endpoint: ${ApiEndpoints.baseUrl}/notifications/schedule',
      );
      print('📋 JSON a enviar: ${json.encode(reminderData)}');

      print('🚀 INICIANDO SOLICITUD HTTP POST...');

      try {
        final response = await http
            .post(
              Uri.parse('${ApiEndpoints.baseUrl}/notifications/schedule'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode(reminderData),
            )
            .timeout(Duration(seconds: 30));

        print('✅ SOLICITUD HTTP COMPLETADA');
        print('📡 RESPUESTA DEL RECORDATORIO:');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ RECORDATORIO PROGRAMADO EXITOSAMENTE');
          return true;
        } else {
          print(
            '⚠️ ERROR PROGRAMANDO RECORDATORIO: ${response.statusCode} - ${response.body}',
          );
          return false;
        }
      } catch (httpError) {
        print('❌ ERROR EN SOLICITUD HTTP: $httpError');
        return false;
      }
    } catch (e) {
      print('❌ ERROR PROGRAMANDO RECORDATORIO: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
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
                const Text(
                  '¡Vacuna Registrada!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceS),
                Text(
                  _reminderScheduled
                      ? 'La vacuna ha sido registrada exitosamente y estará disponible en el historial del paciente.\n\n✅ Se programó un recordatorio para la próxima aplicación.'
                      : 'La vacuna ha sido registrada exitosamente y estará disponible en el historial del paciente.',
                  style: TextStyle(
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
                            _resetForm();
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
                          child: const Text('Otra Vacuna'),
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
                            print(
                              '✅ BOTÓN FINALIZAR PRESIONADO - REGRESANDO CON ÉXITO',
                            );
                            Navigator.pop(context);
                            Navigator.pop(context, true);
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
}
