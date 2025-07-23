import 'package:flutter/material.dart';
import '../../../widgets/cards/appointment_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

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
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundShapes(),
          FadeTransition(
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

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: const Text(
          'Mi Agenda',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, color: AppColors.white),
          onPressed: () => _selectDate(),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.white),
          onPressed: () => Navigator.pushNamed(context, '/configure-schedule'),
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
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
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: dayAppointments.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildDateHeader();
        }

        final appointment = dayAppointments[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
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
      padding: const EdgeInsets.all(AppSizes.paddingL),
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

  Widget _buildWeekAppointmentItem(Map<String, dynamic> appointment) {
    final time =
        '${appointment['dateTime'].hour.toString().padLeft(2, '0')}:${appointment['dateTime'].minute.toString().padLeft(2, '0')}';

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
                    '${appointment['petName']} - ${appointment['ownerName']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    appointment['appointmentType'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          _buildMonthHeader(),
          const SizedBox(height: AppSizes.spaceM),
          _buildMonthCalendar(weeks),
          const SizedBox(height: AppSizes.spaceL),
          _buildMonthAppointmentsList(),
        ],
      ),
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

  Widget _buildMonthAppointmentItem(Map<String, dynamic> appointment) {
    final time =
        '${appointment['dateTime'].hour.toString().padLeft(2, '0')}:${appointment['dateTime'].minute.toString().padLeft(2, '0')}';

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
                    '${appointment['petName']} - ${appointment['ownerName']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    appointment['appointmentType'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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
      default:
        color = AppColors.textSecondary;
        text = 'Desconocido';
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
    final today = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(today) ? today : selectedDate,
      firstDate: today,
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
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
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }
}
