import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/injection/injection.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../domain/usecases/auth/logout_usecase.dart';

class VetSettingsPage extends StatefulWidget {
  const VetSettingsPage({super.key});

  @override
  State<VetSettingsPage> createState() => _VetSettingsPageState();
}

class _VetSettingsPageState extends State<VetSettingsPage> {
  Map<String, dynamic> userData = {};
  String? _vetProfilePhoto;
  String _vetName = '';
  String _vetSpecialty = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Cargar datos básicos del usuario
      final user = await UserService.getCurrentUser();
      
      // Cargar foto de perfil desde SharedPreferences
      final profilePhoto = await SharedPreferencesHelper.getUserProfilePhoto() ?? '';
      final firstName = await SharedPreferencesHelper.getUserFirstName() ?? '';
      final lastName = await SharedPreferencesHelper.getUserLastName() ?? '';
      
      // Construir nombre completo
      String fullName = 'Dr. Usuario';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        fullName = 'Dr. ${firstName.isNotEmpty ? firstName : ''} ${lastName.isNotEmpty ? lastName : ''}'.trim();
      }
      
      // Obtener especialidad del veterinario
      String specialty = 'Sin especialidades registradas';
      final vetData = await SharedPreferencesHelper.getVetData();
      if (vetData != null && vetData.isNotEmpty) {
        final specialties = vetData['specialties'] as List?;
        if (specialties != null && specialties.isNotEmpty) {
          // Convertir la lista a List<String> y tomar máximo 3 especialidades
          final specialtiesList = specialties.map((e) => e.toString()).toList();
          if (specialtiesList.length == 1) {
            specialty = specialtiesList.first;
          } else if (specialtiesList.length == 2) {
            specialty = specialtiesList.join(' • ');
          } else {
            specialty = '${specialtiesList.take(2).join(' • ')} • +${specialtiesList.length - 2} más';
          }
        } else {
          // Si no hay especialidades, revisar si hay una especialización general
          final specialization = vetData['specialization']?.toString();
          if (specialization != null && specialization.isNotEmpty) {
            specialty = specialization;
          }
        }
      }

      setState(() {
        userData = user;
        _vetProfilePhoto = profilePhoto.isNotEmpty ? profilePhoto : null;
        _vetName = fullName;
        _vetSpecialty = specialty;
      });
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      setState(() {
        userData = {};
        _vetProfilePhoto = null;
        _vetName = 'Dr. Usuario';
        _vetSpecialty = 'Sin especialidades registradas';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData.isEmpty) {
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernAppBar(),
                  const SizedBox(height: AppSizes.spaceL),
                  _buildUserHeader(),
                  const SizedBox(height: AppSizes.spaceL),
                  _buildAccountSettings(),
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
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Configuraciones',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusL - 2),
              child: _vetProfilePhoto != null && _vetProfilePhoto!.isNotEmpty
                  ? Image.network(
                      _vetProfilePhoto!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppSizes.radiusL - 2),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.white,
                            size: 32,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppSizes.radiusL - 2),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _vetName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceXS),
                Text(
                  _vetSpecialty,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceXS),
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
    );
  }

  Widget _buildAccountSettings() {
    return _buildSettingsSection(
      title: 'Configuración de Cuenta',
      icon: Icons.account_circle_outlined,
      children: [
        _buildActionTile(
          icon: Icons.person_outline,
          title: 'Editar perfil profesional',
          subtitle: 'Actualiza tu información y especialidades',
          onTap: () {
            Navigator.pushNamed(context, '/professional-profile');
          },
        ),
        _buildActionTile(
          icon: Icons.schedule_outlined,
          title: 'Configuración de horarios',
          subtitle: 'Gestiona tu agenda y disponibilidad',
          onTap: () {
            Navigator.pushNamed(context, '/configure-schedule');
          },
        ),
        _buildActionTile(
          icon: Icons.logout,
          title: 'Cerrar sesión',
          subtitle: 'Salir de la aplicación',
          onTap: _showLogoutDialog,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? AppColors.error.withOpacity(0.05)
                    : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(
              color:
                  isDestructive
                      ? AppColors.error.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color:
                      isDestructive
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color:
                            isDestructive
                                ? AppColors.error
                                : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceXS),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color:
                        isDestructive
                            ? AppColors.error
                            : AppColors.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            content: const Text(
              '¿Estás seguro de que quieres cerrar sesión?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                  onPressed: () async {
                    // Cerrar el diálogo primero
                    Navigator.pop(context);
                    
                    // Verificar que el context sigue siendo válido
                    if (!mounted) return;
                    
                    try {
                      print('🔐 Iniciando proceso de logout...');
                      
                      // Ejecutar logout completo usando el usecase
                      final logoutUseCase = sl<LogoutUseCase>();
                      await logoutUseCase.call();
                      
                      print('🔐 Logout ejecutado correctamente');
                      
                      // Verificar que el widget sigue montado antes de navegar
                      if (mounted) {
                        // Navegar a login y limpiar stack completo
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      print('⚠️ Error durante logout: $e');
                      
                      // Verificar que el widget sigue montado antes de navegar
                      if (mounted) {
                        // Aunque haya error, navegar a login
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
