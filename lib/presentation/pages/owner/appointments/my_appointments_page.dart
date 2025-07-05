import 'package:flutter/material.dart';
import '../../../../core/widgets/confirmation_modal.dart';
import '../../../widgets/cards/appointment_card.dart';

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

  // Mock data de citas
  final List<Map<String, dynamic>> _allAppointments = [
    {
      'id': '1',
      'petName': 'Max',
      'veterinarianName': 'Dr. María González',
      'appointmentType': 'Consulta General',
      'dateTime': DateTime.now().add(const Duration(hours: 2)),
      'status': AppointmentStatus.confirmed,
      'clinic': 'Clínica VetCare Tuxtla',
      'cost': 350.0,
      'notes': 'Control de rutina',
    },
    {
      'id': '2',
      'petName': 'Luna',
      'veterinarianName': 'Dr. Carlos López',
      'appointmentType': 'Vacunación',
      'dateTime': DateTime.now().add(const Duration(days: 1)),
      'status': AppointmentStatus.scheduled,
      'clinic': 'Hospital Veterinario Central',
      'cost': 280.0,
      'notes': 'Vacuna anual',
    },
    {
      'id': '3',
      'petName': 'Max',
      'veterinarianName': 'Dr. María González',
      'appointmentType': 'Consulta General',
      'dateTime': DateTime.now().subtract(const Duration(days: 7)),
      'status': AppointmentStatus.completed,
      'clinic': 'Clínica VetCare Tuxtla',
      'cost': 350.0,
      'notes': 'Revisión post-cirugía',
    },
    {
      'id': '4',
      'petName': 'Rocky',
      'veterinarianName': 'Dra. Ana García',
      'appointmentType': 'Dermatología',
      'dateTime': DateTime.now().subtract(const Duration(days: 14)),
      'status': AppointmentStatus.completed,
      'clinic': 'Centro Veterinario Especializado',
      'cost': 400.0,
      'notes': 'Tratamiento de alergia',
    },
    {
      'id': '5',
      'petName': 'Luna',
      'veterinarianName': 'Dr. Roberto Mendoza',
      'appointmentType': 'Emergencia',
      'dateTime': DateTime.now().subtract(const Duration(days: 3)),
      'status': AppointmentStatus.cancelled,
      'clinic': 'Hospital 24 Horas',
      'cost': 600.0,
      'notes': 'Cancelada por mejora del paciente',
    },
  ];

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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {
                // Implementar filtros o búsqueda
              },
              icon: const Icon(
                Icons.filter_list_rounded,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
            ),
          ),
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
            // ignore: deprecated_member_use
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
        tabs: [
          Tab(text: 'Próximas (${_getUpcomingCount()})'),
          Tab(text: 'Pasadas (${_getPastCount()})'),
          Tab(text: 'Todas (${_allAppointments.length})'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAppointmentsList(_getUpcomingAppointments()),
        _buildAppointmentsList(_getPastAppointments()),
        _buildAppointmentsList(_allAppointments),
      ],
    );
  }

  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments) {
    if (appointments.isEmpty) {
      return _buildEmptyState();
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
            final animationValue = (_animationController.value - delay).clamp(
              0.0,
              1.0,
            );

            return Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: AppointmentCard(
                  petName: appointment['petName'],
                  veterinarianName: appointment['veterinarianName'],
                  appointmentType: appointment['appointmentType'],
                  dateTime: appointment['dateTime'],
                  status: appointment['status'],
                  clinic: appointment['clinic'],
                  notes: appointment['notes'],
                  cost: appointment['cost'],
                  onTap: () => _navigateToAppointmentDetail(appointment),
                  onCancel:
                      _canCancelAppointment(appointment['status'])
                          ? () => _cancelAppointment(appointment)
                          : null,
                  onReschedule:
                      _canRescheduleAppointment(appointment['status'])
                          ? () => _rescheduleAppointment(appointment)
                          : null,
                  isOwnerView: true,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 60,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getEmptyStateTitle(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getEmptyStateMessage(),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToScheduleAppointment,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agendar Primera Cita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
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

  List<Map<String, dynamic>> _getUpcomingAppointments() {
    final now = DateTime.now();
    return _allAppointments.where((appointment) {
        final appointmentDate = appointment['dateTime'] as DateTime;
        final status = appointment['status'] as AppointmentStatus;
        return appointmentDate.isAfter(now) &&
            status != AppointmentStatus.cancelled &&
            status != AppointmentStatus.completed;
      }).toList()
      ..sort(
        (a, b) =>
            (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime),
      );
  }

  List<Map<String, dynamic>> _getPastAppointments() {
    final now = DateTime.now();
    return _allAppointments.where((appointment) {
        final appointmentDate = appointment['dateTime'] as DateTime;
        final status = appointment['status'] as AppointmentStatus;
        return appointmentDate.isBefore(now) ||
            status == AppointmentStatus.completed ||
            status == AppointmentStatus.cancelled;
      }).toList()
      ..sort(
        (a, b) =>
            (b['dateTime'] as DateTime).compareTo(a['dateTime'] as DateTime),
      );
  }

  int _getUpcomingCount() => _getUpcomingAppointments().length;
  int _getPastCount() => _getPastAppointments().length;

  bool _canCancelAppointment(AppointmentStatus status) {
    return status == AppointmentStatus.scheduled ||
        status == AppointmentStatus.confirmed;
  }

  bool _canRescheduleAppointment(AppointmentStatus status) {
    return status == AppointmentStatus.scheduled;
  }

  String _getEmptyStateTitle() {
    switch (_tabController.index) {
      case 0:
        return 'No tienes citas próximas';
      case 1:
        return 'No tienes citas pasadas';
      case 2:
      default:
        return 'No tienes citas registradas';
    }
  }

  String _getEmptyStateMessage() {
    switch (_tabController.index) {
      case 0:
        return 'Agenda una consulta veterinaria para cuidar mejor la salud de tu mascota.';
      case 1:
        return 'Aquí aparecerán las citas que ya hayas completado o cancelado.';
      case 2:
      default:
        return 'Comienza agendando tu primera cita veterinaria para tu mascota.';
    }
  }

  // Métodos de navegación y acciones
  void _navigateToScheduleAppointment() {
    Navigator.pushNamed(context, '/schedule-appointment');
  }

  void _navigateToAppointmentDetail(Map<String, dynamic> appointment) {
    Navigator.pushNamed(context, '/appointment-detail', arguments: appointment);
  }

  Future<void> _cancelAppointment(Map<String, dynamic> appointment) async {
    final confirmed = await ConfirmationModal.show(
      context: context,
      title: 'Cancelar cita',
      message:
          '¿Estás seguro de que quieres cancelar esta cita?\n\nTipo: ${appointment['appointmentType']}\nMascota: ${appointment['petName']}\nVeterinario: ${appointment['veterinarianName']}',
      confirmText: 'Cancelar cita',
      cancelText: 'No cancelar',
      icon: Icons.cancel_outlined,
      iconColor: const Color(0xFFFF7043),
      confirmButtonColor: const Color(0xFFFF7043),
    );

    if (confirmed == true) {
      setState(() {
        final index = _allAppointments.indexWhere(
          (apt) => apt['id'] == appointment['id'],
        );
        if (index != -1) {
          _allAppointments[index]['status'] = AppointmentStatus.cancelled;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cita cancelada exitosamente'),
            backgroundColor: const Color(0xFFFF7043),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _rescheduleAppointment(Map<String, dynamic> appointment) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reprogramar cita de ${appointment['petName']}'),
        backgroundColor: const Color(0xFF81D4FA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
