import 'package:flutter/material.dart';
import '../../../widgets/cards/appointment_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../core/injection/injection.dart';
import '../../../../domain/usecases/appointment/get_upcoming_appointments_usecase.dart';
import '../../../../domain/entities/appointment.dart' as domain;
import '../../../widgets/cards/appointment_card.dart' show AppointmentStatus;
import '../../../../data/datasources/appointment/appointment_remote_datasource.dart';



class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  DateTime selectedDate = DateTime.now();
  String _viewMode = 'day';
  
  List<domain.Appointment> _allAppointments = [];
  List<domain.Appointment> _pendingAppointments = [];
  bool _isLoading = false;
  String? _error;
  late AppointmentRemoteDataSource _appointmentDataSource;

  @override
  void initState() {
    super.initState();
    _appointmentDataSource = sl<AppointmentRemoteDataSource>();
    _loadVetAppointments();
  }

  Future<void> _loadVetAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
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

      // Separar citas pendientes (incluir pending y rescheduled) de las demás
      final pendingAppointments = appointments.where((appointment) => 
        appointment.status == domain.AppointmentStatus.pending ||
        appointment.status == domain.AppointmentStatus.rescheduled
      ).toList();
      
      final nonPendingAppointments = appointments.where((appointment) => 
        appointment.status != domain.AppointmentStatus.pending &&
        appointment.status != domain.AppointmentStatus.rescheduled
      ).toList();

      // Ordenar las citas por fecha
      pendingAppointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
      nonPendingAppointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

      setState(() {
        _pendingAppointments = pendingAppointments;
        _allAppointments = nonPendingAppointments; // Solo citas no pendientes para las vistas principales
        _isLoading = false;
      });

      print('✅ Citas cargadas exitosamente:');
      print('   - Pendientes: ${pendingAppointments.length}');
      print('   - Confirmadas/Otras: ${nonPendingAppointments.length}');
    } catch (e) {
      print('❌ Error cargando citas: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Funciones auxiliares para mapear datos de Appointment a AppointmentCard
  String _getPetName(domain.Appointment appointment) {
    return appointment.pet?.name ?? 'Mascota sin nombre';
  }

  String _getOwnerName(domain.Appointment appointment) {
    // Intentar obtener el nombre del dueño desde la relación user
    if (appointment.user != null) {
      final firstName = appointment.user!.firstName;
      final lastName = appointment.user!.lastName;
      
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '$firstName $lastName';
      } else if (firstName.isNotEmpty) {
        return firstName;
      } else if (lastName.isNotEmpty) {
        return lastName;
      }
    }
    
    // Si no hay user en la relación, usar el nombre genérico
    return 'Propietario';
  }

  String _getAppointmentType(domain.Appointment appointment) {
    return appointment.notes ?? 'Consulta General';
  }

  AppointmentStatus _mapAppointmentStatus(domain.Appointment appointment) {
    switch (appointment.status) {
      case domain.AppointmentStatus.pending:
        return AppointmentStatus.scheduled;
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

  @override
  void dispose() {
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildModernAppBar(),
                  const SizedBox(height: AppSizes.spaceL),
                  _buildViewToggle(),
                  const SizedBox(height: AppSizes.spaceL),
                  _buildCurrentViewContent(),
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
          const Expanded(
            child: Text(
              'Mi Agenda',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_pendingAppointments.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: AppColors.white),
                    onPressed: () => _showPendingAppointmentsModal(),
                  ),
                  if (_pendingAppointments.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${_pendingAppointments.length}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentViewContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: _buildCurrentView(),
    );
  }



  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildToggleButton('Día', 'day'),
          _buildToggleButton('Semana', 'week'),
          _buildToggleButton('Mes', 'month'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String title, String mode) {
    final isSelected = _viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    // Mostrar error si existe
    if (_error != null) {
      return _buildErrorState(_error!);
    }
    
    // Mostrar loading si está cargando
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    switch (_viewMode) {
      case 'week':
        return _buildWeekView();
      case 'month':
        return _buildMonthView();
      default:
        return _buildDayView();
    }
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.spaceM),
          const Text(
            'Error al cargar las citas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceL),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _error = null;
              });
              _loadVetAppointments();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: AppSizes.spaceL),
          const Text(
            'Cargando citas...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView() {
    final dayAppointments = _getAppointmentsForDate(selectedDate);

    return Column(
      children: [
        _buildDateHeader(),
        const SizedBox(height: AppSizes.spaceM),
        ...dayAppointments.map(
          (appointment) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
            child: _buildCustomAppointmentCard(appointment),
          ),
        ),
        const SizedBox(height: 100), // Espacio adicional al final
      ],
    );
  }

  Widget _buildCustomAppointmentCard(domain.Appointment appointment) {
    final isRescheduled = appointment.status == domain.AppointmentStatus.rescheduled;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: _getStatusColor(_mapAppointmentStatus(appointment)).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToAppointmentDetail(appointment),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de reprogramación si es necesario
              if (isRescheduled) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  margin: const EdgeInsets.only(bottom: AppSizes.spaceS),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSizes.spaceS),
                      Expanded(
                        child: Text(
                          'Cita reprogramada - Pendiente de confirmación del propietario',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_mapAppointmentStatus(appointment)).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(
                      _getStatusIcon(_mapAppointmentStatus(appointment)),
                      color: _getStatusColor(_mapAppointmentStatus(appointment)),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getPetName(appointment),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _getOwnerName(appointment),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(_mapAppointmentStatus(appointment)),
                  const SizedBox(width: AppSizes.spaceS),
                  // Solo mostrar menú de acciones si no está cancelada o completada
                  if (appointment.status != domain.AppointmentStatus.cancelled &&
                      appointment.status != domain.AppointmentStatus.completed)
                    InkWell(
                      onTap: () => _showAppointmentActionsMenu(appointment),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingS),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceM),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSizes.spaceS),
                  Text(
                    '${appointment.appointmentDate.hour.toString().padLeft(2, '0')}:${appointment.appointmentDate.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceL),
                  Icon(
                    Icons.medical_services,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSizes.spaceS),
                  Expanded(
                    child: Text(
                      _getAppointmentType(appointment),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceS),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSizes.spaceS),
                      Expanded(
                        child: Text(
                          appointment.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
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
        return AppColors.secondary;
      case AppointmentStatus.cancelled:
        return AppColors.error;
      case AppointmentStatus.rescheduled:
        return AppColors.accent;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.inProgress:
        return Icons.medical_services;
      case AppointmentStatus.completed:
        return Icons.check_circle;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.rescheduled:
        return Icons.update;
    }
  }

  Widget _buildWeekView() {
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );

    return Column(
      children: [
        ...weekDays.map((day) {
          final dayAppointments = _getAppointmentsForDate(day);
          return _buildWeekDaySection(day, dayAppointments);
        }),
        const SizedBox(height: 100), // Espacio adicional al final
      ],
    );
  }

  Widget _buildWeekDaySection(
    DateTime day,
    List<domain.Appointment> appointments,
  ) {
    final isToday = _isSameDay(day, DateTime.now());
    final dayName = _getDayName(day.weekday);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color:
                isToday
                    ? AppColors.secondary.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color:
              isToday
                  ? AppColors.secondary.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              gradient:
                  isToday
                      ? AppColors.orangeGradient
                      : AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusXL),
                topRight: Radius.circular(AppSizes.radiusXL),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$dayName ${day.day}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Text(
                    '${appointments.length} citas',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (appointments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconL,
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    const Text(
                      'No hay citas programadas',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...appointments.map(
              (appointment) => _buildWeekAppointmentItem(appointment),
            ),
        ],
      ),
    );
  }

  Widget _buildWeekAppointmentItem(domain.Appointment appointment) {
    final time =
        '${appointment.appointmentDate.hour.toString().padLeft(2, '0')}:${appointment.appointmentDate.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () => _navigateToAppointmentDetail(appointment),
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.textSecondary, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Text(
                time,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getPetName(appointment)} - ${_getOwnerName(appointment)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _getAppointmentType(appointment),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(_mapAppointmentStatus(appointment)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthView() {
    final monthStart = DateTime(selectedDate.year, selectedDate.month, 1);
    final monthEnd = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final weeks = <List<DateTime>>[];

    var currentWeekStart = monthStart.subtract(
      Duration(days: monthStart.weekday - 1),
    );

    while (currentWeekStart.isBefore(monthEnd) ||
        currentWeekStart.month == monthEnd.month) {
      final week = List.generate(
        7,
        (index) => currentWeekStart.add(Duration(days: index)),
      );
      weeks.add(week);
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));

      if (week.last.isAfter(monthEnd) && week.first.month != monthEnd.month)
        break;
    }

    return Column(
      children: [
        _buildMonthHeader(),
        const SizedBox(height: AppSizes.spaceM),
        _buildMonthCalendar(weeks),
        const SizedBox(height: AppSizes.spaceL),
        _buildMonthAppointmentsList(),
        const SizedBox(height: 100), // Espacio adicional al final
      ],
    );
  }

  Widget _buildMonthHeader() {
    final monthName = _getMonthName(selectedDate.month);
    final today = DateTime.now();
    final canGoBack =
        selectedDate.year > today.year ||
        (selectedDate.year == today.year && selectedDate.month > today.month);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color:
                  canGoBack
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              onPressed: canGoBack ? () => _changeMonth(-1) : null,
              icon: Icon(
                Icons.chevron_left,
                color: canGoBack ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '$monthName ${selectedDate.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              onPressed: () => _changeMonth(1),
              icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(List<List<DateTime>> weeks) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildWeekDayHeaders(),
          ...weeks.map((week) => _buildCalendarWeek(week)),
        ],
      ),
    );
  }

  Widget _buildWeekDayHeaders() {
    final dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusL),
          topRight: Radius.circular(AppSizes.radiusL),
        ),
      ),
      child: Row(
        children:
            dayNames
                .map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCalendarWeek(List<DateTime> week) {
    return Row(children: week.map((day) => _buildCalendarDay(day)).toList());
  }

  Widget _buildCalendarDay(DateTime day) {
    final isCurrentMonth = day.month == selectedDate.month;
    final isToday = _isSameDay(day, DateTime.now());
    final isSelected = _isSameDay(day, selectedDate);
    final appointmentsCount = _getAppointmentsForDate(day).length;
    final today = DateTime.now();
    final isPastDate = day.isBefore(
      DateTime(today.year, today.month, today.day),
    );

    return Expanded(
      child: GestureDetector(
        onTap: isPastDate ? null : () => setState(() => selectedDate = day),
        child: Container(
          height: 50,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? AppColors.primaryGradient
                    : isToday
                    ? AppColors.orangeGradient
                    : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color:
                        isSelected || isToday
                            ? AppColors.white
                            : isPastDate
                            ? AppColors.textSecondary.withOpacity(0.5)
                            : isCurrentMonth
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              if (appointmentsCount > 0 && !isPastDate)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          isSelected || isToday
                              ? AppColors.white
                              : AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthAppointmentsList() {
    final selectedDateAppointments = _getAppointmentsForDate(selectedDate);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusL),
                topRight: Radius.circular(AppSizes.radiusL),
              ),
            ),
            child: Text(
              'Citas del ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          if (selectedDateAppointments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconL,
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    const Text(
                      'No hay citas programadas para este día',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...selectedDateAppointments.map(
              (appointment) => _buildMonthAppointmentItem(appointment),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthAppointmentItem(domain.Appointment appointment) {
    final time =
        '${appointment.appointmentDate.hour.toString().padLeft(2, '0')}:${appointment.appointmentDate.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () => _navigateToAppointmentDetail(appointment),
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.textSecondary, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Text(
                time,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
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
                    '${_getPetName(appointment)} - ${_getOwnerName(appointment)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _getAppointmentType(appointment),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(_mapAppointmentStatus(appointment)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final today = DateTime.now();
    final isToday = _isSameDay(selectedDate, today);
    final dayName = _getDayName(selectedDate.weekday);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceL),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color:
                isToday
                    ? AppColors.secondary.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color:
              isToday
                  ? AppColors.secondary.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              gradient:
                  isToday
                      ? AppColors.orangeGradient
                      : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              Icons.calendar_today,
              color: AppColors.white,
              size: AppSizes.iconM,
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Text(
            isToday
                ? 'Hoy'
                : '$dayName ${selectedDate.day}/${selectedDate.month}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isToday ? AppColors.secondary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    Color color;
    String text;

    switch (status) {
      case AppointmentStatus.scheduled:
        color = AppColors.primary;
        text = 'Programada';
        break;
      case AppointmentStatus.confirmed:
        color = AppColors.success;
        text = 'Confirmada';
        break;
      case AppointmentStatus.inProgress:
        color = AppColors.warning;
        text = 'En curso';
        break;
      case AppointmentStatus.completed:
        color = AppColors.secondary;
        text = 'Completada';
        break;
      case AppointmentStatus.cancelled:
        color = AppColors.error;
        text = 'Cancelada';
        break;
      case AppointmentStatus.rescheduled:
        color = AppColors.accent;
        text = 'Reprogramada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<domain.Appointment> _getAppointmentsForDate(DateTime date) {
    return _allAppointments.where((appointment) {
        final appointmentDate = appointment.appointmentDate;
        return _isSameDay(appointmentDate, date);
      }).toList()
      ..sort(
        (a, b) =>
            a.appointmentDate.compareTo(b.appointmentDate),
      );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayName(int weekday) {
    const dayNames = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return dayNames[weekday - 1];
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return monthNames[month - 1];
  }

  void _changeMonth(int direction) {
    final today = DateTime.now();
    final newDate = DateTime(
      selectedDate.year,
      selectedDate.month + direction,
      1,
    );

    // Solo permitir navegar a meses actuales o futuros
    if (newDate.year > today.year ||
        (newDate.year == today.year && newDate.month >= today.month)) {
      setState(() {
        selectedDate = newDate;
      });
    }
  }

  void _navigateToAppointmentDetail(domain.Appointment appointment) {
    Navigator.pushNamed(
      context,
      '/appointment-detail-vet',
      arguments: appointment.id,
    );
  }

  // Métodos para manejar estados de citas
  Future<void> _handleConfirmAppointment(domain.Appointment appointment) async {
    try {
      setState(() => _isLoading = true);
      
      await _appointmentDataSource.confirmAppointment(appointment.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cita confirmada para ${_getPetName(appointment)}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Recargar las citas
      await _loadVetAppointments();
    } catch (e) {
      print('❌ Error confirmando cita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al confirmar la cita: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCancelAppointment(domain.Appointment appointment, String? reason) async {
    try {
      setState(() => _isLoading = true);
      
      await _appointmentDataSource.cancelAppointment(appointment.id, reason);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cita cancelada para ${_getPetName(appointment)}'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Recargar las citas
      await _loadVetAppointments();
    } catch (e) {
      print('❌ Error cancelando cita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar la cita: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRescheduleAppointment(domain.Appointment appointment, DateTime newDate, String? notes) async {
    try {
      setState(() => _isLoading = true);
      
      await _appointmentDataSource.rescheduleAppointment(appointment.id, newDate, notes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cita reprogramada para ${_getPetName(appointment)}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Recargar las citas
      await _loadVetAppointments();
    } catch (e) {
      print('❌ Error reprogramando cita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reprogramar la cita: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCompleteAppointment(domain.Appointment appointment) async {
    try {
      setState(() => _isLoading = true);
      
      await _appointmentDataSource.completeAppointment(appointment.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cita completada para ${_getPetName(appointment)}'),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Recargar las citas
      await _loadVetAppointments();
    } catch (e) {
      print('❌ Error completando cita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al completar la cita: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Métodos para mostrar modales
  void _showAppointmentActionsMenu(domain.Appointment appointment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusXL),
            topRight: Radius.circular(AppSizes.radiusXL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acciones para ${_getPetName(appointment)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  ..._buildActionButtons(appointment),
                  const SizedBox(height: AppSizes.paddingM),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(domain.Appointment appointment) {
    List<Widget> buttons = [];
    
    // Confirmar cita (solo si está pendiente)
    if (appointment.status == domain.AppointmentStatus.pending) {
      buttons.add(_buildActionButton(
        icon: Icons.check_circle,
        text: 'Confirmar Cita',
        color: AppColors.success,
        onTap: () {
          Navigator.pop(context);
          _handleConfirmAppointment(appointment);
        },
      ));
    }
    
    // Completar cita (solo si está confirmada o en progreso)
    if (appointment.status == domain.AppointmentStatus.confirmed || 
        appointment.status == domain.AppointmentStatus.inProgress) {  
      buttons.add(_buildActionButton(
        icon: Icons.check_circle,
        text: 'Completar Cita',
        color: AppColors.secondary,
        onTap: () {
          Navigator.pop(context);
          _handleCompleteAppointment(appointment);
        },
      ));
    }
    
    // Reprogramar cita (si no está completada o cancelada)
    if (appointment.status != domain.AppointmentStatus.completed && 
        appointment.status != domain.AppointmentStatus.cancelled) {
      buttons.add(_buildActionButton(
        icon: Icons.schedule,
        text: 'Reprogramar',
        color: AppColors.primary,
        onTap: () {
          Navigator.pop(context);
          _showRescheduleModal(appointment);
        },
      ));
    }
    
    // Cancelar cita (si no está completada o cancelada)
    if (appointment.status != domain.AppointmentStatus.completed && 
        appointment.status != domain.AppointmentStatus.cancelled) {
      buttons.add(_buildActionButton(
        icon: Icons.cancel,
        text: 'Cancelar Cita',
        color: AppColors.error,
        onTap: () {
          Navigator.pop(context);
          _showCancelModal(appointment);
        },
      ));
    }
    
    return buttons;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: AppSizes.spaceM),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelModal(domain.Appointment appointment) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: const Text('Cancelar Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cita con ${_getPetName(appointment)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            const Text('Motivo de cancelación (opcional):'),
            const SizedBox(height: AppSizes.spaceS),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                hintText: 'Ingresa el motivo...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleCancelAppointment(appointment, reasonController.text.trim().isEmpty ? null : reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Confirmar Cancelación'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleModal(domain.Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRescheduleModal(appointment),
    );
  }

  Widget _buildRescheduleModal(domain.Appointment appointment) {
    DateTime? selectedDate;
    String? selectedTimeSlot;

    return StatefulBuilder(
      builder: (context, setModalState) {
        final canConfirm = selectedDate != null && selectedTimeSlot != null;

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusXL),
              topRight: Radius.circular(AppSizes.radiusXL),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppSizes.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reprogramar Cita',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_getPetName(appointment)} - ${_getOwnerName(appointment)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModalFormSection(
                        title: 'Fecha',
                        child: GestureDetector(
                          onTap: () => _selectDateForReschedule(setModalState, (date) {
                            selectedDate = date;
                            selectedTimeSlot = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.paddingM),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(AppSizes.radiusL),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.secondary,
                                  size: AppSizes.iconM,
                                ),
                                const SizedBox(width: AppSizes.spaceM),
                                Expanded(
                                  child: Text(
                                    selectedDate != null
                                        ? _formatDate(selectedDate!)
                                        : 'Selecciona una fecha',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: selectedDate != null
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.textSecondary,
                                  size: AppSizes.iconS,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spaceL),

                      if (selectedDate != null)
                        _buildTimeSlotSelectionForReschedule(
                          selectedDate!,
                          selectedTimeSlot,
                          (timeSlot) {
                            setModalState(() {
                              selectedTimeSlot = timeSlot;
                            });
                          },
                        ),

                      const SizedBox(height: AppSizes.spaceL),

                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSizes.spaceM),
                            const Expanded(
                              child: Text(
                                'Se notificará automáticamente al propietario sobre la nueva fecha y hora.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceM),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: canConfirm
                              ? LinearGradient(
                                  colors: [
                                    AppColors.secondary,
                                    AppColors.secondary.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: ElevatedButton(
                          onPressed: canConfirm
                              ? () {
                                  final newDateTime = _createDateTimeFromSlot(
                                    selectedDate!,
                                    selectedTimeSlot!,
                                  );
                                  Navigator.pop(context);
                                  _handleRescheduleAppointment(
                                    appointment,
                                    newDateTime,
                                    null,
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canConfirm
                                ? Colors.transparent
                                : AppColors.textSecondary.withOpacity(0.3),
                            shadowColor: Colors.transparent,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.paddingM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                          ),
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalFormSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        child,
      ],
    );
  }

  Widget _buildTimeSlotSelectionForReschedule(
    DateTime selectedDate,
    String? selectedTimeSlot,
    Function(String) onTimeSlotSelected,
  ) {
    final availableSlots = _getAvailableTimeSlotsForDate(selectedDate);

    if (availableSlots.isEmpty) {
      return _buildModalFormSection(
        title: 'Horarios disponibles',
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: AppSizes.spaceM),
              const Expanded(
                child: Text(
                  'No hay horarios disponibles para esta fecha.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildModalFormSection(
      title: 'Horarios disponibles',
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Wrap(
          spacing: AppSizes.spaceS,
          runSpacing: AppSizes.spaceS,
          children: availableSlots.map((slot) {
            final isSelected = selectedTimeSlot == slot;
            return GestureDetector(
              onTap: () => onTimeSlotSelected(slot),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        )
                      : null,
                  color: isSelected ? null : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _selectDateForReschedule(
    StateSetter setModalState,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setModalState(() {
        onDateSelected(picked);
      });
    }
  }

  List<String> _getAvailableTimeSlotsForDate(DateTime date) {
    final dayOfWeek = date.weekday;

    if (dayOfWeek == 7) {
      return [];
    }

    if (dayOfWeek == 6) {
      return [
        '9:00 AM',
        '10:00 AM',
        '11:00 AM',
        '12:00 PM',
        '1:00 PM',
        '2:00 PM',
      ];
    }

    return [
      '8:00 AM',
      '9:00 AM',
      '10:00 AM',
      '11:00 AM',
      '12:00 PM',
      '1:00 PM',
      '2:00 PM',
      '3:00 PM',
      '4:00 PM',
      '5:00 PM',
      '6:00 PM',
    ];
  }

  DateTime _createDateTimeFromSlot(DateTime date, String timeSlot) {
    final timeParts = timeSlot.split(':');
    final hour = int.parse(timeParts[0]);
    final minutePart = timeParts[1].split(' ');
    final minute = int.parse(minutePart[0]);
    final period = minutePart[1];

    int adjustedHour = hour;
    if (period == 'PM' && hour != 12) {
      adjustedHour = hour + 12;
    } else if (period == 'AM' && hour == 12) {
      adjustedHour = 0;
    }

    return DateTime(date.year, date.month, date.day, adjustedHour, minute);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }

  // Modal para mostrar citas pendientes
  void _showPendingAppointmentsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusXL),
            topRight: Radius.circular(AppSizes.radiusXL),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(
                      Icons.pending_actions,
                      color: AppColors.warning,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Citas Pendientes y Reprogramadas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${_pendingAppointments.length} citas (pendientes y reprogramadas) requieren tu atención',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Lista de citas pendientes
            Expanded(
              child: _pendingAppointments.isEmpty
                  ? _buildEmptyPendingState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      itemCount: _pendingAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _pendingAppointments[index];
                        return _buildPendingAppointmentCard(appointment);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPendingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSizes.spaceM),
          const Text(
            '¡Todo al día!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceS),
          const Text(
            'No tienes citas pendientes o reprogramadas por confirmar',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAppointmentCard(domain.Appointment appointment) {
    final isRescheduled = appointment.status == domain.AppointmentStatus.rescheduled;
    final cardColor = isRescheduled ? AppColors.accent : AppColors.warning;
    final statusText = isRescheduled ? 'Reprogramada' : 'Pendiente';
    final statusIcon = isRescheduled ? Icons.update : Icons.schedule;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: cardColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner superior para citas reprogramadas
            if (isRescheduled) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.accent,
                      size: 16,
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    const Expanded(
                      child: Text(
                        'Esta cita fue reprogramada y necesita confirmación',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    statusIcon,
                    color: cardColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPetName(appointment),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _getOwnerName(appointment),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceM),
            
            // Información de la cita
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.spaceS),
                Text(
                  '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year} ${appointment.appointmentDate.hour.toString().padLeft(2, '0')}:${appointment.appointmentDate.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSizes.spaceS),
            
            // Estado de la cita
            Row(
              children: [
                Icon(
                  statusIcon,
                  size: 16,
                  color: cardColor,
                ),
                const SizedBox(width: AppSizes.spaceS),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    color: cardColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spaceS),
              Text(
                appointment.notes!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            
            const SizedBox(height: AppSizes.spaceM),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () {
                      Navigator.pop(context);
                      _handleConfirmAppointment(appointment);
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Confirmar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () {
                      Navigator.pop(context);
                      _showCancelModal(appointment);
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
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
