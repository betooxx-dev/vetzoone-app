import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/veterinary_constants.dart';
import '../../../../core/injection/injection.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../data/datasources/vet/vet_remote_datasource.dart';

class ConfigureSchedulePage extends StatefulWidget {
  const ConfigureSchedulePage({super.key});

  @override
  State<ConfigureSchedulePage> createState() => _ConfigureSchedulePageState();
}

class _ConfigureSchedulePageState extends State<ConfigureSchedulePage> {
  String? _vetId;
  String? _userId;
  bool _isLoading = false;
  // Horarios por día de la semana - Simplificado sin descansos
  Map<String, Map<String, dynamic>> weeklySchedule = {
    'monday': {
      'enabled': false,
      'periods': <Map<String, dynamic>>[],
    },
    'tuesday': {
      'enabled': false,
      'periods': <Map<String, dynamic>>[],
    },
    'wednesday': {
      'enabled': false,
      'periods': <Map<String, dynamic>>[],
    },
    'thursday': {
      'enabled': false,
      'periods': <Map<String, dynamic>>[],
    },
    'friday': {
      'enabled': false,
      'periods': <Map<String, dynamic>>[],
    },
    'saturday': {
      'enabled': false,
      'periods': <Map<String, dynamic>>[],
    },
    'sunday': {
      'enabled': false,
      'periods': <Map<String, dynamic>>[],
    },
  };

  final Map<String, String> dayNames = VeterinaryConstants.dayMapping;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await SharedPreferencesHelper.getUserId();
      final vetId = await SharedPreferencesHelper.getVetId();
      
      setState(() {
        _userId = userId;
        _vetId = vetId;
      });
      
      // Cargar disponibilidad existente del veterinario
      await _loadExistingAvailability();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadExistingAvailability() async {
    try {
      final vetData = await SharedPreferencesHelper.getVetData();
      if (vetData != null && vetData['availability'] != null) {
        final List<dynamic> availabilityList = vetData['availability'];
        
        print('📅 Cargando disponibilidad existente: $availabilityList');
        
        // Limpiar el horario actual
        for (String day in VeterinaryConstants.weekDays) {
          weeklySchedule[day] = {
            'enabled': false,
            'periods': <Map<String, dynamic>>[],
          };
        }
        
        // Cargar la disponibilidad desde los datos guardados
        for (var availabilityItem in availabilityList) {
          if (availabilityItem is Map<String, dynamic>) {
            final day = availabilityItem['day'];
            final startTime = availabilityItem['start_time'];
            final endTime = availabilityItem['end_time'];
            
            if (day != null && startTime != null && endTime != null) {
              if (weeklySchedule.containsKey(day)) {
                weeklySchedule[day]!['enabled'] = true;
                (weeklySchedule[day]!['periods'] as List<Map<String, dynamic>>).add({
                  'start': startTime,
                  'end': endTime,
                });
              }
            }
          }
        }
        
        setState(() {
          // Trigger rebuild with loaded data
        });
        
        print('✅ Disponibilidad cargada exitosamente');
      } else {
        print('📅 No hay disponibilidad previa configurada');
      }
    } catch (e) {
      print('❌ Error cargando disponibilidad existente: $e');
    }
  }

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
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Icon(Icons.check, color: AppColors.white),
              onPressed: _isLoading ? null : _saveSchedule,
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
          final periods = entry.value['periods'] as List<Map<String, dynamic>>;
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
                          dayData['periods'] = <Map<String, dynamic>>[];
                        } else {
                          // Agregar un período por defecto cuando se habilita el día
                          final periods = dayData['periods'] as List<Map<String, dynamic>>;
                          if (periods.isEmpty) {
                            dayData['periods'] = <Map<String, dynamic>>[{'start': '09:00', 'end': '17:00'}];
                          }
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
              'Horarios de atención',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),

        ...(dayData['periods'] as List<Map<String, dynamic>>).asMap().entries.map((periodEntry) {
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
                  (dayData['periods'] as List<Map<String, dynamic>>).removeAt(index);
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
                  'Agregar horario',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: AppSizes.iconS,
            color: AppColors.primary,
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
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        period['start'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
                      color: AppColors.primary,
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
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        period['end'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
      (dayData['periods'] as List<Map<String, dynamic>>).add({'start': '09:00', 'end': '17:00'});
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

  Future<void> _saveSchedule() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vetDataSource = sl<VetRemoteDataSource>();
      
      // Convertir el horario semanal al formato esperado por el backend
      final List<Map<String, dynamic>> availability = [];
      
      weeklySchedule.forEach((day, daySchedule) {
        if (daySchedule['enabled'] == true) {
          final periods = daySchedule['periods'] as List;
          
          for (final period in periods) {
            if (period is Map<String, dynamic>) {
              availability.add({
                'day': day,  // Usar el nombre en inglés
                'start_time': period['start'] as String,
                'end_time': period['end'] as String,
              });
            }
          }
        }
      });
      
      print('🔄 Enviando disponibilidad al servidor: $availability');
      
      await vetDataSource.updateVetAvailability(_vetId!, _userId!, availability);
      
      print('✅ Disponibilidad actualizada correctamente en el servidor');
      
      // Refrescar los datos del veterinario en SharedPreferences con verificación
      await _refreshVetData();
      
      // Verificar que los datos se guardaron correctamente
      final savedVetData = await SharedPreferencesHelper.getVetData();
      if (savedVetData != null) {
        final savedAvailability = await SharedPreferencesHelper.getVetAvailability();
        print('✅ Verificación: Disponibilidad guardada correctamente: ${savedAvailability.length} periodos');
      } else {
        print('⚠️ Advertencia: No se encontraron datos del veterinario después de la actualización');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario guardado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error guardando horario: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el horario: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshVetData() async {
    try {
      if (_userId == null) {
        print('⚠️ No se puede refrescar datos sin userId');
        return;
      }
      
      print('🔄 Refrescando datos del veterinario...');
      
      final vetDataSource = sl<VetRemoteDataSource>();
      final vetResponse = await vetDataSource.getVetByUserId(_userId!);
      
      print('📥 Respuesta recibida del servidor: ${vetResponse.keys}');
      
      final fullResponse = vetResponse.containsKey('message')
          ? vetResponse
          : {'message': 'Vet retrieved successfully', 'data': vetResponse};
      
      // Guardar la respuesta completa del veterinario
      await SharedPreferencesHelper.saveVetProfileFromResponse(fullResponse);
      
      print('✅ Datos del veterinario actualizados en SharedPreferences');
      
      // Verificación adicional de que los datos se guardaron correctamente
      final savedVetData = await SharedPreferencesHelper.getVetData();
      if (savedVetData != null) {
        print('✅ Verificación exitosa: Datos guardados correctamente');
        print('   - Vet ID: ${savedVetData['id']}');
        print('   - Nombre: ${savedVetData['name']}');
        print('   - Disponibilidad: ${(savedVetData['availability'] as List).length} periodos');
      } else {
        print('⚠️ Advertencia: No se pudieron verificar los datos guardados');
      }
    } catch (e) {
      print('❌ Error refrescando datos del veterinario: $e');
      // No lanzar la excepción para no interrumpir el flujo de guardado
    }
  }
}
