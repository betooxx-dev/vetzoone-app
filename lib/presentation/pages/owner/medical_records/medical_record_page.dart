import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/pet/pet_bloc.dart';
import '../../../blocs/pet/pet_event.dart';
import '../../../blocs/pet/pet_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../domain/entities/appointment.dart';
import 'package:intl/intl.dart';

class MedicalRecordPage extends StatefulWidget {
  final String petId;
  final String petName;

  const MedicalRecordPage({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  String? _expandedAppointmentId;
  String? _expandedRecordId;
  String? _expandedVaccineId;

  final List<Map<String, dynamic>> _medicalRecords = [
    {
      'id': 'c996f950-7948-4c8b-8f19-ded21b198c85',
      'pet_id': '00aaf4ab-0432-4da7-939e-c302ea7134d0',
      'vet_id': 'c608e323-3bc8-46dc-9847-a5e19bbfc0b4',
      'appointment_id': null,
      'visit_date': '2025-07-18T10:00:00.000Z',
      'chief_complaint':
          'El perro no come bien desde hace 2 días - ACTUALIZADO',
      'diagnosis': 'Posible gastritis leve',
      'notes': 'Recomendar dieta blanda por 24 horas',
      'urgency_level': 'MEDIUM',
      'status': 'FINAL',
      'veterinarian_name': 'Dr. María González',
      'treatments': [
        {
          'id': 'treat_001',
          'medication': 'Omeprazol',
          'dosage': '20mg',
          'frequency': '1 vez al día',
          'duration': '7 días',
          'instructions': 'Administrar con alimento',
        },
        {
          'id': 'treat_002',
          'medication': 'Dieta blanda',
          'dosage': 'Ad libitum',
          'frequency': 'Por 3 días',
          'duration': '3 días',
          'instructions': 'Arroz con pollo hervido',
        },
      ],
    },
    {
      'id': 'c996f950-7948-4c8b-8f19-ded21b198c86',
      'pet_id': '00aaf4ab-0432-4da7-939e-c302ea7134d0',
      'vet_id': 'c608e323-3bc8-46dc-9847-a5e19bbfc0b4',
      'appointment_id': 'app_002',
      'visit_date': '2025-07-15T10:30:00.000Z',
      'chief_complaint': 'Control de rutina y revisión general',
      'diagnosis': 'Estado general excelente',
      'notes': 'Mantener rutina de ejercicio y alimentación',
      'urgency_level': 'LOW',
      'status': 'FINAL',
      'veterinarian_name': 'Dr. Carlos López',
      'treatments': [
        {
          'id': 'treat_003',
          'medication': 'Vitaminas multiples',
          'dosage': '1 tableta',
          'frequency': '1 vez al día',
          'duration': '30 días',
          'instructions': 'Con el desayuno',
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _vaccinations = [
    {
      'id': '52792f4e-bf06-4dc3-914f-864ea4cb5ad3',
      'pet_id': '00aaf4ab-0432-4da7-939e-c302ea7134d0',
      'vet_id': 'c608e323-3bc8-46dc-9847-a5e19bbfc0b4',
      'vaccine_name': 'Triple Viral Canina',
      'manufacturer': 'Pfizer',
      'batch_number': 'TV2024-001',
      'administered_date': '2024-01-15',
      'next_due_date': '2025-01-15',
      'notes': 'Aplicada en el muslo derecho',
      'veterinarian_name': 'Dr. María González',
    },
    {
      'id': '52792f4e-bf06-4dc3-914f-864ea4cb5ad4',
      'pet_id': '00aaf4ab-0432-4da7-939e-c302ea7134d0',
      'vet_id': 'c608e323-3bc8-46dc-9847-a5e19bbfc0b4',
      'vaccine_name': 'Antirrábica',
      'manufacturer': 'Merck',
      'batch_number': 'AR2024-005',
      'administered_date': '2024-03-10',
      'next_due_date': '2025-03-10',
      'notes': 'Sin reacciones adversas',
      'veterinarian_name': 'Dr. Carlos López',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetBloc>().add(GetPetByIdEvent(petId: widget.petId));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                children: [
                  _buildAppBar(),
                  _buildPetHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAppointmentsTab(),
                        _buildMedicalRecordsTab(),
                        _buildVaccinationsTab(),
                      ],
                    ),
                  ),
                ],
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
              borderRadius: BorderRadius.circular(12),
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
              'Historial Médico',
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

  Widget _buildPetHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.medical_information_outlined,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historial Médico',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Expediente completo de ${widget.petName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withOpacity(0.9),
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
      margin: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(6),
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        tabs: const [
          Tab(text: 'Citas'),
          Tab(text: 'Expedientes'),
          Tab(text: 'Vacunas'),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return BlocBuilder<PetBloc, PetState>(
      builder: (context, state) {
        if (state is PetLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        } else if (state is PetLoaded) {
          final appointments = state.appointments;
          if (appointments.isEmpty) {
            return _buildEmptyState(
              'No hay citas registradas',
              'Las citas médicas aparecerán aquí',
              Icons.event_busy,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _buildExpandableAppointmentCard(appointment);
            },
          );
        } else if (state is PetError) {
          return _buildEmptyState('Error', state.message, Icons.error_outline);
        }
        return _buildEmptyState(
          'Sin datos',
          'No se pudo cargar la información.',
          Icons.info_outline,
        );
      },
    );
  }

  Widget _buildMedicalRecordsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: _medicalRecords.length,
      itemBuilder: (context, index) {
        final record = _medicalRecords[index];
        return _buildExpandableMedicalRecordCard(record);
      },
    );
  }

  Widget _buildVaccinationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: _vaccinations.length,
      itemBuilder: (context, index) {
        final vaccine = _vaccinations[index];
        return _buildExpandableVaccinationCard(vaccine);
      },
    );
  }

  Widget _buildExpandableAppointmentCard(Appointment appointment) {
    final appointmentDate = appointment.appointmentDate;
    final status = appointment.status;
    final statusColor = _getAppointmentStatusColor(status);
    final isExpanded = _expandedAppointmentId == appointment.id;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [statusColor, statusColor.withOpacity(0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _expandedAppointmentId =
                            isExpanded ? null : appointment.id;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      statusColor,
                                      statusColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: AppSizes.spaceM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getAppointmentStatusText(status),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy • HH:mm',
                                      ).format(appointmentDate),
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          if (!isExpanded) ...[
                            const SizedBox(height: AppSizes.spaceS),
                            Text(
                              'Dr. Veterinario • Clínica Veterinaria',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              Container(
                color: AppColors.backgroundLight,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.secondary.withOpacity(
                              0.1,
                            ),
                            child: Icon(
                              Icons.local_hospital,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dr. Veterinario',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Clínica Veterinaria',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (appointment.notes != null &&
                        appointment.notes!.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.spaceM),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.note_alt_outlined,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: AppSizes.spaceS),
                                const Text(
                                  'Notas',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.spaceS),
                            Text(
                              appointment.notes!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableMedicalRecordCard(Map<String, dynamic> record) {
    final visitDate = DateTime.parse(record['visit_date']);
    final treatments = record['treatments'] as List<dynamic>;
    final urgencyColor = _getUrgencyColor(record['urgency_level']);
    final isExpanded = _expandedRecordId == record['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: urgencyColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: urgencyColor.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [urgencyColor, urgencyColor.withOpacity(0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _expandedRecordId = isExpanded ? null : record['id'];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      urgencyColor,
                                      urgencyColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.medical_services,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: AppSizes.spaceM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record['urgency_level']
                                          .toString()
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: urgencyColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(visitDate),
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          if (!isExpanded) ...[
                            const SizedBox(height: AppSizes.spaceS),
                            Text(
                              record['chief_complaint'],
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              Container(
                color: AppColors.backgroundLight,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.accent.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          Expanded(
                            child: Text(
                              record['veterinarian_name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceM),
                    _buildInfoSection(
                      'Motivo de consulta',
                      record['chief_complaint'],
                      Icons.help_outline,
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    _buildInfoSection(
                      'Diagnóstico',
                      record['diagnosis'],
                      Icons.assignment,
                    ),
                    if (record['notes'] != null) ...[
                      const SizedBox(height: AppSizes.spaceS),
                      _buildInfoSection(
                        'Notas',
                        record['notes'],
                        Icons.note_alt_outlined,
                      ),
                    ],
                    if (treatments.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.spaceM),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withOpacity(0.05),
                              AppColors.secondary.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.medication,
                                  color: AppColors.secondary,
                                  size: 16,
                                ),
                                const SizedBox(width: AppSizes.spaceS),
                                const Text(
                                  'Tratamientos',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.spaceM),
                            ...treatments.map(
                              (treatment) =>
                                  _buildModernTreatmentItem(treatment),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableVaccinationCard(Map<String, dynamic> vaccine) {
    final administeredDate = DateTime.parse(vaccine['administered_date']);
    final nextDueDate = DateTime.parse(vaccine['next_due_date']);
    final isOverdue = nextDueDate.isBefore(DateTime.now());
    final statusColor = isOverdue ? AppColors.error : AppColors.success;
    final isExpanded = _expandedVaccineId == vaccine['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: isOverdue ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [statusColor, statusColor.withOpacity(0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                if (isOverdue)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'VENCIDA',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _expandedVaccineId = isExpanded ? null : vaccine['id'];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      statusColor,
                                      statusColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isOverdue ? Icons.warning : Icons.vaccines,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: AppSizes.spaceM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vaccine['vaccine_name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (!isExpanded)
                                      Text(
                                        'Próxima: ${DateFormat('dd/MM/yyyy').format(nextDueDate)}',
                                        style: TextStyle(
                                          color:
                                              isOverdue
                                                  ? AppColors.error
                                                  : AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              Container(
                color: AppColors.backgroundLight,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          Expanded(
                            child: Text(
                              vaccine['veterinarian_name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceM),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateInfo(
                            'Aplicada',
                            DateFormat('dd/MM/yyyy').format(administeredDate),
                            Icons.check_circle,
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceM),
                        Expanded(
                          child: _buildDateInfo(
                            'Próxima',
                            DateFormat('dd/MM/yyyy').format(nextDueDate),
                            isOverdue ? Icons.warning : Icons.schedule,
                            isOverdue ? AppColors.error : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceM),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: AppSizes.spaceS),
                              const Text(
                                'Detalles',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.spaceS),
                          Text(
                            'Fabricante: ${vaccine['manufacturer']}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Lote: ${vaccine['batch_number']}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (vaccine['notes'] != null) ...[
                            const SizedBox(height: AppSizes.spaceS),
                            Text(
                              vaccine['notes'],
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, String date, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(height: AppSizes.spaceXS),
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 16),
              const SizedBox(width: AppSizes.spaceS),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTreatmentItem(Map<String, dynamic> treatment) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.medication, color: AppColors.secondary, size: 16),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  treatment['medication'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceXS),
                Text(
                  '${treatment['dosage']} • ${treatment['frequency']}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (treatment['instructions'] != null) ...[
                  const SizedBox(height: AppSizes.spaceXS),
                  Text(
                    treatment['instructions'],
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              treatment['duration'],
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
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
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: AppColors.secondary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getAppointmentStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return AppColors.success;
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.completed:
        return AppColors.primary;
      case AppointmentStatus.cancelled:
        return AppColors.error;
      case AppointmentStatus.inProgress:
        return AppColors.accent;
      case AppointmentStatus.rescheduled:
        return AppColors.secondary;
    }
  }

  String _getAppointmentStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.pending:
        return 'Pendiente';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.inProgress:
        return 'En Progreso';
      case AppointmentStatus.rescheduled:
        return 'Reprogramada';
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}
