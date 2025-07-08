import 'package:flutter/material.dart';

class ConfigureSchedulePage extends StatefulWidget {
  const ConfigureSchedulePage({super.key});

  @override
  State<ConfigureSchedulePage> createState() => _ConfigureSchedulePageState();
}

class _ConfigureSchedulePageState extends State<ConfigureSchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Configuración general
  int _consultationDuration = 30; // minutos
  int _breakDuration = 15; // minutos
  bool _allowEmergencies = true;
  bool _autoConfirmAppointments = false;
  
  // Horarios por día de la semana
  Map<String, Map<String, dynamic>> weeklySchedule = {
    'monday': {
      'enabled': true,
      'periods': [
        {'start': '08:00', 'end': '12:00'},
        {'start': '14:00', 'end': '18:00'},
      ],
      'breaks': [
        {'start': '10:30', 'end': '10:45'},
        {'start': '16:00', 'end': '16:15'},
      ],
    },
    'tuesday': {
      'enabled': true,
      'periods': [
        {'start': '08:00', 'end': '12:00'},
        {'start': '14:00', 'end': '18:00'},
      ],
      'breaks': [
        {'start': '10:30', 'end': '10:45'},
        {'start': '16:00', 'end': '16:15'},
      ],
    },
    'wednesday': {
      'enabled': true,
      'periods': [
        {'start': '08:00', 'end': '12:00'},
        {'start': '14:00', 'end': '18:00'},
      ],
      'breaks': [
        {'start': '10:30', 'end': '10:45'},
        {'start': '16:00', 'end': '16:15'},
      ],
    },
    'thursday': {
      'enabled': true,
      'periods': [
        {'start': '08:00', 'end': '12:00'},
        {'start': '14:00', 'end': '18:00'},
      ],
      'breaks': [
        {'start': '10:30', 'end': '10:45'},
        {'start': '16:00', 'end': '16:15'},
      ],
    },
    'friday': {
      'enabled': true,
      'periods': [
        {'start': '08:00', 'end': '12:00'},
        {'start': '14:00', 'end': '17:00'},
      ],
      'breaks': [
        {'start': '10:30', 'end': '10:45'},
        {'start': '15:30', 'end': '15:45'},
      ],
    },
    'saturday': {
      'enabled': true,
      'periods': [
        {'start': '09:00', 'end': '14:00'},
      ],
      'breaks': [
        {'start': '11:30', 'end': '11:45'},
      ],
    },
    'sunday': {
      'enabled': false,
      'periods': [],
      'breaks': [],
    },
  };

  // Excepciones especiales (días específicos)
  List<Map<String, dynamic>> specialDays = [
    {
      'date': '2025-12-25',
      'description': 'Navidad',
      'enabled': false,
      'periods': [],
    },
    {
      'date': '2025-01-01',
      'description': 'Año Nuevo',
      'enabled': false,
      'periods': [],
    },
  ];

  final Map<String, String> dayNames = {
    'monday': 'Lunes',
    'tuesday': 'Martes',
    'wednesday': 'Miércoles',
    'thursday': 'Jueves',
    'friday': 'Viernes',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Configurar Horarios',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF0D9488)),
            onPressed: _saveSchedule,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0D9488),
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFF0D9488),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Horarios'),
            Tab(text: 'Configuración'),
            Tab(text: 'Excepciones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleTab(),
          _buildGeneralSettingsTab(),
          _buildExceptionsTab(),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen semanal
          _buildWeeklySummary(),
          const SizedBox(height: 20),
          
          // Configuración por día
          ...weeklySchedule.entries.map((dayEntry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDayScheduleCard(dayEntry.key, dayEntry.value),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary() {
    final activeDays = weeklySchedule.values.where((day) => day['enabled'] == true).length;
    final totalHours = weeklySchedule.entries
        .where((entry) => entry.value['enabled'] == true)
        .fold<double>(0, (sum, entry) {
          final periods = entry.value['periods'] as List;
          return sum + periods.fold<double>(0, (periodSum, period) {
            final start = TimeOfDay(
              hour: int.parse(period['start'].split(':')[0]),
              minute: int.parse(period['start'].split(':')[1]),
            );
            final end = TimeOfDay(
              hour: int.parse(period['end'].split(':')[0]),
              minute: int.parse(period['end'].split(':')[1]),
            );
            return periodSum + _calculateHoursBetween(start, end);
          });
        });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen Semanal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.calendar_today,
                  label: 'Días activos',
                  value: '$activeDays/7',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.schedule,
                  label: 'Horas totales',
                  value: '${totalHours.toStringAsFixed(1)}h',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDayScheduleCard(String dayKey, Map<String, dynamic> dayData) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header del día
          Row(
            children: [
              Expanded(
                child: Text(
                  dayNames[dayKey] ?? dayKey,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Switch(
                value: dayData['enabled'],
                onChanged: (value) {
                  setState(() {
                    dayData['enabled'] = value;
                    if (!value) {
                      dayData['periods'] = [];
                      dayData['breaks'] = [];
                    }
                  });
                },
                activeColor: const Color(0xFF0D9488),
              ),
            ],
          ),
          
          if (dayData['enabled']) ...[
            const SizedBox(height: 16),

            const Text(
              'Períodos de atención',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            
            ...(dayData['periods'] as List).asMap().entries.map((periodEntry) {
              final index = periodEntry.key;
              final period = periodEntry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTimePeriod(
                  period: period,
                  onStartChanged: (time) {
                    setState(() {
                      period['start'] = time;
                    });
                  },
                  onEndChanged: (time) {
                    setState(() {
                      period['end'] = time;
                    });
                  },
                  onDelete: () {
                    setState(() {
                      (dayData['periods'] as List).removeAt(index);
                    });
                  },
                ),
              );
            }).toList(),
            
            InkWell(
              onTap: () => _addPeriod(dayData),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF0D9488).withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFF0D9488), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Agregar período',
                      style: TextStyle(
                        color: Color(0xFF0D9488),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Descansos
            const Text(
              'Descansos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            
            ...(dayData['breaks'] as List).asMap().entries.map((breakEntry) {
              final index = breakEntry.key;
              final breakPeriod = breakEntry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTimePeriod(
                  period: breakPeriod,
                  isBreak: true,
                  onStartChanged: (time) {
                    setState(() {
                      breakPeriod['start'] = time;
                    });
                  },
                  onEndChanged: (time) {
                    setState(() {
                      breakPeriod['end'] = time;
                    });
                  },
                  onDelete: () {
                    setState(() {
                      (dayData['breaks'] as List).removeAt(index);
                    });
                  },
                ),
              );
            }).toList(),
            
            // Botón agregar descanso
            InkWell(
              onTap: () => _addBreak(dayData),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFF6B7280), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Agregar descanso',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Día no laborable',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePeriod({
    required Map<String, dynamic> period,
    required Function(String) onStartChanged,
    required Function(String) onEndChanged,
    required VoidCallback onDelete,
    bool isBreak = false,
  }) {
    final backgroundColor = isBreak 
        ? const Color(0xFFDDD6FE) 
        : const Color(0xFFDCFCE7);
    final borderColor = isBreak 
        ? const Color(0xFF8B5CF6) 
        : const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (isBreak)
            const Icon(Icons.coffee, size: 16, color: Color(0xFF8B5CF6))
          else
            const Icon(Icons.schedule, size: 16, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, period['start'], onStartChanged),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        period['start'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: borderColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, period['end'], onEndChanged),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        period['end'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: borderColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: const Color(0xFFEF4444),
            constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Duración de consultas
          _buildSettingsCard(
            title: 'Configuración de Consultas',
            children: [
              _buildSliderSetting(
                label: 'Duración de consulta',
                value: _consultationDuration.toDouble(),
                min: 15,
                max: 120,
                divisions: 7,
                unit: 'minutos',
                onChanged: (value) {
                  setState(() {
                    _consultationDuration = value.round();
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildSliderSetting(
                label: 'Tiempo entre consultas',
                value: _breakDuration.toDouble(),
                min: 0,
                max: 30,
                divisions: 6,
                unit: 'minutos',
                onChanged: (value) {
                  setState(() {
                    _breakDuration = value.round();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Configuración de citas
          _buildSettingsCard(
            title: 'Gestión de Citas',
            children: [
              _buildSwitchSetting(
                label: 'Permitir emergencias',
                subtitle: 'Acepta citas fuera del horario para emergencias',
                value: _allowEmergencies,
                onChanged: (value) {
                  setState(() {
                    _allowEmergencies = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildSwitchSetting(
                label: 'Confirmación automática',
                subtitle: 'Las citas se confirman automáticamente sin tu intervención',
                value: _autoConfirmAppointments,
                onChanged: (value) {
                  setState(() {
                    _autoConfirmAppointments = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExceptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Días Especiales',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addSpecialDay,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (specialDays.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.event_note,
                    size: 48,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay días especiales configurados',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            )
          else
            ...specialDays.asMap().entries.map((entry) {
              final index = entry.key;
              final specialDay = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSpecialDayCard(specialDay, index),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              '${value.round()} $unit',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D9488),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF0D9488),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: const Color(0xFF0D9488),
            overlayColor: const Color(0xFF0D9488).withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting({
    required String label,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF0D9488),
        ),
      ],
    );
  }

  Widget _buildSpecialDayCard(Map<String, dynamic> specialDay, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: specialDay['enabled'] 
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              specialDay['enabled'] ? Icons.event_available : Icons.event_busy,
              color: specialDay['enabled'] 
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialDay['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatSpecialDate(specialDay['date']),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteSpecialDay(index),
            icon: const Icon(Icons.delete_outline),
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  double _calculateHoursBetween(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return (endMinutes - startMinutes) / 60.0;
  }

  void _addPeriod(Map<String, dynamic> dayData) {
    setState(() {
      (dayData['periods'] as List).add({
        'start': '09:00',
        'end': '17:00',
      });
    });
  }

  void _addBreak(Map<String, dynamic> dayData) {
    setState(() {
      (dayData['breaks'] as List).add({
        'start': '12:00',
        'end': '12:15',
      });
    });
  }

  Future<void> _selectTime(BuildContext context, String currentTime, Function(String) onChanged) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF0D9488),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onChanged(formattedTime);
    }
  }

  void _addSpecialDay() {
    showDialog(
      context: context,
      builder: (context) {
        String description = '';
        DateTime selectedDate = DateTime.now();
        bool isWorkingDay = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Agregar Día Especial'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => description = value,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(_formatSpecialDate(selectedDate.toString().split(' ')[0])),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Día laborable'),
                    value: isWorkingDay,
                    onChanged: (value) {
                      setDialogState(() {
                        isWorkingDay = value;
                      });
                    },
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
                    if (description.isNotEmpty) {
                      setState(() {
                        specialDays.add({
                          'date': selectedDate.toString().split(' ')[0],
                          'description': description,
                          'enabled': isWorkingDay,
                          'periods': isWorkingDay ? [{'start': '09:00', 'end': '17:00'}] : [],
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteSpecialDay(int index) {
    setState(() {
      specialDays.removeAt(index);
    });
  }

  String _formatSpecialDate(String dateString) {
    final date = DateTime.parse(dateString);
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  void _saveSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Horarios guardados correctamente'),
        backgroundColor: Color(0xFF0D9488),
      ),
    );
    Navigator.pop(context);
  }
}