import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/injection/injection.dart';
import '../../../../data/datasources/user/user_remote_data_source.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../domain/usecases/auth/logout_usecase.dart';
import '../../../widgets/common/profile_image_picker_widget.dart';

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  bool _isEditing = false;
  bool _isLoading = false;
  Map<String, dynamic> userData = {};
  File? _selectedImageFile;

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserService.getCurrentUser();
    setState(() {
      userData = {
        'firstName': user['firstName'],
        'lastName': user['lastName'],
        'fullName': user['fullName'],
        'email': user['email'],
        'phone': user['phone'],
        'profileImage': user['profilePhoto'],
      };
    });
    _updateControllers();
  }

  void _updateControllers() {
    _firstNameController.text = userData['firstName'] ?? '';
    _lastNameController.text = userData['lastName'] ?? '';
    _phoneController.text = userData['phone'] ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _buildDecorativeShapes() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        Positioned(
          top: 150,
          left: -80,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(75),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userData.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFBDE3FF), Color(0xFFE8F5E8), Color(0xFFE5F3FF)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFBDE3FF), Color(0xFFE8F5E8), Color(0xFFE5F3FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildDecorativeShapes(),
            SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildModernAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.paddingL),
                        child: Column(
                          children: [
                            _buildModernProfileHeader(),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildModernPersonalInfoCard(),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildModernOptionsCard(),
                            const SizedBox(height: AppSizes.spaceXL),
                          ],
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
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          const SizedBox(width: AppSizes.spaceM),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi Perfil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Gestiona tu información personal',
                  style: TextStyle(fontSize: 14, color: AppColors.white),
                ),
              ],
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

  Widget _buildModernProfileHeader() {
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
            color: AppColors.secondary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.paddingM),
              child: Column(
                children: [
                  if (_isEditing)
                    ProfileImagePickerWidget(
                      imageFile: _selectedImageFile,
                      imageUrl: userData['profileImage'],
                      onImageSelected: (file) {
                        setState(() {
                          _selectedImageFile = file;
                        });
                      },
                      size: 120,
                    )
                  else
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary,
                            AppColors.secondary.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                        ),
                        child: ClipOval(
                          child:
                              _selectedImageFile != null
                                  ? Image.file(
                                    _selectedImageFile!,
                                    fit: BoxFit.cover,
                                  )
                                  : (userData['profileImage'] != null &&
                                      userData['profileImage'].isNotEmpty)
                                  ? Image.network(
                                    userData['profileImage'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildModernDefaultAvatar();
                                    },
                                  )
                                  : _buildModernDefaultAvatar(),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSizes.spaceL),
                  Text(
                    userData['fullName'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spaceS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                          size: AppSizes.iconS,
                        ),
                        const SizedBox(width: AppSizes.spaceS),
                        Text(
                          userData['email'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_rounded, size: 60, color: AppColors.secondary),
    );
  }

  Widget _buildModernPersonalInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingS),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.accent.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceM),
                      const Text(
                        'Información Personal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceL),
                  _buildModernInfoField(
                    icon: Icons.person_outline,
                    label: 'Nombre',
                    controller: _firstNameController,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      if (value.trim().length < 2) {
                        return 'El nombre debe tener al menos 2 caracteres';
                      }
                      if (value.trim().length > 50) {
                        return 'El nombre no puede exceder 50 caracteres';
                      }
                      if (RegExp(r'[0-9]').hasMatch(value)) {
                        return 'El nombre no puede contener números';
                      }
                      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                        return 'El nombre no puede contener caracteres especiales';
                      }
                      if (RegExp(r'^\s|\s$').hasMatch(value)) {
                        return 'El nombre no puede empezar o terminar con espacios';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  _buildModernInfoField(
                    icon: Icons.person,
                    label: 'Apellido',
                    controller: _lastNameController,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El apellido es obligatorio';
                      }
                      if (value.trim().length < 2) {
                        return 'El apellido debe tener al menos 2 caracteres';
                      }
                      if (value.trim().length > 50) {
                        return 'El apellido no puede exceder 50 caracteres';
                      }
                      if (RegExp(r'[0-9]').hasMatch(value)) {
                        return 'El apellido no puede contener números';
                      }
                      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                        return 'El apellido no puede contener caracteres especiales';
                      }
                      if (RegExp(r'^\s|\s$').hasMatch(value)) {
                        return 'El apellido no puede empezar o terminar con espacios';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  _buildModernInfoField(
                    icon: Icons.email_outlined,
                    label: 'Correo electrónico',
                    value: userData['email'],
                    enabled: false,
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  _buildModernInfoField(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    controller: _phoneController,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El teléfono es obligatorio';
                      }
                      final cleanedValue = value.replaceAll(
                        RegExp(r'[\s\-\(\)]'),
                        '',
                      );
                      if (cleanedValue.length < 8) {
                        return 'El teléfono debe tener al menos 8 dígitos';
                      }
                      if (cleanedValue.length > 15) {
                        return 'El teléfono no puede exceder 15 dígitos';
                      }
                      if (!RegExp(r'^[0-9+\s\-\(\)]+$').hasMatch(value)) {
                        return 'El teléfono solo puede contener números, +, -, ( ), y espacios';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoField({
    required IconData icon,
    required String label,
    TextEditingController? controller,
    String? value,
    required bool enabled,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: enabled ? AppColors.white : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color:
              enabled
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: enabled ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.spaceS),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: enabled ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceS),
          TextFormField(
            controller: controller,
            initialValue: controller == null ? value : null,
            enabled: enabled,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              errorStyle: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOptionsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: AppColors.error.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.error, AppColors.error.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingS),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.error,
                              AppColors.error.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceM),
                      const Text(
                        'Opciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceL),
                  _buildModernOptionItem(
                    icon: Icons.logout_rounded,
                    title: 'Cerrar sesión',
                    onTap: _showLogoutDialog,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? AppColors.error.withOpacity(0.05)
                    : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color:
                  isDestructive
                      ? AppColors.error.withOpacity(0.2)
                      : AppColors.textSecondary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    isDestructive ? AppColors.error : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDestructive ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color:
                    isDestructive ? AppColors.error : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor corrige los errores en el formulario'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SharedPreferencesHelper.getUserId();
      if (userId == null) {
        throw Exception('No se encontró ID del usuario');
      }

      final token = await SharedPreferencesHelper.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();

      final url =
          'https://web-62dilcrvfkkb.up-de-fra1-k8s-1.apps.run-on-seenode.com/user/$userId';

      final dio = Dio();
      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      print('🔄 ACTUALIZANDO PERFIL DE USUARIO:');
      print('URL: $url');
      print('User ID: $userId');
      print('Token disponible: ${token.isNotEmpty ? 'SÍ' : 'NO'}');

      late Response response;

      if (_selectedImageFile != null) {
        if (!await _selectedImageFile!.exists()) {
          throw Exception(
            'Archivo de imagen no encontrado. Por favor, selecciona la imagen nuevamente.',
          );
        }

        final fileSize = await _selectedImageFile!.length();
        print('📁 Archivo encontrado: ${_selectedImageFile!.path}');
        print('📏 Tamaño: $fileSize bytes');

        dio.options.headers['Content-Type'] = 'multipart/form-data';

        final formData = FormData.fromMap({
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'file': await MultipartFile.fromFile(
            _selectedImageFile!.path,
            filename: _selectedImageFile!.path.split('/').last,
          ),
        });

        print(
          '📤 Enviando con imagen - FormData fields: ${formData.fields.length}',
        );
        print('📤 FormData files: ${formData.files.length}');

        response = await dio.patch(url, data: formData);
      } else {
        final requestData = {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        };

        print('📤 Enviando sin imagen - Data: $requestData');

        response = await dio.patch(url, data: requestData);
      }

      print('✅ RESPUESTA DEL SERVIDOR:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> updatedUser;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            updatedUser = responseData['data'];
          } else {
            updatedUser = responseData;
          }
        } else {
          throw Exception('Formato de respuesta inválido');
        }

        if (updatedUser['first_name'] != null) {
          await SharedPreferencesHelper.saveUserFirstName(
            updatedUser['first_name'],
          );
        }
        if (updatedUser['last_name'] != null) {
          await SharedPreferencesHelper.saveUserLastName(
            updatedUser['last_name'],
          );
        }
        if (updatedUser['phone'] != null) {
          await SharedPreferencesHelper.saveUserPhone(updatedUser['phone']);
        }
        if (updatedUser['profile_photo'] != null) {
          await SharedPreferencesHelper.saveUserProfilePhoto(
            updatedUser['profile_photo'],
          );
        }

        setState(() {
          this.userData['firstName'] = updatedUser['first_name'] ?? firstName;
          this.userData['lastName'] = updatedUser['last_name'] ?? lastName;
          this.userData['fullName'] =
              '${updatedUser['first_name'] ?? firstName} ${updatedUser['last_name'] ?? lastName}';
          this.userData['phone'] = updatedUser['phone'] ?? phone;
          if (updatedUser['profile_photo'] != null) {
            this.userData['profileImage'] = updatedUser['profile_photo'];
          }
          _isEditing = false;
          _selectedImageFile = null;
        });

        _updateControllers();

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

        print('✅ Perfil actualizado exitosamente');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error actualizando perfil: $e');

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
            errorMessage =
                'Tiempo de conexión agotado. Verifica tu conexión a internet.';
            break;
          case DioExceptionType.badResponse:
            errorMessage = 'Error del servidor: ${e.response?.statusCode}';
            break;
          case DioExceptionType.connectionError:
            errorMessage =
                'Error de conexión. Verifica tu conexión a internet.';
            break;
          default:
            errorMessage = 'Error al actualizar el perfil: ${e.message}';
        }
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: AppSizes.iconM,
                ),
                const SizedBox(width: AppSizes.spaceS),
                const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            content: const Text(
              '¿Estás seguro de que quieres cerrar sesión?',
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  
                  try {
                    // Ejecutar logout completo usando el usecase
                    final logoutUseCase = sl<LogoutUseCase>();
                    await logoutUseCase.call();
                    
                    print('🔐 Logout ejecutado correctamente');
                  } catch (e) {
                    print('⚠️ Error durante logout: $e');
                    // Incluso si hay error, limpiar datos localmente
                    await SharedPreferencesHelper.clearLoginData();
                  }
                  
                  // Navegar a login eliminando todo el stack
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
