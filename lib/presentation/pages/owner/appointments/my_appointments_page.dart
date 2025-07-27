import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/appointment/appointment_bloc.dart';
import '../../../blocs/appointment/appointment_event.dart';
import '../../../blocs/appointment/appointment_state.dart';
import '../../../../core/services/user_service.dart';
import '../../../../domain/entities/appointment.dart' as domain;
import '../../../widgets/common/veterinarian_avatar.dart';
import 'package:intl/intl.dart';
import '../../../../core/injection/injection.dart';
import '../../../../data/datasources/appointment/appointment_remote_datasource.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AppointmentRemoteDataSource _appointmentDataSource;

  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _appointmentDataSource = sl<AppointmentRemoteDataSource>();
    _loadUserIdAndAppointments();
  }

  Future<void> _loadUserIdAndAppointments() async {
    final user = await UserService.getCurrentUser();
    setState(() {
      _userId = user['id'];
    });
    if (_userId != null) {
      // Simplificar: solo cargar todas las citas y filtrar en el frontend
      print('🟢 Lanzando petición de todas las citas para usuario: $_userId');
      context.read<AppointmentBloc>().add(
        LoadAllAppointmentsEvent(userId: _userId!),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildAppBar(),
                    _buildTabBar(),
                    Expanded(child: _buildTabBarView()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
          // Mostrar botón de volver solo si se puede hacer pop (navegación desde dashboard)
          if (Navigator.canPop(context))
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
          SizedBox(
            width: Navigator.canPop(context) ? AppSizes.spaceM : AppSizes.spaceM,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Citas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Gestiona tus consultas veterinarias',
                  style: TextStyle(fontSize: 14, color: AppColors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(6),
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Próximas'),
          Tab(text: 'Pasadas'),
          Tab(text: 'Todas'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUpcomingAppointmentsTab(),
        _buildPastAppointmentsTab(),
        _buildAllAppointmentsTab(),
      ],
    );
  }

  Widget _buildUpcomingAppointmentsTab() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        print('🔵 Estado en pestaña próximas: $state');
        if (state is AppointmentsOverviewState) {
          if (state.loadingAll) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorAll != null) {
            return _buildEmptyState('Error', state.errorAll!);
          }

          // Filtrar solo las citas que son realmente próximas (desde hoy en adelante)
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final upcomingAppointments =
              state.all.where((appointment) {
                final appointmentDate = DateTime(
                  appointment.appointmentDate.year,
                  appointment.appointmentDate.month,
                  appointment.appointmentDate.day,
                );
                final isUpcoming =
                    appointmentDate.isAtSameMomentAs(today) ||
                    appointmentDate.isAfter(today);
                print(
                  '🔵 Cita ${appointment.appointmentDate}: ${appointmentDate.toString()} >= ${today.toString()} = $isUpcoming',
                );
                return isUpcoming;
              }).toList();

          if (upcomingAppointments.isEmpty) {
            return _buildEmptyState(
              'Sin citas próximas',
              'No tienes citas programadas desde hoy en adelante.',
            );
          }
          print(
            '🔵 Mostrando ${upcomingAppointments.length} citas próximas filtradas',
          );
          return _buildAppointmentsList(upcomingAppointments);
        }
        return _buildEmptyState(
          'Sin datos',
          'No se pudo cargar la información.',
        );
      },
    );
  }

  Widget _buildPastAppointmentsTab() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        print('🟠 Estado en pestaña pasadas: $state');
        if (state is AppointmentsOverviewState) {
          if (state.loadingAll) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorAll != null) {
            return _buildEmptyState('Error', state.errorAll!);
          }

          // Filtrar solo las citas que son realmente pasadas (antes de hoy)
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final pastAppointments =
              state.all.where((appointment) {
                final appointmentDate = DateTime(
                  appointment.appointmentDate.year,
                  appointment.appointmentDate.month,
                  appointment.appointmentDate.day,
                );
                final isPast = appointmentDate.isBefore(today);
                print(
                  '🟠 Cita ${appointment.appointmentDate}: ${appointmentDate.toString()} < ${today.toString()} = $isPast',
                );
                return isPast;
              }).toList();

          if (pastAppointments.isEmpty) {
            return _buildEmptyState(
              'Sin citas pasadas',
              'No hay citas anteriores a hoy.',
            );
          }
          print(
            '🟠 Mostrando ${pastAppointments.length} citas pasadas filtradas',
          );
          return _buildAppointmentsList(pastAppointments);
        }
        return _buildEmptyState(
          'Sin datos',
          'No se pudo cargar la información.',
        );
      },
    );
  }

  Widget _buildAllAppointmentsTab() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        print('🟢 Estado en pestaña todas: $state');
        if (state is AppointmentsOverviewState) {
          if (state.loadingAll) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorAll != null) {
            return _buildEmptyState('Error', state.errorAll!);
          }
          if (state.all.isEmpty) {
            return _buildEmptyState(
              'Sin citas',
              'No tienes ninguna cita registrada.',
            );
          }
          print('🟢 Mostrando ${state.all.length} citas en total');
          return _buildAppointmentsList(state.all);
        }
        return _buildEmptyState(
          'Sin datos',
          'No se pudo cargar la información.',
        );
      },
    );
  }

  Widget _buildAppointmentsList(List<domain.Appointment> appointments) {
    print('📋 Construyendo lista con ${appointments.length} citas');

    if (appointments.isEmpty) {
      return _buildEmptyState(
        'No hay citas',
        'No se encontraron citas para este filtro.',
      );
    }

    // Ordenar las citas por fecha (más recientes primero para "todas", más próximas primero para "próximas")
    final sortedAppointments = List<domain.Appointment>.from(appointments);
    sortedAppointments.sort(
      (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
    );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.spaceL,
        AppSizes.paddingL,
        100,
      ),
      itemCount: sortedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = sortedAppointments[index];
        print(
          '📅 Cita ${index + 1}: ${appointment.appointmentDate} - ${appointment.status}',
        );
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = (_animationController.value - delay).clamp(
              0.0,
              1.0,
            );
            return Opacity(
              opacity: animationValue,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - animationValue)),
                child: _buildModernAppointmentCard(appointment),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernAppointmentCard(domain.Appointment appointment) {
    final formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(appointment.appointmentDate);
    final formattedTime = DateFormat(
      'HH:mm',
    ).format(appointment.appointmentDate);
    final statusColor = _getStatusColor(appointment.status);
    final statusText = _mapAppointmentStatusToString(appointment.status);

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
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
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
                    colors: [statusColor, statusColor.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _navigateToAppointmentDetail(appointment),
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                child: Padding(
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
                                  statusColor,
                                  statusColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                            ),
                            child: Icon(
                              _getStatusIcon(appointment.status),
                              color: AppColors.white,
                              size: AppSizes.iconS,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '$formattedDate • $formattedTime',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) => _handleAppointmentAction(value, appointment),
                            enabled: _canPerformActions(appointment.status),
                            itemBuilder: (context) => _buildPopupMenuItems(appointment.status),
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.paddingS),
                              decoration: BoxDecoration(
                                color: _canPerformActions(appointment.status) 
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.textSecondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                              ),
                              child: Icon(
                                Icons.more_vert,
                                color: _canPerformActions(appointment.status) 
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: AppSizes.iconS,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (appointment.notes != null &&
                          appointment.notes!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.spaceM),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusM,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.note_outlined,
                                    color: AppColors.primary,
                                    size: AppSizes.iconS,
                                  ),
                                  const SizedBox(width: AppSizes.spaceS),
                                  const Text(
                                    'Notas',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.spaceS),
                              Text(
                                appointment.notes!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSizes.spaceM),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            VeterinarianAvatar(
                              veterinarian: appointment.veterinarian,
                              radius: 20,
                            ),
                            const SizedBox(width: AppSizes.spaceM),
                            Expanded(
                              child: VeterinarianInfo(
                                veterinarian: appointment.veterinarian,
                                showLocation: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 50,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(domain.AppointmentStatus status) {
    switch (status) {
      case domain.AppointmentStatus.pending:
        return AppColors.warning;
      case domain.AppointmentStatus.confirmed:
        return AppColors.success;
      case domain.AppointmentStatus.inProgress:
        return AppColors.accent;
      case domain.AppointmentStatus.completed:
        return AppColors.primary;
      case domain.AppointmentStatus.cancelled:
        return AppColors.error;
      case domain.AppointmentStatus.rescheduled:
        return AppColors.secondary;
    }
  }

  IconData _getStatusIcon(domain.AppointmentStatus status) {
    switch (status) {
      case domain.AppointmentStatus.pending:
        return Icons.schedule;
      case domain.AppointmentStatus.confirmed:
        return Icons.check_circle;
      case domain.AppointmentStatus.inProgress:
        return Icons.play_circle;
      case domain.AppointmentStatus.completed:
        return Icons.task_alt;
      case domain.AppointmentStatus.cancelled:
        return Icons.cancel;
      case domain.AppointmentStatus.rescheduled:
        return Icons.update;
    }
  }

  String _mapAppointmentStatusToString(domain.AppointmentStatus status) {
    switch (status) {
      case domain.AppointmentStatus.pending:
        return 'Pendiente';
      case domain.AppointmentStatus.confirmed:
        return 'Confirmada';
      case domain.AppointmentStatus.inProgress:
        return 'En progreso';
      case domain.AppointmentStatus.completed:
        return 'Completada';
      case domain.AppointmentStatus.cancelled:
        return 'Cancelada';
      case domain.AppointmentStatus.rescheduled:
        return 'Reprogramada';
    }
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

  void _navigateToAppointmentDetail(domain.Appointment appointment) {
    Navigator.pushNamed(
      context, 
      '/appointment-detail', 
      arguments: {
        'appointmentId': appointment.id
      },
    );
  }

  // Métodos para manejo de citas

  bool _canPerformActions(domain.AppointmentStatus status) {
    // Los usuarios solo pueden reprogramar citas confirmadas
    return status == domain.AppointmentStatus.confirmed;
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(domain.AppointmentStatus status) {
    if (!_canPerformActions(status)) {
      return [];
    }

    // Solo permitir reprogramar para citas confirmadas
    return [
      const PopupMenuItem<String>(
        value: 'reschedule',
        child: Row(
          children: [
            Icon(Icons.schedule, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Reprogramar'),
          ],
        ),
      ),
    ];
  }

  void _handleAppointmentAction(String action, domain.Appointment appointment) {
    switch (action) {
      case 'reschedule':
        _showRescheduleModal(appointment);
        break;
    }
  }

  void _showRescheduleModal(domain.Appointment appointment) {
    DateTime selectedNewDate = appointment.appointmentDate;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: const Icon(
                Icons.schedule,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            const Text('Reprogramar Cita'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nueva fecha y hora:'),
            const SizedBox(height: AppSizes.spaceM),
            StatefulBuilder(
              builder: (context, setStateDialog) => Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                    title: Text(
                      '${selectedNewDate.day}/${selectedNewDate.month}/${selectedNewDate.year}',
                    ),
                    subtitle: Text(
                      '${selectedNewDate.hour.toString().padLeft(2, '0')}:${selectedNewDate.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedNewDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedNewDate),
                        );
                        if (time != null) {
                          setStateDialog(() {
                            selectedNewDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            const Text('Notas adicionales (opcional):'),
            const SizedBox(height: AppSizes.spaceS),
            TextField(
              controller: notesController,
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                hintText: 'Agregar notas...',
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
              _handleRescheduleAppointment(
                appointment, 
                selectedNewDate, 
                notesController.text.trim().isEmpty ? null : notesController.text.trim()
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Reprogramar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRescheduleAppointment(
    domain.Appointment appointment, 
    DateTime newDate, 
    String? notes
  ) async {
    try {
      await _appointmentDataSource.rescheduleAppointment(
        appointment.id, 
        newDate, 
        notes
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita reprogramada exitosamente'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Recargar las citas
        if (_userId != null) {
          context.read<AppointmentBloc>().add(
            LoadAllAppointmentsEvent(userId: _userId!),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reprogramar la cita: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
