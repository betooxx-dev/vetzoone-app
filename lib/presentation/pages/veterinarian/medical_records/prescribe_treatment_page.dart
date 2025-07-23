import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class PrescribeTreatmentPage extends StatefulWidget {
  const PrescribeTreatmentPage({super.key});

  @override
  State<PrescribeTreatmentPage> createState() => _PrescribeTreatmentPageState();
}

class _PrescribeTreatmentPageState extends State<PrescribeTreatmentPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Map<String, dynamic> patientInfo = {};
  List<Map<String, dynamic>> prescribedMedications = [];

  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _instructionsController = TextEditingController();

  String selectedStatus = 'ACTIVE';
  int durationDays = 7;
  DateTime startDate = DateTime.now();
  String? selectedMedicalRecordId;

  final List<String> statusOptions = ['ACTIVE', 'COMPLETED', 'DISCONTINUED'];
  final List<int> durationOptions = [1, 3, 5, 7, 10, 14, 21, 30, 60, 90];

  final List<Map<String, dynamic>> medicalRecords = [
    {
      'id': '59e7514d-48ad-48cf-a1db-0aa1605f6b84',
      'date': '22/07/2025',
      'diagnosis': 'Infección respiratoria',
      'chief_complaint': 'Tos persistente y fiebre',
    },
    {
      'id': '86da60b5-3861-49fa-834c-653c39fcfcd6',
      'date': '18/07/2025',
      'diagnosis': 'Otitis crónica',
      'chief_complaint': 'Rascado excesivo de orejas',
    },
    {
      'id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
      'date': '15/07/2025',
      'diagnosis': 'Control de rutina',
      'chief_complaint': 'Revisión general',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadPatientInfo();
    _animationController.forward();
  }

  void _loadPatientInfo() {
    setState(() {
      patientInfo = {
        'petName': 'Max',
        'species': 'Perro',
        'breed': 'Labrador Retriever',
        'age': '3 años',
        'weight': '25 kg',
        'ownerName': 'Juan Pérez',
        'diagnosis': 'Infección respiratoria',
      };
    });
  }

  DateTime get endDate => startDate.add(Duration(days: durationDays));

  @override
  void dispose() {
    _animationController.dispose();
    _medicationNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _instructionsController.dispose();
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildModernAppBar(),
                    _buildPatientInfo(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.paddingL),
                        child: Column(
                          children: [
                            _buildPrescriptionForm(),
                            const SizedBox(height: AppSizes.spaceL),
                            if (prescribedMedications.isNotEmpty) ...[
                              _buildPrescribedMedicationsList(),
                              const SizedBox(height: AppSizes.spaceL),
                            ],
                          ],
                        ),
                      ),
                    ),
                    _buildActionButtons(),
                  ],
                ),
              ),
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
              'Prescribir Tratamiento',
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
              icon: const Icon(Icons.medication, color: AppColors.white),
              onPressed: _savePrescription,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
            child: const Icon(
              Icons.medication,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientInfo['petName'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${patientInfo['breed']} • ${patientInfo['age']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Diagnóstico: ${patientInfo['diagnosis']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.medication,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${prescribedMedications.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionForm() {
    return Container(
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Agregar Medicamento',
              'Completa la información del medicamento',
              Icons.add_circle,
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildFormSection(
              'Registro Médico Asociado',
              Icons.assignment,
              child: DropdownButtonFormField<String>(
                value: selectedMedicalRecordId,
                style: const TextStyle(color: AppColors.textPrimary),
                isExpanded: true,
                items:
                    medicalRecords.map<DropdownMenuItem<String>>((record) {
                      return DropdownMenuItem<String>(
                        value: record['id'],
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  record['date'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  record['diagnosis'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMedicalRecordId = value;
                  });
                },
                decoration: _buildInputDecoration(
                  'Selecciona un registro médico',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Debes seleccionar un registro médico';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Nombre del Medicamento',
              Icons.medication,
              child: TextFormField(
                controller: _medicationNameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Ej: Omeprazol, Amoxicilina, Meloxicam...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Duración (días)',
              Icons.timer,
              child: DropdownButtonFormField<int>(
                value: durationDays,
                style: const TextStyle(color: AppColors.textPrimary),
                items:
                    durationOptions.map((days) {
                      return DropdownMenuItem(
                        value: days,
                        child: Text('$days días'),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    durationDays = value!;
                  });
                },
                decoration: _buildInputDecoration(null),
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Frecuencia',
              Icons.schedule,
              child: TextFormField(
                controller: _frequencyController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Ej: Una vez al día, Cada 8 horas, Dos veces al día...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Instrucciones',
              Icons.info,
              child: TextFormField(
                controller: _instructionsController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Ej: Tomar 30 minutos antes del desayuno, Con alimento...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Estado',
              Icons.assignment_turned_in,
              child: DropdownButtonFormField<String>(
                value: selectedStatus,
                style: const TextStyle(color: AppColors.textPrimary),
                items:
                    statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusDisplayName(status)),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
                decoration: _buildInputDecoration(null),
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            _buildFormSection(
              'Fecha de Inicio',
              Icons.event,
              child: InkWell(
                onTap: () => _selectStartDate(),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSizes.spaceS),
                      Text(
                        '${startDate.day}/${startDate.month}/${startDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _addMedication,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Medicamento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescribedMedicationsList() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Medicamentos Prescritos',
            '${prescribedMedications.length} medicamento${prescribedMedications.length != 1 ? 's' : ''} agregado${prescribedMedications.length != 1 ? 's' : ''}',
            Icons.list_alt,
          ),
          const SizedBox(height: AppSizes.spaceL),
          ...prescribedMedications.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> medication = entry.value;
            return _buildMedicationItem(medication, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  medication['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(medication['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  _getStatusDisplayName(medication['status']),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(medication['status']),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _removeMedication(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceS),
          _buildMedicationInfoRow('Dosificación', medication['dosage']),
          _buildMedicationInfoRow('Frecuencia', medication['frequency']),
          _buildMedicationInfoRow(
            'Duración',
            '${medication['duration_days']} días',
          ),
          _buildMedicationInfoRow('Fecha inicio', medication['start_date']),
          _buildMedicationInfoRow('Fecha fin', medication['end_date']),
          _buildMedicationInfoRow('Instrucciones', medication['instructions']),
        ],
      ),
    );
  }

  Widget _buildMedicationInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingS),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Icon(icon, color: AppColors.white, size: 20),
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
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(
    String title,
    IconData icon, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: AppSizes.spaceXS),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceS),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration(String? hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: OutlinedButton.icon(
                onPressed: _clearForm,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: Colors.transparent),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _savePrescription,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Guardando...' : 'Guardar Prescripción',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return AppColors.success;
      case 'COMPLETED':
        return AppColors.primary;
      case 'DISCONTINUED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Activo';
      case 'COMPLETED':
        return 'Completado';
      case 'DISCONTINUED':
        return 'Descontinuado';
      default:
        return status;
    }
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  void _addMedication() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        prescribedMedications.add({
          'name': _medicationNameController.text.trim(),
          'dosage': _dosageController.text.trim(),
          'frequency': _frequencyController.text.trim(),
          'duration_days': durationDays,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'instructions': _instructionsController.text.trim(),
          'status': selectedStatus,
        });
      });

      _clearMedicationForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_medicationNameController.text} agregado a la prescripción',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
      );
    }
  }

  void _removeMedication(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            title: const Text(
              'Eliminar Medicamento',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar "${prescribedMedications[index]['name']}" de la prescripción?',
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    prescribedMedications.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Medicamento eliminado'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _clearMedicationForm() {
    _medicationNameController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _instructionsController.clear();
    setState(() {
      selectedStatus = 'ACTIVE';
      durationDays = 7;
      startDate = DateTime.now();
    });
  }

  void _clearForm() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            title: const Text(
              'Limpiar Formulario',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            content: const Text(
              '¿Estás seguro de que quieres limpiar toda la prescripción? Se perderán todos los medicamentos agregados.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    prescribedMedications.clear();
                  });
                  _clearMedicationForm();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Formulario limpiado'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                ),
                child: const Text('Limpiar'),
              ),
            ],
          ),
    );
  }

  void _savePrescription() async {
    if (prescribedMedications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Agrega al menos un medicamento antes de guardar',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final prescriptionData =
        prescribedMedications
            .map(
              (medication) => {
                'pet_id': '82756d69-b1ea-48c8-8cb8-bb1c01047f6f',
                'medical_record_id':
                    selectedMedicalRecordId ??
                    '59e7514d-48ad-48cf-a1db-0aa1605f6b84',
                'vet_id': 'c608e323-3bc8-46dc-9847-a5e19bbfc0b4',
                'medication_name': medication['name'],
                'dosage': medication['dosage'],
                'frequency': medication['frequency'],
                'duration_days': medication['duration_days'],
                'start_date': medication['start_date'],
                'end_date': medication['end_date'],
                'instructions': medication['instructions'],
                'status': medication['status'],
              },
            )
            .toList();

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceL),
                const Text(
                  '¡Prescripción Guardada!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceS),
                Text(
                  'La prescripción ha sido guardada exitosamente y estará disponible en el expediente del paciente.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceXL),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _createNewPrescription();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: Colors.transparent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                            ),
                          ),
                          child: const Text('Nueva Prescripción'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceM),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success,
                              AppColors.success.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusM,
                              ),
                            ),
                          ),
                          child: const Text('Finalizar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _createNewPrescription() {
    setState(() {
      prescribedMedications.clear();
    });
    _clearMedicationForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Listo para crear una nueva prescripción'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }
}
