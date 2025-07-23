import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/appointment/appointment_bloc.dart';
import '../../../blocs/appointment/appointment_event.dart';
import '../../../blocs/appointment/appointment_state.dart';
import '../../../../core/services/user_service.dart';
import '../../../../domain/entities/appointment.dart' as domain;
import 'package:intl/intl.dart';

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
      floatingActionButton: _buildFloatingActionButton(),
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
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.textSecondary,
                            size: AppSizes.iconS,
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
                            CircleAvatar(
                              backgroundColor: AppColors.secondary.withOpacity(
                                0.1,
                              ),
                              radius: 20,
                              child: Icon(
                                Icons.local_hospital,
                                color: AppColors.secondary,
                                size: AppSizes.iconS,
                              ),
                            ),
                            const SizedBox(width: AppSizes.spaceM),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dr. Veterinario',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Clínica Veterinaria',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
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

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _navigateToScheduleAppointment,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nueva Cita',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
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

  void _navigateToScheduleAppointment() {
    Navigator.pushNamed(context, '/schedule-appointment');
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
}
