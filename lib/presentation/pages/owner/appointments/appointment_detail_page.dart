import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/injection/injection.dart';
import '../../../../domain/entities/appointment.dart' as domain;
import '../../../../domain/entities/pet.dart';
import '../../../../domain/usecases/appointment/get_appointment_by_id_usecase.dart';
import '../../../../domain/usecases/pet/get_pet_by_id_usecase.dart';
import '../../../widgets/common/veterinarian_avatar.dart';
import '../../../widgets/common/pet_avatar.dart';
import '../../../../data/datasources/pet/pet_remote_datasource.dart';
import 'package:intl/intl.dart';


enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
  pending,
}

class AppointmentDetailPage extends StatefulWidget {
  final String? appointmentId;

  const AppointmentDetailPage({super.key, this.appointmentId});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  domain.Appointment? appointment;
  AppointmentStatus? status;
  bool isLoading = true;
  String? errorMessage;
  
  PetDetailDTO? petDetails;
  bool isLoadingPet = false;
  String? petErrorMessage;

  late GetAppointmentByIdUseCase getAppointmentByIdUseCase;
  late GetPetByIdUseCase getPetByIdUseCase;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    getAppointmentByIdUseCase = sl<GetAppointmentByIdUseCase>();
    getPetByIdUseCase = sl<GetPetByIdUseCase>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      _loadAppointmentData();
      _isInitialLoad = false;
    }
  }

  Future<void> _loadAppointmentData() async {
    if (!mounted) return;

    String? appointmentId = widget.appointmentId;

    if (appointmentId == null) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map<String, dynamic>) {
        appointmentId = arguments['appointmentId'] as String?;
      } else if (arguments is String) {
        appointmentId = arguments;
      }
    }

    if (appointmentId == null || appointmentId.isEmpty) {
      if (mounted) {
        setState(() {
          errorMessage = 'ID de cita no proporcionado';
          isLoading = false;
        });
      }
      return;
    }

    await _fetchAppointment(appointmentId);
  }

  Future<void> _fetchAppointment(String appointmentId) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedAppointment = await getAppointmentByIdUseCase.call(
        appointmentId,
      );

      if (!mounted) return;

      setState(() {
        appointment = fetchedAppointment;
        status = _mapBackendStatusToFrontend(fetchedAppointment.status);
        isLoading = false;
        errorMessage = null;
      });

      // Cargar información de la mascota en paralelo
      _fetchPetDetails(fetchedAppointment.petId);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Error al obtener los datos de la cita: $e';
        isLoading = false;
        appointment = null;
        status = null;
      });
    }
  }

  Future<void> _fetchPetDetails(String petId) async {
    if (!mounted) return;

    setState(() {
      isLoadingPet = true;
      petErrorMessage = null;
    });

    try {
      final petDetail = await getPetByIdUseCase.call(petId);

      if (!mounted) return;

      setState(() {
        petDetails = petDetail;
        isLoadingPet = false;
        petErrorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        petErrorMessage = 'Error al obtener información de la mascota: $e';
        isLoadingPet = false;
        petDetails = null;
      });

      print('❌ Error al cargar información de la mascota: $e');
    }
  }

  AppointmentStatus _mapBackendStatusToFrontend(
    domain.AppointmentStatus backendStatus,
  ) {
    switch (backendStatus) {
      case domain.AppointmentStatus.pending:
        return AppointmentStatus.pending;
      case domain.AppointmentStatus.confirmed:
        return AppointmentStatus.confirmed;
      case domain.AppointmentStatus.inProgress:
        return AppointmentStatus.inProgress;
      case domain.AppointmentStatus.completed:
        return AppointmentStatus.completed;
      case domain.AppointmentStatus.cancelled:
        return AppointmentStatus.cancelled;
      case domain.AppointmentStatus.rescheduled:
        return AppointmentStatus.rescheduled;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFBDE3FF), Color(0xFFE8F5E8), Color(0xFFE5F3FF)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSizes.spaceL),
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spaceL),
                  ElevatedButton(
                    onPressed: _loadAppointmentData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (appointment == null || status == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontraron datos de la cita')),
      );
    }

    final statusColor = _getStatusColor(status!);

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
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(statusColor),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppointmentInfo(),
                        const SizedBox(height: AppSizes.spaceL),
                        _buildPetInfo(),
                        const SizedBox(height: AppSizes.spaceL),
                        _buildVeterinarianInfo(),
                        const SizedBox(height: 100),
                        const SizedBox(height: 100),
                      ],
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

  Widget _buildSliverAppBar(Color statusColor) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: statusColor,
      leading: Container(
        margin: const EdgeInsets.all(AppSizes.paddingS),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [statusColor, statusColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(status!),
                  size: 40,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),
              const Text(
                'Consulta Veterinaria',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
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
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusText(status!),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentInfo() {
    return _buildModernInfoCard(
      title: 'Información de la Cita',
      icon: Icons.calendar_today_outlined,
      iconColor: AppColors.primary,
      children: [
        _buildModernInfoRow(
          'Fecha',
          appointment?.appointmentDate != null
              ? _formatDate(appointment!.appointmentDate)
              : 'No especificada',
          Icons.today_outlined,
        ),
        _buildModernInfoRow(
          'Hora',
          appointment?.appointmentDate != null
              ? _formatTime(appointment!.appointmentDate)
              : 'No especificada',
          Icons.access_time_outlined,
        ),
        _buildModernInfoRow('Duración', '30 min', Icons.timer_outlined),
        if (appointment?.notes != null && appointment!.notes!.isNotEmpty)
          _buildModernInfoRow(
            'Notas',
            appointment!.notes!,
            Icons.note_outlined,
          ),
      ],
    );
  }

  Widget _buildPetInfo() {
    final pet = appointment?.pet ?? petDetails?.pet;
    
    return _buildModernInfoCard(
      title: 'Información de la Mascota',
      icon: Icons.pets_outlined,
      iconColor: AppColors.secondary,
      children: [
        if (isLoadingPet) ...[
          const Padding(
            padding: EdgeInsets.all(AppSizes.paddingM),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          ),
        ] else if (petErrorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.error.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: AppSizes.spaceM),
                Expanded(
                  child: Text(
                    petErrorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (pet != null) ...[
          // Información de la mascota con foto
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                PetAvatar(
                  pet: pet,
                  radius: 24,
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  iconColor: AppColors.secondary,
                ),
                const SizedBox(width: AppSizes.spaceM),
                Expanded(
                  child: PetInfo(
                    pet: pet,
                    showAge: true,
                    showGender: true,
                    nameStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    breedStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceM),
          if (pet.description != null && pet.description!.isNotEmpty)
            _buildModernInfoRow(
              'Descripción',
              pet.description!,
              Icons.description_outlined,
            ),
          if (pet.status != null)
            _buildModernInfoRow(
              'Estado de salud',
              _getPetStatusString(pet.status!),
              Icons.health_and_safety_outlined,
            ),
        ] else ...[
          _buildModernInfoRow(
            'ID de Mascota',
            appointment?.petId ?? 'No especificado',
            Icons.pets_rounded,
          ),
          _buildModernInfoRow(
            'Información',
            'Datos de la mascota no disponibles',
            Icons.info_outline,
          ),
        ],
      ],
    );
  }

  String _getPetStatusString(PetStatus status) {
    switch (status) {
      case PetStatus.HEALTHY:
        return '✅ Saludable';
      case PetStatus.TREATMENT:
        return '🩺 En tratamiento';
      case PetStatus.ATTENTION:
        return '⚠️ Necesita atención';
    }
  }

  Widget _buildVeterinarianInfo() {
    final veterinarian = appointment?.veterinarian;
    
    return _buildModernInfoCard(
      title: 'Veterinario',
      icon: Icons.person_outline,
      iconColor: AppColors.accent,
      children: [
        if (veterinarian != null) ...[
          // Información del veterinario con foto (clickeable)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToVeterinarianProfile(veterinarian.id),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    VeterinarianAvatar(
                      veterinarian: veterinarian,
                      radius: 24,
                      backgroundColor: AppColors.accent.withOpacity(0.1),
                      iconColor: AppColors.accent,
                    ),
                    const SizedBox(width: AppSizes.spaceM),
                    Expanded(
                      child: VeterinarianInfo(
                        veterinarian: veterinarian,
                        showLocation: true,
                        nameStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        specialtyStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.accent,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceM),
          _buildModernInfoRow(
            'Cédula',
            veterinarian.license.isNotEmpty ? veterinarian.license : 'No especificada',
            Icons.badge_outlined,
          ),
          _buildModernInfoRow(
            'Experiencia',
            veterinarian.experienceText,
            Icons.timeline_outlined,
          ),
          if (veterinarian.consultationFee != null)
            _buildModernInfoRow(
              'Tarifa de consulta',
              '\$${veterinarian.consultationFee!.toInt()}',
              Icons.attach_money_outlined,
            ),
          if (veterinarian.user.phone.isNotEmpty)
            _buildModernInfoRow(
              'Teléfono',
              veterinarian.user.phone,
              Icons.phone_outlined,
            ),
        ] else ...[
          _buildModernInfoRow(
            'ID del Veterinario',
            appointment?.vetId ?? 'No asignado',
            Icons.person_rounded,
          ),
          _buildModernInfoRow(
            'Información',
            'Datos del veterinario no disponibles',
            Icons.info_outline,
          ),
        ],
      ],
    );
  }

  Widget _buildModernInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
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
            color: iconColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
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
                    colors: [iconColor, iconColor.withOpacity(0.6)],
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
                            colors: [iconColor, iconColor.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Icon(icon, size: 20, color: AppColors.white),
                      ),
                      const SizedBox(width: AppSizes.spaceM),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isClickable = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap:
                      isClickable
                          ? () => _handleClickableValue(label, value)
                          : null,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          isClickable
                              ? AppColors.primary
                              : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: isClickable ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isClickable)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return AppColors.primary;
      case AppointmentStatus.confirmed:
        return AppColors.success;
      case AppointmentStatus.inProgress:
        return AppColors.warning;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
      case AppointmentStatus.rescheduled:
        return AppColors.secondary;
      case AppointmentStatus.pending:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule_outlined;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.inProgress:
        return Icons.medical_services_outlined;
      case AppointmentStatus.completed:
        return Icons.task_alt_outlined;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.rescheduled:
        return Icons.update_outlined;
      case AppointmentStatus.pending:
        return Icons.pending_actions_outlined;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Programada';
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.inProgress:
        return 'En curso';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.rescheduled:
        return 'Reprogramada';
      case AppointmentStatus.pending:
        return 'Pendiente';
    }
  }

  void _handleClickableValue(String label, String value) {
    if (label == 'Teléfono') {
      _callVeterinarian(value);
    } else if (label == 'Email') {
      _emailVeterinarian(value);
    } else if (label == 'Dirección') {
      _openMap(value);
    }
  }

  void _callVeterinarian(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Llamando a $phone...'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  void _emailVeterinarian(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo email para $email...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  void _openMap(String address) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo mapa para: $address'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  void _navigateToVeterinarianProfile(String vetId) {
    Navigator.pushNamed(
      context,
      '/veterinarian-profile',
      arguments: {'vetId': vetId},
    );
  }
}
