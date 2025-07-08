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
  String _viewMode = 'day';

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
    {
      'id': '4',
      'petName': 'Milo',
      'ownerName': 'María Rodríguez',
      'appointmentType': 'Control de peso',
      'dateTime': DateTime.now().add(const Duration(days: 2)),
      'status': AppointmentStatus.scheduled,
      'duration': 15,
      'notes': 'Seguimiento dieta',
      'ownerPhone': '+52 961 456 7890',
    },
    {
      'id': '5',
      'petName': 'Bella',
      'ownerName': 'Luis Martínez',
      'appointmentType': 'Emergencia',
      'dateTime': DateTime.now().add(const Duration(days: 3)),
      'status': AppointmentStatus.completed,
      'duration': 45,
      'notes': 'Revisión urgente',
      'ownerPhone': '+52 961 567 8901',
    },
    {
      'id': '6',
      'petName': 'Coco',
      'ownerName': 'Patricia Silva',
      'appointmentType': 'Consulta General',
      'dateTime': DateTime.now().add(const Duration(days: 7)),
      'status': AppointmentStatus.scheduled,
      'duration': 30,
      'notes': 'Primera consulta',
      'ownerPhone': '+52 961 678 9012',
    },
    {
      'id': '7',
      'petName': 'Rex',
      'ownerName': 'Fernando López',
      'appointmentType': 'Vacunación',
      'dateTime': DateTime.now().add(const Duration(days: 14)),
      'status': AppointmentStatus.scheduled,
      'duration': 20,
      'notes': 'Refuerzo vacuna',
      'ownerPhone': '+52 961 789 0123',
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildViewToggle()),
            ];
          },
          body: _buildCurrentView(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewAppointmentDialog(),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF81D4FA),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Mi Agenda',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          onPressed: () => _selectDate(),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/configure-schedule'),
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF81D4FA) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF757575),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_viewMode) {
      case 'week':
        return _buildWeekView();
      case 'month':
        return _buildMonthView();
      default:
        return _buildDayView();
    }
  }

  Widget _buildDayView() {
    final dayAppointments = _getAppointmentsForDate(selectedDate);

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: dayAppointments.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildDateHeader();
        }

        final appointment = dayAppointments[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppointmentCard(
            petName: appointment['petName'],
            veterinarianName: 'Dr. María González',
            appointmentType: appointment['appointmentType'],
            dateTime: appointment['dateTime'],
            status: appointment['status'],
            notes: appointment['notes'],
            isOwnerView: false,
            ownerName: appointment['ownerName'],
            onTap: () => _navigateToAppointmentDetail(appointment),
            onConfirm:
                _canConfirmAppointment(appointment['status'])
                    ? () => _confirmAppointment(appointment)
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildWeekView() {
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: weekDays.length,
      itemBuilder: (context, index) {
        final day = weekDays[index];
        final dayAppointments = _getAppointmentsForDate(day);

        return _buildWeekDaySection(day, dayAppointments);
      },
    );
  }

  Widget _buildWeekDaySection(
    DateTime day,
    List<Map<String, dynamic>> appointments,
  ) {
    final isToday = _isSameDay(day, DateTime.now());
    final dayName = _getDayName(day.weekday);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isToday ? const Color(0xFF4CAF50) : const Color(0xFF81D4FA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$dayName ${day.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${appointments.length} citas',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          if (appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No hay citas programadas',
                style: TextStyle(color: Color(0xFF757575), fontSize: 14),
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

  Widget _buildWeekAppointmentItem(Map<String, dynamic> appointment) {
    final time =
        '${appointment['dateTime'].hour.toString().padLeft(2, '0')}:${appointment['dateTime'].minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () => _navigateToAppointmentDetail(appointment),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF81D4FA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF81D4FA),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${appointment['petName']} - ${appointment['ownerName']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    appointment['appointmentType'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(appointment['status']),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildMonthHeader(),
          const SizedBox(height: 16),
          _buildMonthCalendar(weeks),
          const SizedBox(height: 20),
          _buildMonthAppointmentsList(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final monthName = _getMonthName(selectedDate.month);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left, color: Color(0xFF81D4FA)),
          ),
          Text(
            '$monthName ${selectedDate.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right, color: Color(0xFF81D4FA)),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(List<List<DateTime>> weeks) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF81D4FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
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
                        color: Colors.white,
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

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedDate = day),
        child: Container(
          height: 50,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF81D4FA)
                    : isToday
                    ? const Color(0xFF4CAF50)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color:
                        isSelected || isToday
                            ? Colors.white
                            : isCurrentMonth
                            ? const Color(0xFF212121)
                            : const Color(0xFFBDBDBD),
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              if (appointmentsCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          isSelected || isToday
                              ? Colors.white
                              : const Color(0xFF4CAF50),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Citas del ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ),
          if (selectedDateAppointments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                'No hay citas programadas para este día',
                style: TextStyle(color: Color(0xFF757575), fontSize: 14),
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

  Widget _buildMonthAppointmentItem(Map<String, dynamic> appointment) {
    final time =
        '${appointment['dateTime'].hour.toString().padLeft(2, '0')}:${appointment['dateTime'].minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () => _navigateToAppointmentDetail(appointment),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(
              time,
              style: const TextStyle(
                color: Color(0xFF81D4FA),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${appointment['petName']} - ${appointment['ownerName']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    appointment['appointmentType'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(appointment['status']),
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: isToday ? const Color(0xFF4CAF50) : const Color(0xFF81D4FA),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            isToday
                ? 'Hoy'
                : '$dayName ${selectedDate.day}/${selectedDate.month}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isToday ? const Color(0xFF4CAF50) : const Color(0xFF212121),
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
        color = const Color(0xFF81D4FA);
        text = 'Programada';
        break;
      case AppointmentStatus.confirmed:
        color = const Color(0xFF4CAF50);
        text = 'Confirmada';
        break;
      case AppointmentStatus.inProgress:
        color = const Color(0xFFFF9800);
        text = 'En curso';
        break;
      case AppointmentStatus.completed:
        color = const Color(0xFF66BB6A);
        text = 'Completada';
        break;
      case AppointmentStatus.cancelled:
        color = const Color(0xFFE57373);
        text = 'Cancelada';
        break;
      default:
        color = const Color(0xFF757575);
        text = 'Desconocido';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

  List<Map<String, dynamic>> _getAppointmentsForDate(DateTime date) {
    return _allAppointments.where((appointment) {
        final appointmentDate = appointment['dateTime'] as DateTime;
        return _isSameDay(appointmentDate, date);
      }).toList()
      ..sort(
        (a, b) =>
            (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime),
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

  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  void _changeMonth(int direction) {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month + direction,
        1,
      );
    });
  }

  void _navigateToAppointmentDetail(Map<String, dynamic> appointment) {
    Navigator.pushNamed(
      context,
      '/appointment-detail-vet',
      arguments: appointment,
    );
  }

  bool _canConfirmAppointment(AppointmentStatus status) {
    return status == AppointmentStatus.scheduled;
  }

  void _confirmAppointment(Map<String, dynamic> appointment) {
    setState(() {
      appointment['status'] = AppointmentStatus.confirmed;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cita confirmada para ${appointment['petName']}'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _showNewAppointmentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nueva Cita'),
            content: const Text('¿Desea crear una nueva cita?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/schedule-appointment');
                },
                child: const Text('Crear'),
              ),
            ],
          ),
    );
  }
}
