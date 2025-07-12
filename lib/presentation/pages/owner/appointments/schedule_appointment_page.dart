import 'package:flutter/material.dart';
import '../../../../core/widgets/confirmation_modal.dart';
import '../../../../core/widgets/date_time_selector.dart';

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
    // Set defaults immediately
    selectedVeterinarian = _defaultVeterinarian;
    selectedPet = _pets.first;

    // Then check for arguments and override if they exist
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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Agendar Cita',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF212121)),
      ),
    );
  }

  Widget _buildBody() {
    if (selectedVeterinarian == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVeterinarianSelection(),
            const SizedBox(height: 24),
            _buildPetSelection(),
            const SizedBox(height: 24),
            _buildAppointmentTypeSelection(),
            const SizedBox(height: 24),
            _buildDateSelection(),
            if (selectedDate != null) ...[
              const SizedBox(height: 24),
              _buildTimeSlotSelection(),
            ],
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 32),
            _buildScheduleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVeterinarianSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Veterinario',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _selectVeterinarian,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child:
                selectedVeterinarian != null
                    ? Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 25,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedVeterinarian!['name'] ?? 'Veterinario',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedVeterinarian!['specialty'] ??
                                    'Especialidad',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              Text(
                                selectedVeterinarian!['clinic'] ?? 'Clínica',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF757575),
                          size: 16,
                        ),
                      ],
                    )
                    : Row(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Selecciona un veterinario',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF757575),
                          size: 16,
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mascota',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedPet,
            isExpanded: true,
            decoration: const InputDecoration(
              hintText: 'Selecciona tu mascota',
              prefixIcon: Icon(Icons.pets_rounded, color: Color(0xFF4CAF50)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
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
      ],
    );
  }

  Widget _buildAppointmentTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de consulta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedAppointmentType,
            isExpanded: true,
            decoration: const InputDecoration(
              hintText: 'Selecciona el tipo de consulta',
              prefixIcon: Icon(
                Icons.medical_services_outlined,
                color: Color(0xFF4CAF50),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items:
                _appointmentTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
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
      ],
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : 'Selecciona una fecha',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          selectedDate != null
                              ? const Color(0xFF212121)
                              : const Color(0xFF757575),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF757575),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelection() {
    final availableSlots = _getAvailableTimeSlotsForDate(selectedDate!);

    if (availableSlots.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horarios disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No hay horarios disponibles para este día',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horarios disponibles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
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
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF4CAF50)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        timeSlot,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF212121),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notas adicionales (opcional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Describe síntomas o información relevante...',
              prefixIcon: Icon(Icons.note_outlined, color: Color(0xFF4CAF50)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
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
      height: 56,
      decoration: BoxDecoration(
        gradient:
            canSchedule
                ? const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
                : null,
        color: canSchedule ? null : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: canSchedule ? _scheduleAppointment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: canSchedule ? Colors.white : const Color(0xFF757575),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
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
        selectedTimeSlot = null; // Reset time slot when date changes
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
      iconColor: const Color(0xFF4CAF50),
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
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
