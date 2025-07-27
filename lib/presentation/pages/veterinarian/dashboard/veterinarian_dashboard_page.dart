import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/services/user_service.dart';
import '../../../../core/injection/injection.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../data/datasources/vet/vet_remote_datasource.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/usecases/appointment/get_upcoming_appointments_usecase.dart';
import '../../../../domain/entities/appointment.dart' as domain;

class VeterinarianDashboardPage extends StatefulWidget {
  const VeterinarianDashboardPage({super.key});

  @override
  State<VeterinarianDashboardPage> createState() =>
      _VeterinarianDashboardPageState();
}

class _VeterinarianDashboardPageState extends State<VeterinarianDashboardPage> {
  String _userGreeting = 'Cargando...';
  bool _isCheckingVetProfile = true;
  String? _vetProfilePhoto;
  String _vetFirstName = '';
  
  // Nuevas variables para las citas
  List<domain.Appointment> _todayAppointments = [];
  bool _isLoadingAppointments = false;
  String? _appointmentsError;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _loadUserData();
    await _checkVetProfile();
    await _loadTodayAppointments(); // Agregar carga de citas
  }

  Future<void> _loadUserData() async {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Buenos días';
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
    } else {
      greeting = 'Buenas noches';
    }

    try {
      final firstName = await SharedPreferencesHelper.getUserFirstName() ?? '';
      final profilePhoto =
          await SharedPreferencesHelper.getUserProfilePhoto() ?? '';

      if (mounted) {
        setState(() {
          _userGreeting = greeting;
          _vetFirstName = firstName.isNotEmpty ? firstName : 'Doctor';
          _vetProfilePhoto = profilePhoto.isNotEmpty ? profilePhoto : null;
        });
      }
    } catch (e) {
      print('Error cargando datos del veterinario: $e');
      if (mounted) {
        setState(() {
          _userGreeting = greeting;
          _vetFirstName = 'Doctor';
          _vetProfilePhoto = null;
        });
      }
    }
  }

  Future<void> _checkVetProfile() async {
    try {
      setState(() {
        _isCheckingVetProfile = true;
      });

      final userId = await SharedPreferencesHelper.getUserId();
      print('👤 User ID obtenido: "$userId"');

      if (userId == null || userId.isEmpty) {
        print('❌ No se encontró userId válido en SharedPreferences');
        throw Exception(
          'No se encontró información del usuario. Por favor, inicia sesión nuevamente.',
        );
      }

      final savedVetData = await SharedPreferencesHelper.getVetData();
      if (savedVetData != null && savedVetData.isNotEmpty) {
        print('✅ Datos del veterinario encontrados en SharedPreferences');
        print(
          'Veterinario: ${savedVetData['name']} - Licencia: ${savedVetData['license']}',
        );
        await _updateHeaderData();
        return;
      }

      print(
        '🔍 No se encontraron datos locales, verificando en servidor para userId: $userId',
      );

      final vetDataSource = sl<VetRemoteDataSource>();

      try {
        final vetResponse = await vetDataSource.getVetByUserId(userId);
        print('📥 Respuesta del servidor: $vetResponse');

        if (vetResponse == null) {
          print('❌ El servidor devolvió una respuesta null');
          throw Exception(
            'No se encontró perfil de veterinario para este usuario',
          );
        }

        if (vetResponse is! Map<String, dynamic>) {
          print(
            '❌ La respuesta del servidor no es un mapa válido: ${vetResponse.runtimeType}',
          );
          throw Exception('Formato de respuesta inválido del servidor');
        }

        final fullResponse =
            vetResponse.containsKey('message')
                ? vetResponse
                : {
                  'message': 'Vet retrieved successfully',
                  'data': vetResponse,
                };

        await SharedPreferencesHelper.saveVetProfileFromResponse(fullResponse);
        print('✅ Veterinario encontrado en servidor y guardado localmente');

        await _updateHeaderData();
      } catch (e) {
        print('❌ Error específico al obtener datos del veterinario: $e');

        if (e.toString().contains('404') ||
            e.toString().contains('not found') ||
            e.toString().contains('no encontrado')) {
          print(
            '🚨 Veterinario no encontrado - Mostrando modal de completar perfil',
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              print('🔄 Widget montado, mostrando modal...');
              _showCompleteProfileModal();
            } else {
              print('❌ Widget no montado, no se puede mostrar modal');
            }
          });
        } else {
          rethrow;
        }
      }
    } catch (e) {
      print('❌ Error general al verificar perfil de veterinario: $e');

      String errorMessage = 'Error al verificar el perfil del veterinario';

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Error de conexión. Verifica tu conexión a internet.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Tiempo de espera agotado. Intenta nuevamente.';
      } else if (e.toString().contains('inicia sesión')) {
        errorMessage = e.toString();
      }

      if (!e.toString().contains('404') &&
          !e.toString().contains('not found')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVetProfile = false;
        });
      }
    }
  }

  Future<void> _updateHeaderData() async {
    try {
      final firstName = await SharedPreferencesHelper.getUserFirstName() ?? '';
      final profilePhoto =
          await SharedPreferencesHelper.getUserProfilePhoto() ?? '';

      if (mounted) {
        setState(() {
          _vetFirstName = firstName.isNotEmpty ? firstName : 'Doctor';
          _vetProfilePhoto = profilePhoto.isNotEmpty ? profilePhoto : null;
        });
      }
    } catch (e) {
      print('Error actualizando datos del header: $e');
    }
  }

  void _showCompleteProfileModal() {
    print('🔄 Intentando mostrar modal de completar perfil');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: AppColors.black.withOpacity(0.3)),
              ),
              Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: AppColors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceL),

                      const Text(
                        'Completa tu perfil profesional',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceM),

                      const Text(
                        'Para utilizar tu cuenta de veterinario, necesitas completar la siguiente información profesional.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceXL),

                      Container(
                        width: double.infinity,
                        height: AppSizes.buttonHeightL,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showVetProfileForm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusL,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showVetProfileForm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => VetProfileFormModal(
            onProfileCompleted: () {
              Navigator.pop(context);
              _checkVetProfile();
              _updateHeaderData();
            },
          ),
    );
  }

  // Nuevo método para cargar citas de hoy
  Future<void> _loadTodayAppointments() async {
    setState(() {
      _isLoadingAppointments = true;
      _appointmentsError = null;
    });

    try {
      // Obtener el vet UUID desde SharedPreferences
      final vetId = await SharedPreferencesHelper.getVetId();
      
      if (vetId == null || vetId.isEmpty) {
        throw Exception('No se encontró el ID del veterinario');
      }

      print('🔍 Cargando citas para veterinario: $vetId');

      // Usar el use case para obtener las citas
      final getVetAppointmentsUseCase = sl<GetVetAppointmentsUseCase>();
      final appointments = await getVetAppointmentsUseCase.call(vetId);

      // Filtrar solo las citas de hoy
      final today = DateTime.now();
      final todayAppointments = appointments.where((appointment) {
        final appointmentDate = appointment.appointmentDate;
        return _isSameDay(appointmentDate, today);
      }).toList();

      // Ordenar las citas por hora
      todayAppointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

      setState(() {
        _todayAppointments = todayAppointments;
        _isLoadingAppointments = false;
      });

      print('✅ Citas de hoy cargadas: ${todayAppointments.length}');
    } catch (e) {
      print('❌ Error cargando citas de hoy: $e');
      
      String errorMessage = 'Error al cargar las citas de hoy';
      
      if (e.toString().contains('No se encontró el ID del veterinario')) {
        errorMessage = 'No se pudo identificar al veterinario';
      } else if (e.toString().contains('connection') || e.toString().contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu internet';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Tiempo de espera agotado';
      }
      
      setState(() {
        _appointmentsError = errorMessage;
        _isLoadingAppointments = false;
      });
    }
  }

  // Método auxiliar para comparar fechas
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Funciones auxiliares para mapear datos de Appointment (simplificadas)
  String _getPetName(domain.Appointment appointment) {
    return appointment.pet?.name ?? 'Mascota';
  }

  String _getAppointmentTime(domain.Appointment appointment) {
    final time = appointment.appointmentDate;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingVetProfile) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF0D9488),
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),
              const Text(
                'Verificando perfil profesional...',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundShapes(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSizes.spaceXL),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTodayStats(),
                        const SizedBox(height: AppSizes.spaceXL),
                        _buildTodaySchedule(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
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

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _userGreeting,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnDark,
                        ),
                      ),
                      if (_vetFirstName.isNotEmpty) ...[
                        const TextSpan(
                          text: ', ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnDark,
                          ),
                        ),
                        TextSpan(
                          text: 'Dr. $_vetFirstName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spaceS),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child:
                  _vetProfilePhoto != null && _vetProfilePhoto!.isNotEmpty
                      ? Image.network(
                        _vetProfilePhoto!,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(38),
                            ),
                            child: const Icon(
                              Icons.medical_services_rounded,
                              color: AppColors.white,
                              size: 40,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(38),
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
                      : Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(38),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: AppColors.white,
                          size: 40,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    // Calcular estadísticas reales simplificadas
    final totalAppointments = _todayAppointments.length;
    final completedAppointments = _todayAppointments
        .where((app) => app.status == domain.AppointmentStatus.completed)
        .length;
    final uniquePets = _todayAppointments
        .map((app) => app.pet?.id)
        .where((id) => id != null)
        .toSet()
        .length;
    final pendingAppointments = _todayAppointments
        .where((app) => app.status == domain.AppointmentStatus.pending)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen de Hoy',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spaceL),
        Container(
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
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: 'Citas',
                  value: '$totalAppointments',
                  subtitle: '$completedAppointments completadas',
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.spaceL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.3),
                      AppColors.primary.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  title: 'Pacientes',
                  value: '$uniquePets',
                  subtitle: '$pendingAppointments pendientes',
                  icon: Icons.pets_rounded,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Icon(icon, color: color, size: AppSizes.iconL),
        ),
        const SizedBox(height: AppSizes.spaceM),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXS),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTodaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Agenda de Hoy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            )
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),
        _isLoadingAppointments
            ? _buildLoadingCard()
            : _appointmentsError != null
                ? _buildErrorCard()
                : _todayAppointments.isEmpty
                    ? _buildNoAppointmentsCard()
                    : _buildAppointmentsList(),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppSizes.spaceM),
            const Text(
              'Cargando citas de hoy...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: AppSizes.iconL,
            ),
            const SizedBox(height: AppSizes.spaceM),
            const Text(
              'Error al cargar las citas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceS),
            TextButton(
              onPressed: _loadTodayAppointments,
              child: Text(
                'Reintentar',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAppointmentsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Icon(
                Icons.event_available_rounded,
                color: AppColors.primary,
                size: AppSizes.iconL,
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            const Text(
              'No hay citas programadas para hoy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              '¡Disfruta tu día libre!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    // Validar que hay citas disponibles
    if (_todayAppointments.isEmpty) {
      return _buildNoAppointmentsCard();
    }

    // Obtener la próxima cita (primera no completada)
    domain.Appointment? nextAppointment;
    
    try {
      nextAppointment = _todayAppointments.firstWhere(
        (appointment) => appointment.status != domain.AppointmentStatus.completed,
      );
    } catch (e) {
      // Si no hay citas no completadas, tomar la primera disponible
      nextAppointment = _todayAppointments.first;
    }

    return Column(
      children: [
        // Mostrar la próxima cita destacada
        _buildNextAppointmentCard(nextAppointment),
        
        // Si hay más citas, mostrar un resumen
        if (_todayAppointments.length > 1) ...[
          const SizedBox(height: AppSizes.spaceM),
          _buildAdditionalAppointmentsSummary(),
        ],
      ],
    );
  }

  Widget _buildNextAppointmentCard(domain.Appointment appointment) {
    final time = _getAppointmentTime(appointment);
    final petName = _getPetName(appointment);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/appointment-detail-vet',
          arguments: appointment.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.darkBlue],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Text(
                time,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceS),
                  Text(
                    'Próxima cita',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Text(
                'Hoy',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalAppointmentsSummary() {
    final remainingCount = _todayAppointments.length - 1;
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.more_horiz,
                color: AppColors.primary,
                size: AppSizes.iconM,
              ),
              const SizedBox(width: AppSizes.spaceS),
              Text(
                '$remainingCount cita${remainingCount > 1 ? 's' : ''} más programada${remainingCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class VetProfileFormModal extends StatefulWidget {
  final VoidCallback onProfileCompleted;

  const VetProfileFormModal({super.key, required this.onProfileCompleted});

  @override
  State<VetProfileFormModal> createState() => _VetProfileFormModalState();
}

class _VetProfileFormModalState extends State<VetProfileFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  String _fullName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final firstName = await SharedPreferencesHelper.getUserFirstName();
    final lastName = await SharedPreferencesHelper.getUserLastName();

    setState(() {
      _fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    });

    print('📝 Nombre construido automáticamente: $_fullName');
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndSaveVetData(String userId) async {
    try {
      print('🔄 Obteniendo datos completos del veterinario...');
      print('User ID: $userId');

      if (userId.isEmpty) {
        throw Exception('User ID está vacío');
      }

      final vetDataSource = sl<VetRemoteDataSource>();
      final vetResponse = await vetDataSource.getVetByUserId(userId);

      print('📥 Datos del veterinario obtenidos: $vetResponse');

      if (vetResponse == null) {
        throw Exception('El servidor devolvió una respuesta vacía');
      }

      if (vetResponse is! Map<String, dynamic>) {
        throw Exception(
          'El servidor devolvió un formato de respuesta inválido: ${vetResponse.runtimeType}',
        );
      }

      final fullResponse =
          vetResponse.containsKey('message')
              ? vetResponse
              : {'message': 'Vet retrieved successfully', 'data': vetResponse};

      await SharedPreferencesHelper.saveVetProfileFromResponse(fullResponse);

      print('✅ Datos del veterinario guardados en SharedPreferences');
    } catch (e) {
      print('❌ Error al obtener y guardar datos del veterinario: $e');

      String errorMessage = 'Error al obtener datos del veterinario';

      if (e.toString().contains('404') || e.toString().contains('not found')) {
        errorMessage =
            'No se encontró el perfil del veterinario después de crearlo. Intenta nuevamente.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Error de conexión al obtener datos del veterinario.';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'Tiempo de espera agotado al obtener datos del veterinario.';
      }

      throw Exception(errorMessage);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SharedPreferencesHelper.getUserId();
      if (userId == null) {
        throw Exception('No se encontró ID del usuario');
      }

      final vetData = {
        'name': _fullName,
        'description': _descriptionController.text.trim(),
        'user_id': userId,
      };

      print('📋 Enviando datos del veterinario: $vetData');

      final vetDataSource = sl<VetRemoteDataSource>();
      await vetDataSource.createVet(vetData);

      print('✅ Perfil de veterinario creado exitosamente');

      await _fetchAndSaveVetData(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil profesional completado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onProfileCompleted();
      }
    } catch (e) {
      print('❌ Error al crear perfil de veterinario: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al completar el perfil: $e'),
            backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: AppColors.black.withOpacity(0.3)),
        ),
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            color: AppColors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceM),
                        const Expanded(
                          child: Text(
                            'Información Profesional',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceXL),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                color: Color(0xFF0D9488),
                                size: 20,
                              ),
                              const SizedBox(width: AppSizes.spaceS),
                              const Text(
                                'Nombre profesional',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0D9488),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.spaceS),
                          Text(
                            _fullName.isNotEmpty ? _fullName : 'Cargando...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spaceS),
                          const Text(
                            'Este nombre se obtiene automáticamente de tu perfil',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceL),

                    TextFormField(
                      controller: _licenseController,
                      decoration: InputDecoration(
                        labelText: 'Cédula profesional',
                        hintText: '09718342',
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu cédula profesional';
                        }
                        if (value.trim().length < 4) {
                          return 'La cédula profesional debe tener al menos 4 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spaceM),

                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(color: const Color(0xFFFFE69C)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFB45309),
                            size: 16,
                          ),
                          const SizedBox(width: AppSizes.spaceS),
                          Expanded(
                            child: Text(
                              'Tu cédula profesional será validada con el Registro Nacional de Profesionales Veterinarios',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB45309),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceL),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Descripción profesional',
                        hintText:
                            'Veterinario especializado en cirugía y medicina preventiva...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(
                            Icons.description_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        if (value.trim().length < 20) {
                          return 'La descripción debe tener al menos 20 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spaceXL),

                    Container(
                      width: double.infinity,
                      height: AppSizes.buttonHeightL,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusL,
                            ),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : const Text(
                                  'Completar Perfil Profesional',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
