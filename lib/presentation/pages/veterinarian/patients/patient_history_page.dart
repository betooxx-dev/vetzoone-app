import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class PatientHistoryPage extends StatefulWidget {
  final Map<String, dynamic>? patient;

  const PatientHistoryPage({super.key, this.patient});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> consultations = [
    {
      'id': '1',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'diagnosis': 'Control de rutina',
      'veterinarian': 'Dr. María González',
      'notes': 'Mascota en excelente estado de salud.',
      'status': 'Completado',
      'cost': 350.0,
      'weight': '25 kg',
      'temperature': '38.5°C',
    },
    {
      'id': '2',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'diagnosis': 'Vacunación anual',
      'veterinarian': 'Dr. Carlos López',
      'notes': 'Aplicación de vacuna múltiple.',
      'status': 'Completado',
      'cost': 280.0,
      'weight': '24.8 kg',
      'temperature': '38.2°C',
    },
    {
      'id': '3',
      'date': DateTime.now().subtract(const Duration(days: 90)),
      'diagnosis': 'Revisión dental',
      'veterinarian': 'Dr. Ana Martín',
      'notes': 'Limpieza dental profesional. Estado dental excelente.',
      'status': 'Completado',
      'cost': 420.0,
      'weight': '24.5 kg',
      'temperature': '38.3°C',
    },
  ];

  final List<Map<String, dynamic>> treatments = [
    {
      'id': '1',
      'name': 'Tratamiento Preventivo',
      'startDate': DateTime.now().subtract(const Duration(days: 15)),
      'endDate': DateTime.now().add(const Duration(days: 15)),
      'status': 'Activo',
      'medications': [
        {
          'name': 'Desparasitante',
          'dosage': '250mg',
          'frequency': 'Cada 3 meses',
          'duration': 'Permanente',
          'instructions': 'Administrar con alimento',
        },
      ],
      'reason': 'Prevención de parásitos',
      'veterinarian': 'Dr. María González',
      'notes': 'Tratamiento preventivo según calendario.',
      'cost': 380.00,
      'progress': 'Excelente tolerancia',
    },
  ];

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
    final patient = widget.patient;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundShapes(),
          SafeArea(
            child: Column(
              children: [
                _buildModernAppBar(patient),
                _buildPatientHeader(patient),
                _buildTabBar(),
                Expanded(child: _buildTabBarView()),
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

  Widget _buildModernAppBar(Map<String, dynamic>? patient) {
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
          Expanded(
            child: Text(
              'Historial de ${patient?['name'] ?? 'Paciente'}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.white),
              onSelected: _handleMenuAction,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'create_record',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSizes.paddingS),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusS,
                              ),
                            ),
                            child: Icon(
                              Icons.note_add_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          const Text(
                            'Crear Registro Médico',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'prescribe_medication',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSizes.paddingS),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusS,
                              ),
                            ),
                            child: Icon(
                              Icons.medication_rounded,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          const Text(
                            'Prescribir Medicamentos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'register_vaccine',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSizes.paddingS),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusS,
                              ),
                            ),
                            child: Icon(
                              Icons.vaccines_rounded,
                              size: 16,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          const Text(
                            'Registrar Vacuna',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'create_record':
        Navigator.pushNamed(
          context,
          '/create-medical-record',
          arguments: widget.patient,
        );
        break;
      case 'prescribe_medication':
        Navigator.pushNamed(
          context,
          '/prescribe-treatment',
          arguments: widget.patient,
        );
        break;
      case 'register_vaccine':
        Navigator.pushNamed(
          context,
          '/register-vaccination',
          arguments: widget.patient,
        );
        break;
    }
  }

  Widget _buildPatientHeader(Map<String, dynamic>? patient) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
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
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              image:
                  patient?['profileImage'] != null
                      ? DecorationImage(
                        image: NetworkImage(patient!['profileImage']),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                patient?['profileImage'] == null
                    ? Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 40,
                        color: AppColors.white,
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient?['name'] ?? 'Nombre no disponible',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceS),
                Text(
                  '${patient?['species'] ?? 'Especie'} • ${patient?['breed'] ?? 'Raza'} • ${patient?['age'] ?? 'Edad'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceS),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoChip(
                        Icons.person_rounded,
                        patient?['ownerName'] ?? '',
                      ),
                      const SizedBox(width: AppSizes.spaceS),
                      _buildInfoChip(
                        Icons.monitor_weight_rounded,
                        patient?['weight'] ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: AppSizes.spaceXS),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          dividerColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(text: 'Consultas'),
            Tab(text: 'Expedientes'),
            Tab(text: 'Vacunas'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildConsultationsTab(),
        _buildExpedientesTab(),
        _buildVaccinationsTab(),
      ],
    );
  }

  Widget _buildConsultationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: consultations.length,
      itemBuilder: (context, index) {
        final consultation = consultations[index];
        return _buildConsultationCard(consultation);
      },
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> consultation) {
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
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      consultation['status'],
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: _getStatusColor(
                        consultation['status'],
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    consultation['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(consultation['status']),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              consultation['diagnosis'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              _formatDate(consultation['date']),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              consultation['notes'],
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.spaceM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.orangeGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.attach_money_rounded,
                        size: 14,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: AppSizes.spaceXS),
                      Text(
                        '\$${consultation['cost'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    consultation['veterinarian'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpedientesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: treatments.length,
      itemBuilder: (context, index) {
        final treatment = treatments[index];
        return _buildExpedienteCard(treatment);
      },
    );
  }

  Widget _buildExpedienteCard(Map<String, dynamic> treatment) {
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
            color: AppColors.secondary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    treatment['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTreatmentStatusColor(
                      treatment['status'],
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: _getTreatmentStatusColor(
                        treatment['status'],
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    treatment['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getTreatmentStatusColor(treatment['status']),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              treatment['reason'],
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.folder_rounded,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSizes.spaceS),
                      const Text(
                        'Expedientes Médicos:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceS),
                  ...treatment['medications'].map<Widget>((medication) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spaceXS),
                      child: Text(
                        '• ${medication['name']} - ${medication['dosage']} (${medication['frequency']})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.vaccines_rounded,
              size: 60,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSizes.spaceL),
          const Text(
            'Historial de vacunas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceS),
          const Text(
            'Próximamente disponible',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completado':
        return AppColors.success;
      case 'pendiente':
        return AppColors.warning;
      case 'cancelado':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getTreatmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return AppColors.success;
      case 'completado':
        return AppColors.primary;
      case 'pausado':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
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
}
