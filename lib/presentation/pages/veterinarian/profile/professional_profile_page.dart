import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/injection/injection.dart';
import '../../../../data/datasources/user/user_remote_data_source.dart';
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

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _locationCityController = TextEditingController();
  final _locationStateController = TextEditingController();
  final _consultationFeeController = TextEditingController();

  List<String> _specialties = [];
  List<String> _services = [];
  List<String> _animalsServed = [];
  List<Map<String, dynamic>> _availability = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
      final profilePhoto = await SharedPreferencesHelper.getUserProfilePhoto() ?? '';

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
          
          _specialties = List<String>.from(vetData['specialties'] ?? []);
          _services = List<String>.from(vetData['services'] ?? []);
          _animalsServed = List<String>.from(vetData['animals_served'] ?? []);
          _availability = List<Map<String, dynamic>>.from(vetData['availability'] ?? []);
        });
        
        print('📊 Datos del veterinario cargados:');
        print('Nombre completo: ${professionalData['fullName']}');
        print('Licencia: ${professionalData['license']}');
        print('Especialidades: $_specialties');
        print('Servicios: $_services');
      } else {
        print('⚠️ No se encontraron datos del veterinario en SharedPreferences');
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
      print('❌ Error cargando datos del perfil: $e');
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
    
    _bioController.text = professionalData['bio'] ?? '';
    _experienceController.text = professionalData['yearsExperience']?.toString() ?? '0';
    _locationCityController.text = professionalData['locationCity'] ?? '';
    _locationStateController.text = professionalData['locationState'] ?? '';
    _consultationFeeController.text = professionalData['consultationFee']?.toString() ?? '0';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
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
            child: Column(
              children: [
                _buildModernAppBar(),
                Expanded(
                  child: _buildProfessionalInfoTab(),
                ),
              ],
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
      padding: const EdgeInsets.fromLTRB(AppSizes.paddingL, 0, AppSizes.paddingL, AppSizes.paddingL),
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
                value: professionalData['license'],
                enabled: false,
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
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.location_on_outlined,
                label: 'Dirección de consulta',
                controller: _locationCityController,
                enabled: _isEditing,
                maxLines: 1,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.location_on_outlined,
                label: 'Estado',
                controller: _locationStateController,
                enabled: _isEditing,
                maxLines: 1,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.work_outline,
                label: 'Años de experiencia',
                controller: _experienceController,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildInfoField(
                icon: Icons.attach_money,
                label: 'Tarifa de consulta (MXN)',
                controller: _consultationFeeController,
                enabled: _isEditing,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              ),
            ],
          ),
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

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  bool _isValidUUID(String uuid) {
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(uuid);
  }

  Future<void> _updateVetProfile(String vetId, String userId, Map<String, dynamic> vetDataToSave) async {
    final vetRemoteDataSource = sl<VetRemoteDataSource>();
    
    print('🔄 ACTUALIZANDO DATOS DEL VETERINARIO:');
    final updatedVet = await vetRemoteDataSource.updateVet(vetId, userId, vetDataToSave);

    if (updatedVet['data'] != null) {
      print('💾 Actualizando SharedPreferences del veterinario...');
      final vetDataForSP = {
        ...vetData,
        'bio': updatedVet['data']['bio'],
        'specialties': updatedVet['data']['specialties'],
        'years_experience': updatedVet['data']['years_experience'],
        'location_city': updatedVet['data']['location_city'],
        'location_state': updatedVet['data']['location_state'],
        'services': updatedVet['data']['services'],
        'consultation_fee': updatedVet['data']['consultation_fee'],
        'animals_served': updatedVet['data']['animals_served'],
        'availability': updatedVet['data']['availability'],
      };
      await SharedPreferencesHelper.saveVetData(vetDataForSP);

      setState(() {
        professionalData['bio'] = updatedVet['data']['bio'];
        professionalData['yearsExperience'] = updatedVet['data']['years_experience'];
        professionalData['locationCity'] = updatedVet['data']['location_city'];
        professionalData['locationState'] = updatedVet['data']['location_state'];
        professionalData['consultationFee'] = updatedVet['data']['consultation_fee'];
        
        _specialties = List<String>.from(updatedVet['data']['specialties'] ?? []);
        _services = List<String>.from(updatedVet['data']['services'] ?? []);
        _animalsServed = List<String>.from(updatedVet['data']['animals_served'] ?? []);
        _availability = List<Map<String, dynamic>>.from(updatedVet['data']['availability'] ?? []);
        
        _isEditing = false;
        _selectedImageFile = null;
      });

      _initializeControllers();
    } else {
      throw Exception('Respuesta inválida del servidor al actualizar veterinario');
    }
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SharedPreferencesHelper.getUserId();
      print('👤 Usuario ID obtenido: "$userId"');
      
      if (userId == null || userId.isEmpty) {
        throw Exception('No se encontró ID del usuario. Por favor, inicia sesión nuevamente.');
      }

      final token = await SharedPreferencesHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No se encontró token de autenticación. Por favor, inicia sesión nuevamente.');
      }

      print('🔐 Token válido encontrado');

      final phone = _phoneController.text.trim();
      bool userUpdated = false;
      bool vetNeedsUpdate = false;

      final bio = _bioController.text.trim();
      final experience = int.tryParse(_experienceController.text.trim()) ?? 0;
      final locationCity = _locationCityController.text.trim();
      final locationState = _locationStateController.text.trim();
      final consultationFee = double.tryParse(_consultationFeeController.text.trim()) ?? 0.0;

      if (bio != professionalData['bio'] || 
          experience != professionalData['yearsExperience'] ||
          locationCity != professionalData['locationCity'] ||
          locationState != professionalData['locationState'] ||
          consultationFee != professionalData['consultationFee']) {
        vetNeedsUpdate = true;
      }

      if (_selectedImageFile != null || phone != professionalData['phone']) {
        print('📸 ACTUALIZANDO USUARIO (foto/teléfono)...');
        
        final userUrl = 'https://web-62dilcrvfkkb.up-de-fra1-k8s-1.apps.run-on-seenode.com/user/$userId';
        final dio = Dio();
        dio.options.headers = {
          'Authorization': 'Bearer $token',
        };

        if (_selectedImageFile != null) {
          print('📁 Subiendo imagen: ${_selectedImageFile!.path}');
          dio.options.headers['Content-Type'] = 'multipart/form-data';
          
          final formData = FormData.fromMap({
            'phone': phone,
            'file': await MultipartFile.fromFile(_selectedImageFile!.path),
          });
          
          final response = await dio.patch(userUrl, data: formData);
          if (response.statusCode == 200) {
            final userData = response.data['data'] ?? response.data;
            if (userData['profile_photo'] != null) {
              await SharedPreferencesHelper.saveUserProfilePhoto(userData['profile_photo']);
              professionalData['profileImage'] = userData['profile_photo'];
            }
            if (userData['phone'] != null) {
              await SharedPreferencesHelper.saveUserPhone(userData['phone']);
              professionalData['phone'] = userData['phone'];
            }
            userUpdated = true;
            print('✅ Usuario actualizado con imagen');
          }
        } else {
          print('📞 Actualizando solo teléfono');
          dio.options.headers['Content-Type'] = 'application/json';
          
          final response = await dio.patch(userUrl, data: {'phone': phone});
          if (response.statusCode == 200) {
            final userData = response.data['data'] ?? response.data;
            if (userData['phone'] != null) {
              await SharedPreferencesHelper.saveUserPhone(userData['phone']);
              professionalData['phone'] = userData['phone'];
            }
            userUpdated = true;
            print('✅ Teléfono actualizado');
          }
        }
      }

      if (vetNeedsUpdate) {
        print('🩺 ACTUALIZANDO DATOS DEL VETERINARIO...');
        
        print('🔍 OBTENIENDO VET ID PARA ACTUALIZACIÓN...');
        String? vetId = await SharedPreferencesHelper.getVetId();
        print('🔍 getVetId() inicial: "$vetId"');
        
        if (vetId == null || vetId.isEmpty) {
          print('🚨 VET ID VACÍO - INTENTANDO RECARGAR DESDE SERVIDOR...');
          
          try {
            final vetDataSource = sl<VetRemoteDataSource>();
            print('🌐 Realizando petición getVetByUserId para: $userId');
            
            final vetResponse = await vetDataSource.getVetByUserId(userId);
            print('📥 Respuesta cruda del servidor: $vetResponse');
            
            if (vetResponse == null) {
              throw Exception('El servidor devolvió una respuesta vacía. Es posible que no tengas un perfil de veterinario creado.');
            }
            
            if (vetResponse is! Map<String, dynamic>) {
              throw Exception('El servidor devolvió una respuesta en formato inválido: ${vetResponse.runtimeType}');
            }
            
            final responseData = vetResponse['data'] ?? vetResponse;
            if (responseData == null) {
              throw Exception('La respuesta del servidor no contiene datos del veterinario');
            }
            
            if (responseData['id'] == null) {
              throw Exception('El perfil del veterinario no tiene un ID válido');
            }
            
            print('✅ Respuesta válida del servidor recibida');
            
            final fullResponse = vetResponse.containsKey('message') ? vetResponse : {
              'message': 'Vet retrieved successfully',
              'data': vetResponse
            };
            
            await SharedPreferencesHelper.saveVetProfileFromResponse(fullResponse);
            
            vetId = await SharedPreferencesHelper.getVetId();
            print('✅ VET ID REOBTENIDO Y GUARDADO: "$vetId"');
            
            if (vetId == null || vetId.isEmpty) {
              vetId = responseData['id']?.toString();
              print('🔧 EXTRACCIÓN MANUAL DE ID: "$vetId"');
              
              if (vetId != null && vetId.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('vet_id', vetId);
                print('💾 GUARDADO MANUAL EXITOSO');
              } else {
                throw Exception('No se pudo extraer el ID del veterinario de la respuesta del servidor');
              }
            }
            
          } catch (e) {
            print('❌ Error detallado al recargar datos del veterinario: $e');
            String errorMessage = 'No se pudo obtener el perfil del veterinario';
            
            if (e.toString().contains('404') || e.toString().contains('not found')) {
              errorMessage = 'No tienes un perfil de veterinario creado. Por favor, completa tu perfil profesional primero.';
            } else if (e.toString().contains('network') || e.toString().contains('connection')) {
              errorMessage = 'Error de conexión. Verifica tu conexión a internet e intenta nuevamente.';
            } else if (e.toString().contains('timeout')) {
              errorMessage = 'Tiempo de espera agotado. Intenta nuevamente.';
            } else if (e is Exception) {
              errorMessage = e.toString().replaceFirst('Exception: ', '');
            }
            
            throw Exception(errorMessage);
          }
        }

        if (vetId == null || vetId.isEmpty) {
          throw Exception('FALLO CRÍTICO: No se pudo obtener el ID del veterinario después de todos los intentos. Por favor, contacta al soporte técnico.');
        }

        print('🆔 VetId final validado: $vetId');
        print('🆔 UserId validado: $userId');

        final vetDataToSave = {
          'bio': bio,
          'specialties': _specialties,
          'years_experience': experience,
          'location_city': locationCity,
          'location_state': locationState,
          'services': _services,
          'consultation_fee': consultationFee,
          'animals_served': _animalsServed,
          'availability': _availability,
        };

        print('📋 Datos a actualizar: $vetDataToSave');

        final vetRemoteDataSource = sl<VetRemoteDataSource>();
        final updatedVet = await vetRemoteDataSource.updateVet(vetId, userId, vetDataToSave);

        if (updatedVet != null && updatedVet['data'] != null) {
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
          professionalData['yearsExperience'] = vetResponseData['years_experience'];
          professionalData['locationCity'] = vetResponseData['location_city'];
          professionalData['locationState'] = vetResponseData['location_state'];
          professionalData['consultationFee'] = vetResponseData['consultation_fee'];
          
          _specialties = List<String>.from(vetResponseData['specialties'] ?? []);
          _services = List<String>.from(vetResponseData['services'] ?? []);
          _animalsServed = List<String>.from(vetResponseData['animals_served'] ?? []);
          _availability = List<Map<String, dynamic>>.from(vetResponseData['availability'] ?? []);

          print('✅ Veterinario actualizado exitosamente');
        } else {
          throw Exception('La respuesta del servidor para la actualización del veterinario es inválida');
        }
      }

      setState(() {
        _isEditing = false;
        _selectedImageFile = null;
      });

      _initializeControllers();

      print('✅ Perfil actualizado correctamente');
      print('Usuario actualizado: $userUpdated');
      print('Veterinario actualizado: $vetNeedsUpdate');

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
      print('❌ Error actualizando perfil profesional: $e');
      
      String errorMessage = 'Error al actualizar el perfil';
      
      if (e is DioException) {
        print('❌ Dio Error type: ${e.type}');
        print('❌ Dio Error message: ${e.message}');
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
        
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Tiempo de conexión agotado. Verifica tu conexión a internet.';
            break;
          case DioExceptionType.badResponse:
            if (e.response?.statusCode == 404) {
              errorMessage = 'Perfil no encontrado. Por favor, completa tu perfil profesional primero.';
            } else {
              errorMessage = 'Error del servidor: ${e.response?.statusCode}';
            }
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'Error de conexión. Verifica tu conexión a internet.';
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