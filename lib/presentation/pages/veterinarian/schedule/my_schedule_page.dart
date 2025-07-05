import 'package:flutter/material.dart';
import '../../../widgets/cards/appointment_card.dart';

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DateTime selectedDate = DateTime.now();
  String _viewMode = 'day'; // 'day', 'week', 'month'

  // Mock data de citas para veterinario
  final List<Map<String, dynamic>> _allAppointments = [
    {
      'id': '1',
      'petName': 'Max',
      'ownerName': 'Juan Pérez',
      'appointmentType': 'Consulta General',
      'dateTime': DateTime.now().add(const Duration(hours: 2)),
      'status': AppointmentStatus.confirmed,
      'duration': 30,
      'notes': 'Control de rutina',
      'ownerPhone': '+52 961 123 4567',
    },
    {
      'id': '2',
      'petName': 'Luna',
      'ownerName': 'Ana García',
      'appointmentType': 'Vacunación',
      'dateTime': DateTime.now().add(const Duration(hours: 4)),
      'status': AppointmentStatus.scheduled,
      'duration': 20,
      'notes': 'Vacuna anual',
      'ownerPhone': '+52 961 234 5678',
    },
    {
      'id': '3',
      'petName': 'Rocky',
      'ownerName': 'Carlos López',
      'appointmentType': 'Cirugía Menor',
      'dateTime': DateTime.now().add(const Duration(days: 1, hours: 1)),
      'status': AppointmentStatus.scheduled,
      'duration': 60,
      'notes': 'Remoción de quiste',
      'ownerPhone': '+52 961 345 6789',
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
              _buildDateNavigator(),
              _buildViewModeSelector(),
              Expanded(child: _buildScheduleView()),
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
        gradient: LinearGradient(
          colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
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
                  'Mi Agenda',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Gestiona tus consultas y horarios',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {
                // Configurar horarios
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigator() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.subtract(const Duration(days: 1));
              });
            },
            icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF81D4FA)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _selectDate,
              child: Column(
                children: [
                  Text(
                    _formatDate(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getAppointmentsForDate(selectedDate).length} citas',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.add(const Duration(days: 1));
              });
            },
            icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF81D4FA)),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildViewModeButton('Día', 'day', Icons.view_day_outlined),
          _buildViewModeButton('Semana', 'week', Icons.view_week_outlined),
          _buildViewModeButton('Mes', 'month', Icons.calendar_month_outlined),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(String label, String mode, IconData icon) {
    final isSelected = _viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _viewMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF81D4FA) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF757575),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleView() {
    switch (_viewMode) {
      case 'day':
        return _buildDayView();
      case 'week':
        return _buildWeekView();
      case 'month':
        return _buildMonthView();
      default:
        return _buildDayView();
    }
  }

  Widget _buildDayView() {
    final appointments = _getAppointmentsForDate(selectedDate);
    
    if (appointments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = (_animationController.value - delay).clamp(0.0, 1.0);
            
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: AppointmentCard(
                  petName: appointment['petName'],
                  veterinarianName: 'Dr. María González', // Current vet
                  appointmentType: appointment['appointmentType'],
                  dateTime: appointment['dateTime'],
                  status: appointment['status'],
                  notes: appointment['notes'],
                  isOwnerView: false,
                  ownerName: appointment['ownerName'],
                  onTap: () => _navigateToAppointmentDetail(appointment),
                  onConfirm: _canConfirmAppointment(appointment['status']) 
                      ? () => _confirmAppointment(appointment) 
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeekView() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_week_outlined,
              size: 64,
              color: Color(0xFF81D4FA),
            ),
            SizedBox(height: 16),
            Text(
              'Vista Semanal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Próximamente disponible',
              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthView() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: Color(0xFF81D4FA),
            ),
            SizedBox(height: 16),
            Text(
              'Vista Mensual',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Próximamente disponible',
              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
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
                color: const Color(0xFF81D4FA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.event_available_outlined,
                size: 60,
                color: Color(0xFF81D4FA),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay citas programadas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Las citas para ${_formatDate(selectedDate)} aparecerán aquí.',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
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
    return FloatingActionButton.extended(
      onPressed: () {
        // Configurar disponibilidad
      },
      backgroundColor: const Color(0xFF81D4FA),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.schedule_rounded),
      label: const Text(
        'Horarios',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  // Métodos auxiliares
  List<Map<String, dynamic>> _getAppointmentsForDate(DateTime date) {
    return _allAppointments.where((appointment) {
      final appointmentDate = appointment['dateTime'] as DateTime;
      return appointmentDate.day == date.day &&
          appointmentDate.month == date.month &&
          appointmentDate.year == date.year;
    }).toList()
      ..sort((a, b) => (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));
  }

  bool _canConfirmAppointment(AppointmentStatus status) {
    return status == AppointmentStatus.scheduled;
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                   'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    
    final today = DateTime.now();
    if (date.day == today.day && date.month == today.month && date.year == today.year) {
      return 'Hoy, ${date.day} $month';
    }
    
    final tomorrow = today.add(const Duration(days: 1));
    if (date.day == tomorrow.day && date.month == tomorrow.month && date.year == tomorrow.year) {
      return 'Mañana, ${date.day} $month';
    }
    
    return '$weekday, ${date.day} $month';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF81D4FA),
              onPrimary: Colors.white,
              onSurface: Color(0xFF212121),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _navigateToAppointmentDetail(Map<String, dynamic> appointment) {
    Navigator.pushNamed(
      context, 
      '/appointment-detail-vet', 
      arguments: appointment
    );
  }

  void _confirmAppointment(Map<String, dynamic> appointment) {
    setState(() {
      final index = _allAppointments.indexWhere((apt) => apt['id'] == appointment['id']);
      if (index != -1) {
        _allAppointments[index]['status'] = AppointmentStatus.confirmed;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cita de ${appointment['petName']} confirmada'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}