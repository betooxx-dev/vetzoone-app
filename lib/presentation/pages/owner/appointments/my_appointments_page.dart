import 'package:flutter/material.dart';
import '../../../../core/widgets/confirmation_modal.dart';
// import '../../../widgets/cards/appointment_card.dart';
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
      final now = DateTime.now();
      final fifteenDaysLater = now.add(const Duration(days: 15));
      final oneMonthAgo = now.subtract(const Duration(days: 30));
      final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      final yesterdayEnd = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999);
      // Lanzar las tres peticiones en paralelo y trackear en consola
      Future.wait([
        Future(() {
          print('🔵 Lanzando petición de próximas citas...');
          context.read<AppointmentBloc>().add(LoadUpcomingAppointmentsEvent(userId: _userId!, dateFrom: now, dateTo: fifteenDaysLater));
        }),
        Future(() {
          print('🟠 Lanzando petición de citas pasadas...');
          context.read<AppointmentBloc>().add(LoadPastAppointmentsEvent(userId: _userId!, dateFrom: oneMonthAgo, dateTo: yesterdayEnd));
        }),
        Future(() {
          print('🟢 Lanzando petición de todas las citas...');
          context.read<AppointmentBloc>().add(LoadAllAppointmentsEvent(userId: _userId!));
        }),
      ]);
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Citas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                Text(
                  'Gestiona tus consultas veterinarias',
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
          // Botón de filtro eliminado
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(6),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF757575),
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
        if (state is AppointmentsOverviewState) {
          if (state.errorUpcoming != null) {
            return _buildEmptyState('Error', state.errorUpcoming!);
          } else {
            return _buildAppointmentsList(state.upcoming);
          }
        }
        return _buildEmptyState('Sin datos', 'No se pudo cargar la información.');
      },
    );
  }

  Widget _buildPastAppointmentsTab() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentsOverviewState) {
          if (state.errorPast != null) {
            return _buildEmptyState('Error', state.errorPast!);
          } else if (state.past.isEmpty) {
            return _buildEmptyState('Sin citas', 'No hay citas en el último mes.');
          } else {
            return _buildAppointmentsList(state.past);
          }
        }
        return _buildEmptyState('Sin datos', 'No se pudo cargar la información.');
      },
    );
  }

  Widget _buildAllAppointmentsTab() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentsOverviewState) {
          if (state.errorAll != null) {
            return _buildEmptyState('Error', state.errorAll!);
          } else {
            return _buildAppointmentsList(state.all);
          }
        }
        return _buildEmptyState('Sin datos', 'No se pudo cargar la información.');
      },
    );
  }

  Widget _buildAppointmentsList(List<domain.Appointment> appointments) {
    if (appointments.isEmpty) {
      return _buildEmptyState('No hay citas', 'No se encontraron citas para este filtro.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = (_animationController.value - delay).clamp(0.0, 1.0);
            return Opacity(
              opacity: animationValue,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - animationValue)),
                child: _buildAppointmentCard(appointment),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(domain.Appointment appointment) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(appointment.appointmentDate);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
        title: Text('Fecha: $formattedDate', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(appointment.notes ?? 'Sin notas'),
        trailing: Text(_mapAppointmentStatusToString(appointment.status)),
        onTap: () => _navigateToAppointmentDetail(appointment),
      ),
    );
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
    return '';
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 48, color: Color(0xFFBDBDBD)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF757575)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToScheduleAppointment,
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Nueva Cita',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _navigateToScheduleAppointment() {
    Navigator.pushNamed(context, '/schedule-appointment');
  }

  void _navigateToAppointmentDetail(domain.Appointment appointment) {
    Navigator.pushNamed(context, '/appointment-detail', arguments: appointment);
  }
}
