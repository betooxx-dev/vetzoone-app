import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateMedicalRecordPage extends StatefulWidget {
  const CreateMedicalRecordPage({super.key});

  @override
  State<CreateMedicalRecordPage> createState() =>
      _CreateMedicalRecordPageState();
}

class _CreateMedicalRecordPageState extends State<CreateMedicalRecordPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  int _currentStep = 0;
  bool _isLoading = false;

  final _chiefComplaintController = TextEditingController();
  final _historyController = TextEditingController();
  final _physicalExamController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentPlanController = TextEditingController();
  final _observationsController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _diagnosisProbableController = TextEditingController();

  Map<String, dynamic> patientInfo = {};
  String selectedSeverity = 'Leve';
  List<Map<String, dynamic>> attachedFiles = [];
  DateTime consultationDate = DateTime.now();

  final List<String> severityLevels = ['Leve', 'Moderado', 'Grave', 'Crítico'];

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
        'lastVisit': '15 Oct 2024',
      };
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _chiefComplaintController.dispose();
    _historyController.dispose();
    _physicalExamController.dispose();
    _diagnosisController.dispose();
    _treatmentPlanController.dispose();
    _observationsController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _symptomsController.dispose();
    _diagnosisProbableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Nuevo Registro Médico',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          onPressed: () => _handleBackPress(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined, color: Color(0xFF3498DB)),
            onPressed: _currentStep == 3 ? _saveRecord : null,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildPatientInfo(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged:
                      (index) => setState(() => _currentStep = index),
                  children: [
                    _buildMotiveAndHistoryStep(),
                    _buildPhysicalExamStep(),
                    _buildDiagnosisStep(),
                    _buildTreatmentStep(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.pets, color: Color(0xFF3498DB), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientInfo['petName'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  '${patientInfo['breed']} • ${patientInfo['age']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                Text(
                  'Dueño: ${patientInfo['ownerName']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF95A5A6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Consulta',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '${consultationDate.day}/${consultationDate.month}/${consultationDate.year}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3498DB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        isActive || isCompleted
                            ? const Color(0xFF3498DB)
                            : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                            : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color:
                                    isActive || isCompleted
                                        ? Colors.white
                                        : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color:
                          isCompleted
                              ? const Color(0xFF3498DB)
                              : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMotiveAndHistoryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Motivo de Consulta e Historia',
              'Registra el motivo principal y antecedentes relevantes',
              Icons.assignment,
            ),

            const SizedBox(height: 24),

            _buildFormSection(
              'Motivo Principal de Consulta',
              Icons.help_outline,
              child: TextFormField(
                controller: _chiefComplaintController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'Describe el motivo principal por el cual se trae la mascota...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 24),

            _buildFormSection(
              'Síntomas Observados',
              Icons.sick,
              child: TextFormField(
                controller: _symptomsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Describe los síntomas observados en la mascota:\n\nEjemplo: Fiebre, vómitos, diarrea, letargo, pérdida de apetito, dificultad respiratoria, cojera, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 24),

            _buildFormSection(
              'Severidad del Caso',
              Icons.priority_high,
              child: DropdownButtonFormField<String>(
                value: selectedSeverity,
                items:
                    severityLevels.map((severity) {
                      return DropdownMenuItem(
                        value: severity,
                        child: Text(severity),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSeverity = value!;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),

            const SizedBox(height: 24),

            _buildFormSection(
              'Historia Clínica Relevante',
              Icons.history,
              child: TextFormField(
                controller: _historyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Antecedentes médicos, cirugías previas, medicamentos actuales...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalExamStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Examen Físico',
            'Registra los signos vitales y hallazgos del examen',
            Icons.medical_services,
          ),

          const SizedBox(height: 24),

          _buildFormSection(
            'Signos Vitales',
            Icons.monitor_heart,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.scale),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _temperatureController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Temperatura (°C)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.thermostat),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heartRateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Frecuencia Cardíaca',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.favorite),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _respiratoryRateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Frecuencia Respiratoria',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.air),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildFormSection(
            'Hallazgos del Examen Físico',
            Icons.search,
            child: TextFormField(
              controller: _physicalExamController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText:
                    'Describe los hallazgos del examen físico:\n\n• Estado general\n• Sistema cardiovascular\n• Sistema respiratorio\n• Sistema digestivo\n• Sistema locomotor\n• Piel y faneras...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Diagnóstico',
            'Establece el diagnóstico basado en los hallazgos',
            Icons.psychology,
          ),

          const SizedBox(height: 24),

          _buildFormSection(
            'Diagnóstico Probable',
            Icons.medical_information,
            child: TextFormField(
              controller: _diagnosisProbableController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Establece el diagnóstico probable basado en los síntomas y hallazgos:\n\nEjemplo: Gastroenteritis, infección respiratoria, otitis, dermatitis, parasitosis, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          _buildFormSection(
            'Diagnóstico Detallado',
            Icons.assignment_late,
            child: TextFormField(
              controller: _diagnosisController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Describe el diagnóstico detallado, diagnósticos diferenciales y justificación...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          _buildFormSection(
            'Observaciones Adicionales',
            Icons.note,
            child: TextFormField(
              controller: _observationsController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Observaciones adicionales, recomendaciones para el propietario...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Plan de Tratamiento',
            'Define el plan terapéutico',
            Icons.healing,
          ),

          const SizedBox(height: 24),

          _buildFormSection(
            'Plan de Tratamiento',
            Icons.medical_services,
            child: TextFormField(
              controller: _treatmentPlanController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'Describe el plan de tratamiento:\n\n• Medicamentos prescritos\n• Procedimientos recomendados\n• Cuidados en casa\n• Restricciones de actividad\n• Próximas citas...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          _buildFormSection(
            'Acciones Adicionales',
            Icons.add_task,
            child: Column(
              children: [
                _buildActionButton(
                  'Prescribir Medicamentos',
                  Icons.medication,
                  () => _navigateToPrescription(),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  'Registrar Vacuna',
                  Icons.vaccines,
                  () => _navigateToVaccination(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF3498DB), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            Icon(icon, color: const Color(0xFF3498DB), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3498DB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF3498DB), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF3498DB),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.summarize, color: Color(0xFF3498DB), size: 20),
              SizedBox(width: 8),
              Text(
                'Resumen del Registro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Paciente', patientInfo['petName'] ?? ''),
          _buildSummaryRow(
            'Motivo',
            _chiefComplaintController.text.isNotEmpty
                ? _chiefComplaintController.text.substring(
                      0,
                      _chiefComplaintController.text.length > 50
                          ? 50
                          : _chiefComplaintController.text.length,
                    ) +
                    '...'
                : 'No especificado',
          ),
          _buildSummaryRow('Gravedad', selectedSeverity),
          _buildSummaryRow(
            'Síntomas',
            _symptomsController.text.isNotEmpty
                ? _symptomsController.text.substring(
                      0,
                      _symptomsController.text.length > 50
                          ? 50
                          : _symptomsController.text.length,
                    ) +
                    '...'
                : 'No especificado',
          ),
          _buildSummaryRow(
            'Diagnóstico',
            _diagnosisProbableController.text.isNotEmpty
                ? _diagnosisProbableController.text.substring(
                      0,
                      _diagnosisProbableController.text.length > 50
                          ? 50
                          : _diagnosisProbableController.text.length,
                    ) +
                    '...'
                : 'No especificado',
          ),
          _buildSummaryRow(
            'Archivos',
            '${attachedFiles.length} archivo${attachedFiles.length != 1 ? 's' : ''}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7F8C8D),
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _nextStep,
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Icon(
                        _currentStep == 3 ? Icons.save : Icons.arrow_forward,
                      ),
              label: Text(_currentStep == 3 ? 'Guardar' : 'Siguiente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _saveRecord();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _chiefComplaintController.text.trim().isNotEmpty &&
            _symptomsController.text.trim().isNotEmpty;
      case 1:
        return _physicalExamController.text.trim().isNotEmpty;
      case 2:
        return _diagnosisProbableController.text.trim().isNotEmpty &&
            _diagnosisController.text.trim().isNotEmpty;
      case 3:
        return _treatmentPlanController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  void _handleBackPress() {
    if (_currentStep > 0) {
      _previousStep();
    } else {
      Navigator.pop(context);
    }
  }

  void _saveRecord() async {
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _navigateToPrescription() {
    Navigator.pushNamed(context, '/prescribe-treatment');
  }

  void _navigateToVaccination() {
    Navigator.pushNamed(context, '/register-vaccination');
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF27AE60),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Registro Guardado!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'El registro médico ha sido guardado exitosamente. Ahora puedes prescribir medicamentos o registrar vacunas si es necesario.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _createNewRecord();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3498DB),
                          side: const BorderSide(color: Color(0xFF3498DB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Nuevo Registro'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Finalizar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _createNewRecord() {
    setState(() {
      _currentStep = 0;
      selectedSeverity = 'Leve';
      attachedFiles.clear();
      consultationDate = DateTime.now();
    });

    _chiefComplaintController.clear();
    _historyController.clear();
    _physicalExamController.clear();
    _diagnosisController.clear();
    _treatmentPlanController.clear();
    _observationsController.clear();
    _weightController.clear();
    _temperatureController.clear();
    _heartRateController.clear();
    _respiratoryRateController.clear();
    _symptomsController.clear();
    _diagnosisProbableController.clear();

    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listo para crear un nuevo registro médico'),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
  }
}
