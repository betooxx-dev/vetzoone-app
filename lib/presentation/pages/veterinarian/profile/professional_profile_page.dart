import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/veterinary_constants.dart';
import '../../../../core/injection/injection.dart';
import '../../../../data/datasources/vet/vet_remote_datasource.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../widgets/common/profile_image_picker_widget.dart';

class ProfessionalProfilePage extends StatefulWidget {
  const ProfessionalProfilePage({super.key});

  @override
  State<ProfessionalProfilePage> createState() =>
      _ProfessionalProfilePageState();
}

class _ProfessionalProfilePageState extends State<ProfessionalProfilePage> {
  bool _isEditing = false;
  bool _isLoading = false;
  Map<String, dynamic> professionalData = {};
  Map<String, dynamic> vetData = {};
  File? _selectedImageFile;

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _locationCityController = TextEditingController();
  final _locationStateController = TextEditingController();
  final _consultationFeeController = TextEditingController();

  List<String> _specialties = [];
  List<String> _services = [];
  List<String> _animalsServed = [];
  List<Map<String, dynamic>> _availability = [];

  // Usar las especialidades del modelo de IA con nombres legibles
  List<String> get _availableSpecialties => 
      VeterinaryConstants.aiModelSpecialties.map((s) => s.displayName).toList();

  final List<String> _availableServices = [
    'Consulta General',
    'Vacunación',
    'Desparasitación',
    'Cirugía Menor',
    'Cirugía Mayor',
    'Rayos X',
    'Ultrasonido',
    'Análisis de Laboratorio',
    'Hospitalización',
    'Grooming',
    'Eutanasia',
    'Microchip',
  ];

  final List<String> _availableAnimals = [
    'Perros',
    'Gatos',
    'Aves',
    'Conejos',
    'Hámsters',
    'Reptiles',
    'Peces',
    'Animales Exóticos',
    'Ganado Bovino',
    'Ganado Porcino',
    'Equinos',
    'Caprinos',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String? _validateLicense(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La cédula profesional es obligatoria';
    }
    if (value.trim().length < 4) {
      return 'La cédula debe tener al menos 4 caracteres';
    }
    if (value.trim().length > 20) {
      return 'La cédula no puede exceder 20 caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(value.trim())) {
      return 'La cédula solo puede contener letras, números, guiones y guiones bajos';
    }
    return null;
  }

  String? _validateSpecialties(List<String> value) {
    if (value.isEmpty) {
      return 'Debe seleccionar al menos una especialidad';
    }
    if (value.length > 10) {
      return 'No puede seleccionar más de 10 especialidades';
    }
    return null;
  }

