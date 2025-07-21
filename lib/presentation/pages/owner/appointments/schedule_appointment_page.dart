import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/confirmation_modal.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  const ScheduleAppointmentPage({super.key});

  @override
  State<ScheduleAppointmentPage> createState() =>
      _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Map<String, dynamic>? selectedVeterinarian;
  Map<String, dynamic>? selectedPet;
  DateTime? selectedDate;
  String? selectedTimeSlot;
  String? selectedAppointmentType;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _pets = [
    {'id': '1', 'name': 'Max', 'species': 'Perro', 'breed': 'Labrador'},
    {'id': '2', 'name': 'Luna', 'species': 'Gato', 'breed': 'Persa'},
    {'id': '3', 'name': 'Rocky', 'species': 'Perro', 'breed': 'Bulldog'},
  ];

  final List<String> _appointmentTypes = [
    'Consulta General',
    'Vacunación',
    'Desparasitación',
    'Cirugía',
    'Control',
    'Emergencia',
    'Examen de laboratorio',
    'Radiografía',
  ];

  final Map<String, dynamic> _defaultVeterinarian = {
    'name': 'Dr. María González',
    'specialty': 'Medicina General',
    'clinic': 'Veterinaria Central',
    'image': null,
  };

  void _selectVeterinarian() async {
    final result = await Navigator.pushNamed(context, '/search-veterinarians');

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        selectedVeterinarian = result;
        selectedDate = null;
        selectedTimeSlot = null;
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

  @override
  void initState() {
    super.initState();
    selectedVeterinarian = _defaultVeterinarian;
    selectedPet = _pets.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        setState(() {
          if (arguments.containsKey('selectedVeterinarian')) {
            selectedVeterinarian = arguments['selectedVeterinarian'];
          }
          if (arguments.containsKey('selectedPet')) {
            final petData = arguments['selectedPet'];
            selectedPet = _pets.firstWhere(
              (pet) => pet['name'] == petData['name'],
              orElse: () => _pets.first,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
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
              child: Column(
                children: [_buildAppBar(), Expanded(child: _buildBody())],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        children: [
          Container(
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
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          const Expanded(
            child: Text(
              'Agendar Cita',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (selectedVeterinarian == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVeterinarianSelection(),
            const SizedBox(height: AppSizes.spaceL),
            _buildPetSelection(),
            const SizedBox(height: AppSizes.spaceL),
            _buildAppointmentTypeSelection(),
            const SizedBox(height: AppSizes.spaceL),
            _buildDateSelection(),
            if (selectedDate != null) ...[
              const SizedBox(height: AppSizes.spaceL),
              _buildTimeSlotSelection(),
            ],
            const SizedBox(height: AppSizes.spaceL),
            _buildNotesSection(),
            const SizedBox(height: AppSizes.spaceXL),
            _buildScheduleButton(),
            const SizedBox(height: AppSizes.spaceL),
          ],
        ),
      ),
    );
  }

  Widget _buildVeterinarianSelection() {
    return _buildFormSection(
      title: 'Veterinario',
      child: GestureDetector(
        onTap: _selectVeterinarian,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              selectedVeterinarian != null
                  ? Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary,
                              AppColors.secondary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: AppSizes.iconM,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedVeterinarian!['name'] ?? 'Veterinario',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedVeterinarian!['specialty'] ??
                                  'Especialidad',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              selectedVeterinarian!['clinic'] ?? 'Clínica',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
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
                  )
                  : Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        color: AppColors.secondary,
                        size: AppSizes.iconM,
                      ),
                      const SizedBox(width: AppSizes.spaceM),
                      const Expanded(
                        child: Text(
                          'Selecciona un veterinario',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
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
    );
  }

  Widget _buildPetSelection() {
    return _buildFormSection(
      title: 'Mascota',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<Map<String, dynamic>>(
          value: selectedPet,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Selecciona tu mascota',
            prefixIcon: Icon(
              Icons.pets_rounded,
              color: AppColors.secondary,
              size: AppSizes.iconM,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
          ),
          items:
              _pets.map((pet) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: pet,
                  child: Text('${pet['name']} - ${pet['species']}'),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              selectedPet = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Por favor selecciona una mascota';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentTypeSelection() {
    return _buildFormSection(
      title: 'Tipo de consulta',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: selectedAppointmentType,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Selecciona el tipo de consulta',
            prefixIcon: Icon(
              Icons.medical_services_outlined,
              color: AppColors.secondary,
              size: AppSizes.iconM,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
          ),
          items:
              _appointmentTypes.map((type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
          onChanged: (value) {
            setState(() {
              selectedAppointmentType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor selecciona el tipo de consulta';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return _buildFormSection(
      title: 'Fecha',
      child: GestureDetector(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
                    color:
                        selectedDate != null
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
    );
  }

  Widget _buildTimeSlotSelection() {
    final availableSlots = _getAvailableTimeSlotsForDate(selectedDate!);

    if (availableSlots.isEmpty) {
      return _buildFormSection(
        title: 'Horarios disponibles',
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: AppSizes.iconM,
              ),
              const SizedBox(width: AppSizes.spaceM),
              const Expanded(
                child: Text(
                  'No hay horarios disponibles para este día',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildFormSection(
      title: 'Horarios disponibles',
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Wrap(
          spacing: AppSizes.spaceM,
          runSpacing: AppSizes.spaceM,
          children:
              availableSlots.map((timeSlot) {
                final isSelected = selectedTimeSlot == timeSlot;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTimeSlot = timeSlot;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected
                              ? LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                ],
                              )
                              : null,
                      color: isSelected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      timeSlot,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildFormSection(
      title: 'Notas adicionales (opcional)',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe síntomas o información relevante...',
            prefixIcon: Icon(
              Icons.note_outlined,
              color: AppColors.secondary,
              size: AppSizes.iconM,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(AppSizes.paddingM),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleButton() {
    final canSchedule =
        selectedPet != null &&
        selectedAppointmentType != null &&
        selectedDate != null &&
        selectedTimeSlot != null;

    return Container(
      width: double.infinity,
      height: AppSizes.buttonHeightL,
      decoration: BoxDecoration(
        gradient:
            canSchedule
                ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
                : null,
        color: canSchedule ? null : AppColors.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow:
            canSchedule
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: ElevatedButton(
        onPressed: canSchedule ? _scheduleAppointment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor:
              canSchedule ? AppColors.white : AppColors.textSecondary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.white),
                    strokeWidth: 2.5,
                  ),
                )
                : const Text(
                  'Agendar Cita',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Widget _buildFormSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spaceM),
        child,
      ],
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTimeSlot = null;
      });
    }
  }

  Future<void> _scheduleAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await ConfirmationModal.show(
      context: context,
      title: 'Confirmar cita',
      message:
          '¿Estás seguro de que quieres agendar esta cita?\n\n'
          'Mascota: ${selectedPet!['name']}\n'
          'Tipo: $selectedAppointmentType\n'
          'Fecha: ${_formatDate(selectedDate!)}\n'
          'Hora: $selectedTimeSlot',
      confirmText: 'Agendar',
      icon: Icons.calendar_today_rounded,
      iconColor: AppColors.secondary,
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cita agendada exitosamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
      );
    }
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

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday, ${date.day} de $month';
  }
}
