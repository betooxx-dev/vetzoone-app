import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class ConfigureSchedulePage extends StatefulWidget {
  const ConfigureSchedulePage({super.key});

  @override
  State<ConfigureSchedulePage> createState() => _ConfigureSchedulePageState();
}

class _ConfigureSchedulePageState extends State<ConfigureSchedulePage> {
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
    'sunday': {'enabled': false, 'periods': [], 'breaks': []},
  };

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundShapes(),
          SafeArea(
            child: Column(
              children: [
                _buildModernAppBar(),
                Expanded(child: _buildScheduleContent()),
              ],
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

  Widget _buildModernAppBar() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
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
          const SizedBox(width: AppSizes.spaceM),
          const Expanded(
            child: Text(
              'Configurar Horarios',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              icon: const Icon(Icons.check, color: AppColors.white),
              onPressed: _saveSchedule,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklySummary(),
          const SizedBox(height: AppSizes.spaceXL),

          // Configuración por día
          ...weeklySchedule.entries.map((dayEntry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceL),
              child: _buildDayScheduleCard(dayEntry.key, dayEntry.value),
            );
          }).toList(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary() {
    final activeDays =
        weeklySchedule.values.where((day) => day['enabled'] == true).length;
    final totalHours = weeklySchedule.entries
        .where((entry) => entry.value['enabled'] == true)
        .fold<double>(0, (sum, entry) {
          final periods = entry.value['periods'] as List;
          return sum +
              periods.fold<double>(0, (periodSum, period) {
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
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              const Text(
                'Resumen Semanal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.calendar_today,
                  label: 'Días activos',
                  value: '$activeDays/7',
                  color: AppColors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.spaceM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.secondary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.3),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.schedule,
                  label: 'Horas totales',
                  value: '${totalHours.toStringAsFixed(1)}h',
                  color: AppColors.secondary,
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
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Icon(icon, color: color, size: AppSizes.iconM),
        ),
        const SizedBox(height: AppSizes.spaceM),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDayScheduleCard(String dayKey, Map<String, dynamic> dayData) {
    final isEnabled = dayData['enabled'] as bool;

    return Container(
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
                isEnabled
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color:
              isEnabled
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del día
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              gradient:
                  isEnabled
                      ? AppColors.primaryGradient
                      : LinearGradient(
                        colors: [
                          AppColors.textSecondary,
                          AppColors.textSecondary.withOpacity(0.8),
                        ],
                      ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusXL),
                topRight: Radius.circular(AppSizes.radiusXL),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dayNames[dayKey] ?? dayKey,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Switch(
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
                    activeColor: AppColors.white,
                    activeTrackColor: AppColors.white.withOpacity(0.3),
                    inactiveThumbColor: AppColors.white.withOpacity(0.7),
                    inactiveTrackColor: AppColors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),

          // Contenido del día
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child:
                isEnabled
                    ? _buildEnabledDayContent(dayData)
                    : _buildDisabledDayContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnabledDayContent(Map<String, dynamic> dayData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Períodos de atención
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(
                Icons.schedule_rounded,
                color: AppColors.primary,
                size: AppSizes.iconS,
              ),
            ),
            const SizedBox(width: AppSizes.spaceS),
            const Text(
              'Períodos de atención',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),

        ...(dayData['periods'] as List).asMap().entries.map((periodEntry) {
          final index = periodEntry.key;
          final period = periodEntry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
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

        // Botón agregar período
        InkWell(
          onTap: () => _addPeriod(dayData),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppColors.primary, size: AppSizes.iconS),
                const SizedBox(width: AppSizes.spaceS),
                const Text(
                  'Agregar período',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSizes.spaceL),

        // Descansos
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(
                Icons.coffee_rounded,
                color: AppColors.accent,
                size: AppSizes.iconS,
              ),
            ),
            const SizedBox(width: AppSizes.spaceS),
            const Text(
              'Descansos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),

        ...(dayData['breaks'] as List).asMap().entries.map((breakEntry) {
          final index = breakEntry.key;
          final breakPeriod = breakEntry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
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
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: AppSizes.spaceS),
                const Text(
                  'Agregar descanso',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledDayContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            color: AppColors.textSecondary,
            size: AppSizes.iconL,
          ),
          const SizedBox(height: AppSizes.spaceS),
          const Text(
            'Día no laborable',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
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
    final backgroundColor =
        isBreak
            ? AppColors.accent.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1);
    final borderColor = isBreak ? AppColors.accent : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isBreak ? Icons.coffee_rounded : Icons.schedule_rounded,
            size: AppSizes.iconS,
            color: borderColor,
          ),
          const SizedBox(width: AppSizes.spaceS),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap:
                        () => _selectTime(
                          context,
                          period['start'],
                          onStartChanged,
                        ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        border: Border.all(color: borderColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        period['start'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: borderColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceS,
                  ),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: borderColor,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap:
                        () => _selectTime(context, period['end'], onEndChanged),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        border: Border.all(color: borderColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        period['end'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: borderColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSizes.spaceS),
          Container(
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.error,
              constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
              padding: EdgeInsets.zero,
            ),
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
      (dayData['periods'] as List).add({'start': '09:00', 'end': '17:00'});
    });
  }

  void _addBreak(Map<String, dynamic> dayData) {
    setState(() {
      (dayData['breaks'] as List).add({'start': '12:00', 'end': '12:15'});
    });
  }

  Future<void> _selectTime(
    BuildContext context,
    String currentTime,
    Function(String) onChanged,
  ) async {
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
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onChanged(formattedTime);
    }
  }

  void _saveSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Horarios guardados correctamente'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
    Navigator.pop(context);
  }
}
