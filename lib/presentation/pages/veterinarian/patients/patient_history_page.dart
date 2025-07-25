import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../data/datasources/pet/pet_remote_datasource.dart';
import '../../../../data/models/pet/pet_model.dart';
import '../../../../data/models/appointment/appointment_model.dart';
import '../../../../data/models/medical_records/medical_record_with_treatments_model.dart';
import '../../../../data/models/medical_records/vaccination_model.dart';
import '../../../../core/injection/injection.dart';

class PatientHistoryPage extends StatefulWidget {
  final PetModel? patient;

  const PatientHistoryPage({super.key, this.patient});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = true;
  PetModel? _pet;
  List<AppointmentModel> _appointments = [];
  List<MedicalRecordWithTreatmentsModel> _medicalRecords = [];
  List<VaccinationModel> _vaccinations = [];
  String? _currentVetId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    if (widget.patient == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Obtener ID del veterinario actual
      _currentVetId = await SharedPreferencesHelper.getVetId();

      final petDataSource = sl<PetRemoteDataSource>();
      final petDetails = await petDataSource.getPetCompleteById(widget.patient!.id);

      if (mounted) {
        setState(() {
          _pet = petDetails.pet;
          _appointments = petDetails.appointments;
          _medicalRecords = petDetails.medicalRecords;
          _vaccinations = petDetails.vaccinations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando datos del paciente: $e');
      if (mounted) {
        setState(() {
          _pet = widget.patient;
          _appointments = [];
          _medicalRecords = [];
          _vaccinations = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar historial: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundShapes(),
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : Column(
                    children: [
                      _buildModernAppBar(),
                      _buildPatientHeader(),
                      _buildTabBar(),
                      Expanded(child: _buildTabBarView()),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: _showAddOptionsMenu,
              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.white,
                size: 28,
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: AppSizes.spaceM),
          const Text(
            'Cargando historial del paciente...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
          Expanded(
            child: Text(
              'Historial de ${_pet?.name ?? 'Paciente'}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSizes.spaceL),
              const Text(
                'Agregar nuevo registro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.spaceL),
              _buildAddOptionTile(
                icon: Icons.note_add_rounded,
                title: 'Crear Registro Médico',
                subtitle: 'Agregar nueva consulta médica',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/create-medical-record',
                    arguments: widget.patient,
                  );
                },
              ),
              const SizedBox(height: AppSizes.spaceM),
              _buildAddOptionTile(
                icon: Icons.vaccines_rounded,
                title: 'Registrar Vacuna',
                subtitle: 'Agregar nueva vacuna aplicada',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/register-vaccination',
                    arguments: widget.patient,
                  );
                },
              ),
              const SizedBox(height: AppSizes.spaceL),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceXS),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
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
              image: _pet?.imageUrl != null && _pet!.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(_pet!.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _pet?.imageUrl == null || _pet!.imageUrl!.isEmpty
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
                  _pet?.name ?? 'Nombre no disponible',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceS),
                Text(
                  '${_getTypeText(_pet?.type)} • ${_pet?.breed ?? 'Raza'} • ${_getAge(_pet?.birthDate ?? DateTime.now())} años',
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
                        Icons.cake_rounded,
                        '${_getAge(_pet?.birthDate ?? DateTime.now())} años',
                      ),
                      const SizedBox(width: AppSizes.spaceS),
                      _buildInfoChip(
                        Icons.verified_rounded,
                        _getStatusText(_pet?.status),
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
    if (_appointments.isEmpty) {
      return _buildEmptyState('No hay citas registradas', 'Las citas aparecerán aquí cuando se registren', Icons.calendar_today_rounded);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(icon, size: 60, color: AppColors.white),
            ),
            const SizedBox(height: AppSizes.spaceL),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
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
                      appointment.status.toString().split('.').last,
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: _getStatusColor(
                        appointment.status.toString().split('.').last,
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getAppointmentStatusText(appointment.status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(appointment.status.toString().split('.').last),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              appointment.notes ?? 'Cita programada',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              _formatDate(appointment.appointmentDate),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (appointment.veterinarian != null) ...[
              const SizedBox(height: AppSizes.spaceS),
              Row(
                children: [
                  const Icon(Icons.person_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSizes.spaceXS),
                  Expanded(
                    child: Text(
                      'Dr. ${appointment.veterinarian!.user.firstName} ${appointment.veterinarian!.user.lastName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpedientesTab() {
    if (_medicalRecords.isEmpty) {
      return _buildEmptyState('No hay registros médicos', 'Los registros médicos aparecerán aquí cuando se creen', Icons.medical_services_rounded);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: _medicalRecords.length,
      itemBuilder: (context, index) {
        final medicalRecord = _medicalRecords[index];
        return _buildMedicalRecordCard(medicalRecord);
      },
    );
  }



  Widget _buildVaccinationsTab() {
    if (_vaccinations.isEmpty) {
      return _buildEmptyState('No hay vacunas registradas', 'Las vacunas aparecerán aquí cuando se registren', Icons.vaccines_rounded);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: _vaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = _vaccinations[index];
        return _buildVaccinationCard(vaccination);
      },
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

  String _getStatusText(dynamic status) {
    if (status == null) return 'Sin estado';
    return status.toString().split('.').last.toLowerCase() == 'healthy' ? 'Saludable' : 
           status.toString().split('.').last.toLowerCase() == 'sick' ? 'Enfermo' : 
           status.toString().split('.').last.toLowerCase() == 'injured' ? 'Herido' :
           status.toString();
  }

  String _getTypeText(dynamic type) {
    if (type == null) return 'Otro';
    final typeStr = type.toString().split('.').last.toLowerCase();
    return typeStr == 'dog' ? 'Perro' : 
           typeStr == 'cat' ? 'Gato' : 
           typeStr == 'bird' ? 'Ave' :
           typeStr == 'rabbit' ? 'Conejo' :
           typeStr;
  }

  int _getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  bool _canEditMedicalRecord(MedicalRecordWithTreatmentsModel record) {
    return _currentVetId != null && _currentVetId == record.vetId;
  }

  bool _canEditVaccination(VaccinationModel vaccination) {
    return _currentVetId != null && _currentVetId == vaccination.vetId;
  }

  String _getAppointmentStatusText(dynamic status) {
    final statusStr = status.toString().split('.').last.toLowerCase();
    switch (statusStr) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmada';
      case 'inprogress':
        return 'En progreso';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      case 'rescheduled':
        return 'Reprogramada';
      default:
        return 'Sin estado';
    }
  }

  Widget _buildMedicalRecordCard(MedicalRecordWithTreatmentsModel medicalRecord) {
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
                    medicalRecord.diagnosis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getMedicalRecordStatusColor(medicalRecord.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: _getMedicalRecordStatusColor(medicalRecord.status).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getMedicalRecordStatusText(medicalRecord.status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getMedicalRecordStatusColor(medicalRecord.status),
                        ),
                      ),
                    ),
                    if (_canEditMedicalRecord(medicalRecord)) ...[
                      const SizedBox(width: AppSizes.spaceS),
                      _buildRecordActionsMenu(
                        onEdit: () => _editMedicalRecord(medicalRecord),
                        onDelete: () => _deleteMedicalRecord(medicalRecord),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              medicalRecord.chiefComplaint,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (medicalRecord.notes != null && medicalRecord.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spaceS),
              Text(
                medicalRecord.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
            if (medicalRecord.treatments.isNotEmpty) ...[
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
                          Icons.medication_rounded,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: AppSizes.spaceS),
                        const Text(
                          'Tratamientos:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    ...medicalRecord.treatments.map((treatment) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.spaceXS),
                        child: Text(
                          '• ${treatment.medicationName} - ${treatment.dosage} (${treatment.frequency})',
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
            const SizedBox(height: AppSizes.spaceS),
            Text(
              _formatDate(medicalRecord.visitDate),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationCard(VaccinationModel vaccination) {
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
            color: AppColors.accent.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.accent.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: const Icon(
                    Icons.vaccines_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceM),
                Expanded(
                  child: Text(
                    vaccination.vaccineName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (_canEditVaccination(vaccination))
                  _buildRecordActionsMenu(
                    onEdit: () => _editVaccination(vaccination),
                    onDelete: () => _deleteVaccination(vaccination),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceM),
            Row(
              children: [
                Icon(Icons.business_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.spaceS),
                Text(
                  'Fabricante: ${vaccination.manufacturer}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceS),
            Row(
              children: [
                Icon(Icons.qr_code_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.spaceS),
                Text(
                  'Lote: ${vaccination.batchNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceM),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aplicada: ${_formatDate(vaccination.administeredDate)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Vence: ${_formatDate(vaccination.nextDueDate)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (vaccination.notes != null && vaccination.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spaceM),
              Text(
                vaccination.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getMedicalRecordStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'final':
        return AppColors.success;
      case 'draft':
        return AppColors.warning;
      case 'review':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getMedicalRecordStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'final':
        return 'Final';
      case 'draft':
        return 'Borrador';
      case 'review':
        return 'En revisión';
      default:
        return status;
    }
  }

  Widget _buildRecordActionsMenu({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: AppColors.textSecondary,
      ),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSizes.spaceS),
              const Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, size: 16, color: AppColors.error),
              const SizedBox(width: AppSizes.spaceS),
              const Text('Eliminar'),
            ],
          ),
        ),
      ],
    );
  }

  void _editMedicalRecord(MedicalRecordWithTreatmentsModel record) {
    // TODO: Implementar edición de registro médico
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar registro médico: ${record.id}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _deleteMedicalRecord(MedicalRecordWithTreatmentsModel record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          title: const Text('Eliminar registro médico'),
          content: const Text('¿Estás seguro de que deseas eliminar este registro médico? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implementar eliminación de registro médico
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registro médico eliminado: ${record.id}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _editVaccination(VaccinationModel vaccination) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit-vaccination',
      arguments: vaccination,
    );
    
    // Si se editó exitosamente, recargar los datos
    if (result == true) {
      _loadPatientData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vacuna actualizada exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _deleteVaccination(VaccinationModel vaccination) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
              const SizedBox(width: AppSizes.spaceS),
              const Text('Eliminar vacuna'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que deseas eliminar esta vacuna?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccination.vaccineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Lote: ${vaccination.batchNumber}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Fecha: ${vaccination.administeredDate.day}/${vaccination.administeredDate.month}/${vaccination.administeredDate.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performDeleteVaccination(vaccination);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _performDeleteVaccination(VaccinationModel vaccination) async {
    try {
      print('💉 INICIANDO ELIMINACIÓN DE VACUNA');
      
      final token = await SharedPreferencesHelper.getToken();
      
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }
      
      print('🔑 Token obtenido: ${token.substring(0, 10)}...');
      print('💉 Vaccination ID: ${vaccination.id}');

      // Mostrar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              const Text('Eliminando vacuna...'),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 30),
        ),
      );

      final response = await http.delete(
        Uri.parse(ApiEndpoints.deleteVaccinationUrl(vaccination.id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 RESPUESTA DEL SERVIDOR:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Ocultar indicador de carga
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ VACUNA ELIMINADA EXITOSAMENTE');
        
        // Recargar datos del paciente
        _loadPatientData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.white, size: 20),
                const SizedBox(width: AppSizes.spaceS),
                const Text('Vacuna eliminada exitosamente'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
        );
      } else {
        print('❌ ERROR EN LA RESPUESTA DEL SERVIDOR');
        throw Exception('Error del servidor: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR ELIMINANDO VACUNA: $e');
      
      // Ocultar indicador de carga
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: AppColors.white, size: 20),
              const SizedBox(width: AppSizes.spaceS),
              Expanded(
                child: Text('Error al eliminar la vacuna: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