  String? _validateYearsExperience(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Los años de experiencia son obligatorios';
    }
    final years = int.tryParse(value.trim());
    if (years == null) {
      return 'Debe ser un número válido';
    }
    if (years < 0) {
      return 'Los años de experiencia no pueden ser negativos';
    }
    if (years > 60) {
      return 'Los años de experiencia no pueden exceder 60';
    }
    return null;
  }

  String? _validateLocationCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length < 2) {
      return 'La ciudad debe tener al menos 2 caracteres';
    }
    if (value.trim().length > 100) {
      return 'La ciudad no puede exceder 100 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-\.]+$').hasMatch(value.trim())) {
      return 'La ciudad contiene caracteres no válidos';
    }
    return null;
  }

  String? _validateLocationState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length < 2) {
      return 'El estado debe tener al menos 2 caracteres';
    }
    if (value.trim().length > 100) {
      return 'El estado no puede exceder 100 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-\.]+$').hasMatch(value.trim())) {
      return 'El estado contiene caracteres no válidos';
    }
    return null;
  }

  String? _validateBio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length < 10) {
      return 'La biografía debe tener al menos 10 caracteres';
    }
    if (value.trim().length > 1000) {
      return 'La biografía no puede exceder 1000 caracteres';
    }
    return null;
  }

  String? _validateConsultationFee(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final fee = double.tryParse(value.trim());
    if (fee == null) {
      return 'Debe ser un número válido';
    }
    if (fee < 0) {
      return 'La tarifa no puede ser negativa';
    }
    if (fee > 10000) {
      return 'La tarifa no puede exceder \$10,000';
    }
    return null;
  }

  String? _validateServices(List<String> value) {
    if (value.isEmpty) {
      return 'Debe seleccionar al menos un servicio';
    }
    if (value.length > 15) {
      return 'No puede seleccionar más de 15 servicios';
    }
    return null;
  }

  String? _validateAnimalsServed(List<String> value) {
    if (value.isEmpty) {
      return 'Debe seleccionar al menos un tipo de animal';
    }
    if (value.length > 12) {
      return 'No puede seleccionar más de 12 tipos de animales';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length < 10) {
      return 'El teléfono debe tener al menos 10 dígitos';
    }
    if (value.trim().length > 15) {
      return 'El teléfono no puede exceder 15 dígitos';
    }
    if (!RegExp(r'^[\+]?[0-9\s\-\(\)]+$').hasMatch(value.trim())) {
      return 'El teléfono contiene caracteres no válidos';
    }
    return null;
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    final licenseValidation = _validateLicense(_licenseController.text);
    if (licenseValidation != null) {
      _showValidationError(licenseValidation);
      return false;
    }

    final specialtiesValidation = _validateSpecialties(_specialties);
    if (specialtiesValidation != null) {
      _showValidationError(specialtiesValidation);
      return false;
    }

    final servicesValidation = _validateServices(_services);
    if (servicesValidation != null) {
      _showValidationError(servicesValidation);
      return false;
    }

    final animalsValidation = _validateAnimalsServed(_animalsServed);
    if (animalsValidation != null) {
      _showValidationError(animalsValidation);
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

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final firstName = await SharedPreferencesHelper.getUserFirstName() ?? '';
      final lastName = await SharedPreferencesHelper.getUserLastName() ?? '';
      final email = await SharedPreferencesHelper.getUserEmail() ?? '';
      final phone = await SharedPreferencesHelper.getUserPhone() ?? '';
      final profilePhoto =
          await SharedPreferencesHelper.getUserProfilePhoto() ?? '';

      final vetProfileData = await SharedPreferencesHelper.getVetData();

      if (vetProfileData != null) {
        vetData = vetProfileData;

        setState(() {
          professionalData = {
            'firstName': firstName,
            'lastName': lastName,
            'fullName': '$firstName $lastName'.trim(),
            'email': email,
            'phone': phone,
            'profileImage': profilePhoto,
            'license': vetData['license'] ?? '',
            'bio': vetData['bio'] ?? '',
            'yearsExperience': vetData['years_experience'] ?? 0,
            'locationCity': vetData['location_city'] ?? '',
            'locationState': vetData['location_state'] ?? '',
            'consultationFee': vetData['consultation_fee'] ?? 0.0,
          };

          // Convertir códigos de IA a nombres legibles para mostrar en UI
          final specialtyCodes = List<String>.from(vetData['specialties'] ?? []);
          _specialties = specialtyCodes.map((code) => 
            VeterinaryConstants.getDisplayNameFromAICode(code)
          ).toList();
          
          _services = List<String>.from(vetData['services'] ?? []);
          _animalsServed = List<String>.from(vetData['animals_served'] ?? []);
          _availability = List<Map<String, dynamic>>.from(
            vetData['availability'] ?? [],
          );
        });
      } else {
        setState(() {
          professionalData = {
            'firstName': firstName,
            'lastName': lastName,
            'fullName': '$firstName $lastName'.trim(),
            'email': email,
            'phone': phone,
            'profileImage': profilePhoto,
            'license': 'No disponible',
            'bio': '',
            'yearsExperience': 0,
            'locationCity': '',
            'locationState': '',
            'consultationFee': 0.0,
          };
        });
      }

      _initializeControllers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el perfil: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    _firstNameController.text = professionalData['firstName'] ?? '';
    _lastNameController.text = professionalData['lastName'] ?? '';
    _phoneController.text = professionalData['phone'] ?? '';
    _licenseController.text = professionalData['license'] ?? '';
    _bioController.text = professionalData['bio'] ?? '';
    _experienceController.text =
        professionalData['yearsExperience']?.toString() ?? '0';
    _locationCityController.text = professionalData['locationCity'] ?? '';
    _locationStateController.text = professionalData['locationState'] ?? '';
    _consultationFeeController.text =
        professionalData['consultationFee']?.toString() ?? '0';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _locationCityController.dispose();
    _locationStateController.dispose();
    _consultationFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (professionalData.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundShapes(),
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildModernAppBar(),
                  Expanded(child: _buildProfessionalInfoTab()),
                ],
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
              'Perfil Profesional',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: IconButton(
                icon: Icon(
                  _isEditing ? Icons.check : Icons.edit,
                  color: AppColors.white,
                ),
                onPressed: _isEditing ? _saveProfile : _toggleEditing,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        0,
        AppSizes.paddingL,
        AppSizes.paddingL,
      ),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: AppSizes.spaceL),
          _buildInfoCard(
            title: 'Información Profesional',
            children: [
              _buildInfoField(
                icon: Icons.person_outline,
                label: 'Nombre',
                controller: _firstNameController,
                enabled: false,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.person,
                label: 'Apellido',
                controller: _lastNameController,
                enabled: false,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.badge_outlined,
                label: 'Cédula profesional',
                controller: _licenseController,
                enabled: _isEditing,
                validator: _validateLicense,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.email_outlined,
                label: 'Correo electrónico',
                value: professionalData['email'],
                enabled: false,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                controller: _phoneController,
                enabled: _isEditing,
                validator: _validatePhone,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.location_on_outlined,
                label: 'Ciudad',
                controller: _locationCityController,
                enabled: _isEditing,
                maxLines: 1,
                validator: _validateLocationCity,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.location_on_outlined,
                label: 'Estado',
                controller: _locationStateController,
                enabled: _isEditing,
                maxLines: 1,
                validator: _validateLocationState,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.work_outline,
                label: 'Años de experiencia',
                controller: _experienceController,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                validator: _validateYearsExperience,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.attach_money,
                label: 'Tarifa de consulta (MXN)',
                controller: _consultationFeeController,
                enabled: _isEditing,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validateConsultationFee,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildMultiSelectField(
                icon: Icons.medical_services_outlined,
                label: 'Especialidades',
                items: _specialties,
                availableOptions: _availableSpecialties,
                onChanged: (selected) {
                  setState(() {
                    _specialties = selected;
                  });
                },
                enabled: _isEditing,
                isRequired: true,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildMultiSelectField(
                icon: Icons.build_outlined,
                label: 'Servicios que ofrece',
                items: _services,
                availableOptions: _availableServices,
                onChanged: (selected) {
                  setState(() {
                    _services = selected;
                  });
                },
                enabled: _isEditing,
                isRequired: true,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildMultiSelectField(
                icon: Icons.pets_outlined,
                label: 'Animales que atiende',
                items: _animalsServed,
                availableOptions: _availableAnimals,
                onChanged: (selected) {
                  setState(() {
                    _animalsServed = selected;
                  });
                },
                enabled: _isEditing,
                isRequired: true,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          _buildInfoCard(
            title: 'Biografía Profesional',
            children: [
              _buildInfoField(
                icon: Icons.description_outlined,
                label: 'Descripción',
                controller: _bioController,
                enabled: _isEditing,
                maxLines: 5,
                validator: _validateBio,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          _buildAvailabilityCard(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
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
        children: [
          Row(
            children: [
              if (_isEditing)
                ProfileImagePickerWidget(
                  imageFile: _selectedImageFile,
                  imageUrl: professionalData['profileImage'],
                  onImageSelected: (file) {
                    setState(() {
                      _selectedImageFile = file;
                    });
                  },
                  size: 80,
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: ClipOval(
                    child:
                        _selectedImageFile != null
                            ? Image.file(_selectedImageFile!, fit: BoxFit.cover)
                            : (professionalData['profileImage'] != null &&
                                professionalData['profileImage'].isNotEmpty)
                            ? Image.network(
                              professionalData['profileImage'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            )
                            : Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primary,
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
                      professionalData['fullName'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceXS),
                    Text(
                      'Cédula: ${professionalData['license']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Verificado',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceL),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    TextEditingController? controller,
    String? value,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSizes.spaceS),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceS),
        if (controller != null)
          TextFormField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary),
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? AppColors.white : AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.2),
                ),
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.2),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.2),
              ),
            ),
            child: Text(
              value ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMultiSelectField({
    required IconData icon,
    required String label,
    required List<String> items,
    required List<String> availableOptions,
    required Function(List<String>) onChanged,
    required bool enabled,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSizes.spaceS),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceS),
        if (enabled)
          InkWell(
            onTap:
                () => _showMultiSelectDialog(
                  title: label,
                  items: items,
                  availableOptions: availableOptions,
                  onChanged: onChanged,
                ),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                        items.isEmpty
                            ? Text(
                              'Seleccionar $label',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary.withOpacity(0.6),
                              ),
                            )
                            : Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children:
                                  items
                                      .map(
                                        (item) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ],
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.2),
              ),
            ),
            child:
                items.isEmpty
                    ? Text(
                      'No se han seleccionado $label',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                    )
                    : Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children:
                          items
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
          ),
      ],
    );
  }

  void _showMultiSelectDialog({
    required String title,
    required List<String> items,
    required List<String> availableOptions,
    required Function(List<String>) onChanged,
  }) {
    List<String> tempSelected = List.from(items);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Seleccionar $title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: availableOptions.length,
                  itemBuilder: (context, index) {
                    final option = availableOptions[index];
                    final isSelected = tempSelected.contains(option);

                    return CheckboxListTile(
                      title: Text(option, style: const TextStyle(fontSize: 14)),
                      value: isSelected,
                      activeColor: AppColors.primary,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (!tempSelected.contains(option)) {
                              tempSelected.add(option);
                            }
                          } else {
                            tempSelected.remove(option);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    onChanged(tempSelected);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Widget _buildAvailabilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              const Expanded(
                child: Text(
                  'Horarios de Disponibilidad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (_isEditing)
                IconButton(
                  onPressed: _showAvailabilityDialog,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  tooltip: 'Editar horarios',
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),
          _availability.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    'No se han configurado horarios de disponibilidad',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: WeekDays.orderedDays.map((day) {
                    final daySchedule = _availability.where((schedule) => 
                      schedule['day'] == day
                    ).toList();
                    
                    return _buildDayScheduleRow(day, daySchedule);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildDayScheduleRow(String day, List<Map<String, dynamic>> schedules) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: schedules.isEmpty 
            ? AppColors.backgroundLight 
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: schedules.isEmpty 
              ? AppColors.textSecondary.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              WeekDays.getDisplayName(day),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: schedules.isEmpty 
                    ? AppColors.textSecondary.withOpacity(0.7)
                    : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: schedules.isEmpty
                ? Text(
                    'No disponible',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: schedules.map((schedule) {
                      final startTime = schedule['start_time'] ?? '';
                      final endTime = schedule['end_time'] ?? '';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$startTime - $endTime',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAvailabilityDialog() {
    List<Map<String, dynamic>> tempAvailability = _availability.map((schedule) => 
      Map<String, dynamic>.from(schedule)
    ).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Configurar Horarios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: WeekDays.orderedDays.map((day) {
                      final daySchedules = tempAvailability.where((schedule) => 
                        schedule['day'] == day
                      ).toList();
                      
                      return _buildDayAvailabilityEditor(
                        day, 
                        daySchedules, 
                        setDialogState,
                        tempAvailability,
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _availability = tempAvailability;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDayAvailabilityEditor(
    String day, 
    List<Map<String, dynamic>> daySchedules,
    StateSetter setDialogState,
    List<Map<String, dynamic>> tempAvailability,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                WeekDays.getDisplayName(day),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Switch(
                    value: daySchedules.isNotEmpty,
                    onChanged: (bool value) {
                      setDialogState(() {
                        if (value) {
                          // Agregar horario por defecto
                          tempAvailability.add({
                            'day': day,
                            'start_time': '09:00',
                            'end_time': '17:00',
                          });
                        } else {
                          // Remover todos los horarios del día
                          tempAvailability.removeWhere((schedule) => 
                            schedule['day'] == day
                          );
                        }
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  if (daySchedules.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        setDialogState(() {
                          tempAvailability.add({
                            'day': day,
                            'start_time': '09:00',
                            'end_time': '17:00',
                          });
                        });
                      },
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      tooltip: 'Agregar horario',
                    ),
                ],
              ),
            ],
          ),
          if (daySchedules.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...daySchedules.asMap().entries.map((entry) {
              final schedule = entry.value;
              final globalIndex = tempAvailability.indexOf(schedule);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: schedule['start_time'],
                        decoration: const InputDecoration(
                          labelText: 'Inicio',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        items: WorkingHours.availableHours.map((hour) {
                          return DropdownMenuItem(
                            value: hour,
                            child: Text(hour),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              tempAvailability[globalIndex]['start_time'] = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: schedule['end_time'],
                        decoration: const InputDecoration(
                          labelText: 'Fin',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        items: WorkingHours.availableHours.map((hour) {
                          return DropdownMenuItem(
                            value: hour,
                            child: Text(hour),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              tempAvailability[globalIndex]['end_time'] = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    if (daySchedules.length > 1)
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            tempAvailability.removeAt(globalIndex);
                          });
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        tooltip: 'Eliminar horario',
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!list2.contains(list1[i])) return false;
    }
    for (int i = 0; i < list2.length; i++) {
      if (!list1.contains(list2[i])) return false;
    }
    return true;
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;

    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SharedPreferencesHelper.getUserId();

      if (userId == null || userId.isEmpty) {
        throw Exception(
          'No se encontró ID del usuario. Por favor, inicia sesión nuevamente.',
        );
      }

      final token = await SharedPreferencesHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'No se encontró token de autenticación. Por favor, inicia sesión nuevamente.',
        );
      }

      final phone = _phoneController.text.trim();
      bool vetNeedsUpdate = false;

      final bio = _bioController.text.trim();
      final experience = int.tryParse(_experienceController.text.trim()) ?? 0;
      final locationCity = _locationCityController.text.trim();
      final locationState = _locationStateController.text.trim();
      final consultationFee =
          double.tryParse(_consultationFeeController.text.trim()) ?? 0.0;

      final currentSpecialties = List<String>.from(
        vetData['specialties'] ?? [],
      );
      // Convertir códigos de IA actuales a nombres legibles para comparación
      final currentSpecialtiesDisplay = currentSpecialties.map((code) => 
        VeterinaryConstants.getDisplayNameFromAICode(code)
      ).toList();
      
      final currentServices = List<String>.from(vetData['services'] ?? []);
      final currentAnimalsServed = List<String>.from(
        vetData['animals_served'] ?? [],
      );

      if (bio != professionalData['bio'] ||
          experience != professionalData['yearsExperience'] ||
          locationCity != professionalData['locationCity'] ||
          locationState != professionalData['locationState'] ||
          consultationFee != professionalData['consultationFee'] ||
          !_listsEqual(_specialties, currentSpecialtiesDisplay) ||
          !_listsEqual(_services, currentServices) ||
          !_listsEqual(_animalsServed, currentAnimalsServed)) {
        vetNeedsUpdate = true;
      }

      if (_selectedImageFile != null || phone != professionalData['phone']) {
        final userUrl =
            'https://web-62dilcrvfkkb.up-de-fra1-k8s-1.apps.run-on-seenode.com/user/$userId';
        final dio = Dio();
        dio.options.headers = {'Authorization': 'Bearer $token'};

        if (_selectedImageFile != null) {
          dio.options.headers['Content-Type'] = 'multipart/form-data';

          final formData = FormData.fromMap({
            'phone': phone,
            'file': await MultipartFile.fromFile(_selectedImageFile!.path),
          });

          final response = await dio.patch(userUrl, data: formData);
          if (response.statusCode == 200) {
            final userData = response.data['data'] ?? response.data;
            if (userData['profile_photo'] != null) {
              await SharedPreferencesHelper.saveUserProfilePhoto(
                userData['profile_photo'],
              );
              professionalData['profileImage'] = userData['profile_photo'];
            }
            if (userData['phone'] != null) {
              await SharedPreferencesHelper.saveUserPhone(userData['phone']);
              professionalData['phone'] = userData['phone'];
            }
          }
        } else {
          dio.options.headers['Content-Type'] = 'application/json';

          final response = await dio.patch(userUrl, data: {'phone': phone});
          if (response.statusCode == 200) {
            final userData = response.data['data'] ?? response.data;
            if (userData['phone'] != null) {
              await SharedPreferencesHelper.saveUserPhone(userData['phone']);
              professionalData['phone'] = userData['phone'];
            }
          }
        }
      }

      if (vetNeedsUpdate) {
        String? vetId = await SharedPreferencesHelper.getVetId();

        if (vetId == null || vetId.isEmpty) {
          try {
            final vetDataSource = sl<VetRemoteDataSource>();
            final vetResponse = await vetDataSource.getVetByUserId(userId);

            final responseData = vetResponse['data'] ?? vetResponse;
            if (responseData == null || responseData['id'] == null) {
              throw Exception(
                'El perfil del veterinario no tiene un ID válido',
              );
            }

            final fullResponse =
                vetResponse.containsKey('message')
                    ? vetResponse
                    : {
                      'message': 'Vet retrieved successfully',
                      'data': vetResponse,
                    };

            await SharedPreferencesHelper.saveVetProfileFromResponse(
              fullResponse,
            );
            vetId = await SharedPreferencesHelper.getVetId();

            if (vetId == null || vetId.isEmpty) {
              vetId = responseData['id']?.toString();
              if (vetId != null && vetId.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('vet_id', vetId);
              } else {
                throw Exception(
                  'No se pudo extraer el ID del veterinario de la respuesta del servidor',
                );
              }
            }
          } catch (e) {
            String errorMessage =
                'No se pudo obtener el perfil del veterinario';

            if (e.toString().contains('404') ||
                e.toString().contains('not found')) {
              errorMessage =
                  'No tienes un perfil de veterinario creado. Por favor, completa tu perfil profesional primero.';
            } else if (e.toString().contains('network') ||
                e.toString().contains('connection')) {
              errorMessage =
                  'Error de conexión. Verifica tu conexión a internet e intenta nuevamente.';
            } else if (e.toString().contains('timeout')) {
              errorMessage = 'Tiempo de espera agotado. Intenta nuevamente.';
            } else if (e is Exception) {
              errorMessage = e.toString().replaceFirst('Exception: ', '');
            }

            throw Exception(errorMessage);
          }
        }

        if (vetId.isEmpty) {
          throw Exception(
            'FALLO CRÍTICO: No se pudo obtener el ID del veterinario después de todos los intentos.',
          );
        }

        // Convertir nombres legibles de vuelta a códigos de IA para guardar en BD
        final specialtyCodesToSave = _specialties.map((displayName) => 
          VeterinaryConstants.getSpecialtyCodeForAI(displayName) ?? displayName
        ).toList();

        final vetDataToSave = {
          'bio': bio,
          'specialties': specialtyCodesToSave,
          'years_experience': experience,
          'location_city': locationCity,
          'location_state': locationState,
          'services': _services,
          'consultation_fee': consultationFee,
          'animals_served': _animalsServed,
          'availability': _availability,
        };

        final vetRemoteDataSource = sl<VetRemoteDataSource>();
        final updatedVet = await vetRemoteDataSource.updateVet(
          vetId,
          userId,
          vetDataToSave,
        );

        final vetResponseData = updatedVet['data'];

        final vetDataForSP = {
          ...vetData,
          'bio': vetResponseData['bio'],
          'specialties': vetResponseData['specialties'],
          'years_experience': vetResponseData['years_experience'],
          'location_city': vetResponseData['location_city'],
          'location_state': vetResponseData['location_state'],
          'services': vetResponseData['services'],
          'consultation_fee': vetResponseData['consultation_fee'],
          'animals_served': vetResponseData['animals_served'],
          'availability': vetResponseData['availability'],
        };
        await SharedPreferencesHelper.saveVetData(vetDataForSP);

        professionalData['bio'] = vetResponseData['bio'];
        professionalData['yearsExperience'] =
            vetResponseData['years_experience'];
        professionalData['locationCity'] = vetResponseData['location_city'];
        professionalData['locationState'] = vetResponseData['location_state'];
        professionalData['consultationFee'] =
            vetResponseData['consultation_fee'];

        // Convertir códigos de IA de vuelta a nombres legibles para mostrar en UI
        final savedSpecialtyCodes = List<String>.from(vetResponseData['specialties'] ?? []);
        _specialties = savedSpecialtyCodes.map((code) => 
          VeterinaryConstants.getDisplayNameFromAICode(code)
        ).toList();
        
        _services = List<String>.from(vetResponseData['services'] ?? []);
        _animalsServed = List<String>.from(
          vetResponseData['animals_served'] ?? [],
        );
        _availability = List<Map<String, dynamic>>.from(
          vetResponseData['availability'] ?? [],
        );
      }

      setState(() {
        _isEditing = false;
        _selectedImageFile = null;
      });

      _initializeControllers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil actualizado correctamente'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Error al actualizar el perfil';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage =
                'Tiempo de conexión agotado. Verifica tu conexión a internet.';
            break;
          case DioExceptionType.badResponse:
            if (e.response?.statusCode == 404) {
              errorMessage =
                  'Perfil no encontrado. Por favor, completa tu perfil profesional primero.';
            } else if (e.response?.statusCode == 400) {
              errorMessage =
                  'Datos inválidos. Revisa la información ingresada.';
            } else {
              errorMessage = 'Error del servidor: ${e.response?.statusCode}';
            }
            break;
          case DioExceptionType.connectionError:
            errorMessage =
                'Error de conexión. Verifica tu conexión a internet.';
            break;
          default:
            errorMessage = 'Error al actualizar el perfil: ${e.message}';
        }
      } else if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
