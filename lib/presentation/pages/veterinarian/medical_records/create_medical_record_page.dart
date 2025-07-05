import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateMedicalRecordPage extends StatefulWidget {
  const CreateMedicalRecordPage({super.key});

  @override
  State<CreateMedicalRecordPage> createState() => _CreateMedicalRecordPageState();
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

  // Controladores de texto
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

  // Variables del formulario
  Map<String, dynamic> patientInfo = {};
  String selectedSeverity = 'Leve';
  List<String> selectedSymptoms = [];
  List<String> selectedDiagnoses = [];
  List<Map<String, dynamic>> attachedFiles = [];
  DateTime consultationDate = DateTime.now();

  final List<String> severityLevels = ['Leve', 'Moderado', 'Grave', 'Crítico'];
  final List<String> commonSymptoms = [
    'Fiebre', 'Vómitos', 'Diarrea', 'Letargo', 'Pérdida de apetito',
    'Dificultad respiratoria', 'Cojera', 'Secreción ocular', 'Tos',
    'Temblores', 'Convulsiones', 'Dolor abdominal', 'Deshidratación'
  ];

  final List<String> commonDiagnoses = [
    'Gastroenteritis', 'Infección respiratoria', 'Otitis', 'Dermatitis',
    'Parasitosis', 'Traumatismo', 'Intoxicación', 'Enfermedad dental',
    'Artritis', 'Conjuntivitis', 'Cistitis', 'Obesidad'
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
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _loadPatientInfo();
    _animationController.forward();
  }

  void _loadPatientInfo() {
    // Simulación de información del paciente - en producción vendría como parámetro
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
              // Información del paciente
              _buildPatientHeader(),
              
              // Indicador de progreso
              _buildProgressIndicator(),
              
              // Contenido del formulario
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentStep = index),
                  children: [
                    _buildMotiveAndHistoryStep(),
                    _buildPhysicalExamStep(),
                    _buildDiagnosisStep(),
                    _buildTreatmentStep(),
                  ],
                ),
              ),
              
              // Botones de navegación
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF3498DB).withOpacity(0.1),
            child: const Icon(
              Icons.pets,
              color: Color(0xFF3498DB),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientInfo['petName'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  '${patientInfo['breed']} • ${patientInfo['age']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Propietario: ${patientInfo['ownerName']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatDate(consultationDate),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF27AE60),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF3498DB)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
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
                      color: isCompleted
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
            
            // Motivo principal de consulta
            _buildFormSection(
              'Motivo Principal de Consulta',
              Icons.help_outline,
              child: TextFormField(
                controller: _chiefComplaintController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe el motivo principal por el cual se trae la mascota...',
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
            
            // Síntomas observados
            _buildFormSection(
              'Síntomas Observados',
              Icons.sick,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: commonSymptoms.map((symptom) {
                  final isSelected = selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedSymptoms.add(symptom);
                        } else {
                          selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF3498DB) : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Gravedad
            _buildFormSection(
              'Nivel de Gravedad',
              Icons.warning,
              child: DropdownButtonFormField<String>(
                value: selectedSeverity,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: severityLevels.map((severity) {
                  return DropdownMenuItem(
                    value: severity,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getSeverityColor(severity),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(severity),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedSeverity = value!);
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Historia clínica relevante
            _buildFormSection(
              'Historia Clínica Relevante',
              Icons.history,
              child: TextFormField(
                controller: _historyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Antecedentes médicos, cirugías previas, medicamentos actuales...',
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
          
          // Signos vitales
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
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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
                          labelText: 'Frecuencia Cardíaca (bpm)',
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
                          labelText: 'Frecuencia Respiratoria (rpm)',
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
          
          // Examen físico detallado
          _buildFormSection(
            'Hallazgos del Examen Físico',
            Icons.search,
            child: TextFormField(
              controller: _physicalExamController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Describe los hallazgos del examen físico:\n\n• Sistema cardiovascular\n• Sistema respiratorio\n• Sistema digestivo\n• Sistema neurológico\n• Piel y mucosas\n• Otros hallazgos...',
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
          
          // Archivos adjuntos
          _buildFormSection(
            'Archivos Adjuntos',
            Icons.attach_file,
            child: Column(
              children: [
                if (attachedFiles.isNotEmpty) ...[
                  ...attachedFiles.map((file) => _buildAttachedFileItem(file)).toList(),
                  const SizedBox(height: 16),
                ],
                OutlinedButton.icon(
                  onPressed: _attachFile,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Adjuntar Foto/Documento'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3498DB),
                    side: const BorderSide(color: Color(0xFF3498DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
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
          
          // Diagnósticos comunes
          _buildFormSection(
            'Diagnósticos Probables',
            Icons.medical_information,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: commonDiagnoses.map((diagnosis) {
                final isSelected = selectedDiagnoses.contains(diagnosis);
                return FilterChip(
                  label: Text(diagnosis),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedDiagnoses.add(diagnosis);
                      } else {
                        selectedDiagnoses.remove(diagnosis);
                      }
                    });
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: const Color(0xFF27AE60).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF27AE60) : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Diagnóstico detallado
          _buildFormSection(
            'Diagnóstico Detallado',
            Icons.assignment_late,
            child: TextFormField(
              controller: _diagnosisController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe el diagnóstico detallado, diagnósticos diferenciales y justificación...',
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
          
          // Observaciones adicionales
          _buildFormSection(
            'Observaciones Adicionales',
            Icons.note,
            child: TextFormField(
              controller: _observationsController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Observaciones adicionales, recomendaciones para el propietario...',
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
            'Define el plan terapéutico y seguimiento',
            Icons.healing,
          ),
          
          const SizedBox(height: 24),
          
          // Plan de tratamiento
          _buildFormSection(
            'Plan de Tratamiento',
            Icons.medical_services,
            child: TextFormField(
              controller: _treatmentPlanController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe el plan de tratamiento:\n\n• Medicamentos prescritos\n• Procedimientos recomendados\n• Cuidados en casa\n• Restricciones de actividad\n• Próximas citas...',
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
          
          // Acciones rápidas
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
                const SizedBox(height: 12),
                _buildActionButton(
                  'Programar Seguimiento',
                  Icons.schedule,
                  () => _scheduleFollowUp(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Resumen final
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
            child: Icon(
              icon,
              color: const Color(0xFF3498DB),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(String title, IconData icon, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF3498DB),
            ),
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

  Widget _buildAttachedFileItem(Map<String, dynamic> file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            file['type'] == 'image' ? Icons.image : Icons.insert_drive_file,
            color: const Color(0xFF3498DB),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              file['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                attachedFiles.remove(file);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF3498DB),
          side: const BorderSide(color: Color(0xFF3498DB)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3498DB).withOpacity(0.1),
            const Color(0xFF2ECC71).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3498DB).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.summarize,
                color: Color(0xFF3498DB),
              ),
              SizedBox(width: 8),
              Text(
                'Resumen del Registro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Paciente', patientInfo['petName'] ?? ''),
          _buildSummaryRow('Motivo', _chiefComplaintController.text.isNotEmpty 
              ? _chiefComplaintController.text.substring(0, _chiefComplaintController.text.length > 50 ? 50 : _chiefComplaintController.text.length) + '...'
              : 'No especificado'),
          _buildSummaryRow('Gravedad', selectedSeverity),
          _buildSummaryRow('Síntomas', selectedSymptoms.isNotEmpty 
              ? selectedSymptoms.take(3).join(', ')
              : 'Ninguno seleccionado'),
          _buildSummaryRow('Diagnósticos', selectedDiagnoses.isNotEmpty 
              ? selectedDiagnoses.take(2).join(', ')
              : 'Ninguno seleccionado'),
          _buildSummaryRow('Archivos', '${attachedFiles.length} archivo${attachedFiles.length != 1 ? 's' : ''}'),
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
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(_currentStep == 3 ? Icons.save : Icons.arrow_forward),
              label: Text(_currentStep == 3 ? 'Guardar Registro' : 'Siguiente'),
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

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'leve':
        return const Color(0xFF27AE60);
      case 'moderado':
        return const Color(0xFFF39C12);
      case 'grave':
        return const Color(0xFFE67E22);
      case 'crítico':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _handleBackPress() {
    if (_currentStep > 0) {
      _previousStep();
    } else {
      _showExitConfirmation();
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

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _chiefComplaintController.text.trim().isNotEmpty;
      case 1:
        return _physicalExamController.text.trim().isNotEmpty;
      case 2:
        return _diagnosisController.text.trim().isNotEmpty;
      case 3:
        return _treatmentPlanController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  void _saveRecord() async {
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simular guardado en el backend
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Mostrar confirmación de éxito
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el registro. Inténtalo de nuevo.'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _attachFile() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Adjuntar Archivo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF3498DB)),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _simulateFileAttachment('camera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF3498DB)),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _simulateFileAttachment('gallery');
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Color(0xFF3498DB)),
              title: const Text('Documento'),
              onTap: () {
                Navigator.pop(context);
                _simulateFileAttachment('document');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _simulateFileAttachment(String source) {
    setState(() {
      attachedFiles.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': source == 'document' 
            ? 'documento_${attachedFiles.length + 1}.pdf'
            : 'foto_${attachedFiles.length + 1}.jpg',
        'type': source == 'document' ? 'document' : 'image',
        'source': source,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Archivo adjuntado desde $source'),
        backgroundColor: const Color(0xFF27AE60),
      ),
    );
  }

  void _navigateToPrescription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirigiendo a prescripción de medicamentos...'),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
    // Aquí se navegaría a la pantalla de prescripción
  }

  void _navigateToVaccination() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirigiendo a registro de vacunas...'),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
    // Aquí se navegaría a la pantalla de vacunación
  }

  void _scheduleFollowUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Programar Seguimiento',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Cuándo quieres programar la próxima cita de seguimiento?'),
            SizedBox(height: 16),
            // Aquí iría un date picker
            Text(
              'Fecha sugerida: 1 semana',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF3498DB),
              ),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita de seguimiento programada'),
                  backgroundColor: Color(0xFF27AE60),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Programar'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Salir sin Guardar',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFFE74C3C),
          ),
        ),
        content: const Text(
          '¿Estás seguro de que quieres salir? Se perderán todos los datos ingresados.',
          style: TextStyle(
            color: Color(0xFF7F8C8D),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continuar Editando',
              style: TextStyle(color: Color(0xFF3498DB)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Salir de la página
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF27AE60),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Registro Médico Guardado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'El registro médico de ${patientInfo['petName']} ha sido guardado exitosamente.',
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
                      Navigator.pop(context); // Cerrar diálogo
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
                      Navigator.pop(context); // Cerrar diálogo
                      Navigator.pop(context); // Volver a la vista anterior
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
      selectedSymptoms.clear();
      selectedDiagnoses.clear();
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