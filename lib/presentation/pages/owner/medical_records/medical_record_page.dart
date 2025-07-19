import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/pet/pet_bloc.dart';
import '../../../blocs/pet/pet_event.dart';
import '../../../blocs/pet/pet_state.dart';
import '../../../../domain/entities/appointment.dart';
import 'package:intl/intl.dart';

class MedicalRecordPage extends StatefulWidget {
  final String petId;
  final String petName;
  const MedicalRecordPage({super.key, required this.petId, required this.petName});

  @override
  State<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _medicalRecords = [
    {
      'id': '1',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'type': 'Consulta General',
      'veterinarian': 'Dr. María González',
      'clinic': 'Clínica VetCare Tuxtla',
      'diagnosis': 'Salud general excelente',
      'treatment': 'Control de rutina completado',
      'notes':
          'Mascota en perfecto estado de salud. Mantener rutina de ejercicio.',
      'weight': '25.5 kg',
      'temperature': '38.2°C',
      'heartRate': '95 bpm',
      'medications': [
        {
          'name': 'Vitaminas multiples',
          'dosage': '1 tablet diaria',
          'duration': '30 días',
        },
      ],
    },
    {
      'id': '2',
      'date': DateTime.now().subtract(const Duration(days: 45)),
      'type': 'Vacunación',
      'veterinarian': 'Dr. Carlos López',
      'clinic': 'Hospital Veterinario Central',
      'diagnosis': 'Protocolo de vacunación completado',
      'treatment': 'Vacuna múltiple aplicada',
      'notes': 'Próxima vacuna en 6 meses. Sin reacciones adversas.',
      'weight': '25.0 kg',
      'medications': [],
    },
    {
      'id': '3',
      'date': DateTime.now().subtract(const Duration(days: 120)),
      'type': 'Cirugía Menor',
      'veterinarian': 'Dra. Ana García',
      'clinic': 'Centro Veterinario Especializado',
      'diagnosis': 'Extracción dental exitosa',
      'treatment': 'Cirugía dental completada sin complicaciones',
      'notes': 'Recuperación excelente. Dieta blanda por 7 días.',
      'weight': '24.8 kg',
      'temperature': '37.9°C',
      'medications': [
        {
          'name': 'Antibiótico',
          'dosage': '250mg cada 12h',
          'duration': '7 días',
        },
        {'name': 'Analgésico', 'dosage': '100mg cada 8h', 'duration': '5 días'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Cargar historial real de citas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetBloc>().add(GetPetByIdEvent(petId: widget.petId));
    });
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildPetHeader(),
            const SizedBox(height: 16),
            _buildTabBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildTabBarView()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
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
                  'Expediente Médico',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Historial completo de salud',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pets, color: Color(0xFF4CAF50), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.petName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
          Tab(text: 'Citas'),
          Tab(text: 'Medicamentos'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAppointmentsTab(),
        _buildMedicationsTab(),
      ],
    );
  }

  Widget _buildAppointmentsTab() {
    return BlocBuilder<PetBloc, PetState>(
      builder: (context, state) {
        if (state is PetLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PetLoaded) {
          final appointments = state.appointments;
          if (appointments.isEmpty) {
            return _buildEmptyState(
              'No hay citas registradas',
              'Las citas médicas aparecerán aquí',
              Icons.event_busy,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final formattedDate = DateFormat('dd/MM/yyyy').format(appointment.appointmentDate);
              return ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
                title: Text('Fecha: $formattedDate', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(appointment.notes ?? 'Sin notas'),
                trailing: Text(_mapAppointmentStatusToString(appointment.status)),
              );
            },
          );
        } else if (state is PetError) {
          return _buildEmptyState('Error', state.message, Icons.error_outline);
        }
        return _buildEmptyState('Sin datos', 'No se pudo cargar la información.', Icons.info_outline);
      },
    );
  }

  Widget _buildMedicationsTab() {
    final allMedications = <Map<String, dynamic>>[];

    for (final record in _medicalRecords) {
      if (record['medications'] != null && record['medications'] is List) {
        final medications = record['medications'] as List;
        for (final medication in medications) {
          if (medication is Map<String, dynamic>) {
            allMedications.add({
              ...medication,
              'date': record['date'],
              'veterinarian': record['veterinarian'],
            });
          }
        }
      }
    }

    if (allMedications.isEmpty) {
      return _buildEmptyState(
        'No hay medicamentos registrados',
        'Los tratamientos médicos aparecerán aquí',
        Icons.medication_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: allMedications.length,
      itemBuilder: (context, index) {
        final medication = allMedications[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: Color(0xFFFF7043),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dosis: ${medication['dosage']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  'Duración: ${medication['duration']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recetado: ${_formatDate(medication['date'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'consulta general':
        return const Color(0xFF4CAF50);
      case 'vacunación':
        return const Color(0xFF81D4FA);
      case 'cirugía menor':
      case 'cirugía':
        return const Color(0xFFFF7043);
      case 'emergencia':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'consulta general':
        return Icons.medical_services_outlined;
      case 'vacunación':
        return Icons.vaccines_outlined;
      case 'cirugía menor':
      case 'cirugía':
        return Icons.healing_outlined;
      case 'emergencia':
        return Icons.emergency_outlined;
      default:
        return Icons.health_and_safety_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _mapAppointmentStatusToString(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pendiente';
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.inProgress:
        return 'En progreso';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.rescheduled:
        return 'Reprogramada';
    }
  }
}
