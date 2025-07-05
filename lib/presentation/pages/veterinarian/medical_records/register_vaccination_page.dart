import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterVaccinationPage extends StatefulWidget {
  const RegisterVaccinationPage({super.key});

  @override
  State<RegisterVaccinationPage> createState() => _RegisterVaccinationPageState();
}

class _RegisterVaccinationPageState extends State<RegisterVaccinationPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Información del paciente
  Map<String, dynamic> patientInfo = {};
  
  // Controladores de texto
  final _vaccineNameController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _notesController = TextEditingController();
  final _reactionNotesController = TextEditingController();

  // Variables del formulario
  String selectedVaccineType = 'Múltiple (DHPP)';
  String selectedRoute = 'Subcutánea';
  String selectedSite = 'Región interescapular';
  DateTime vaccinationDate = DateTime.now();
  DateTime? nextDueDate;
  bool hasReaction = false;
  String reactionSeverity = 'Leve';
  bool isBooster = false;
  bool certificateIssued = true;

  final List<String> vaccineTypes = [
    'Múltiple (DHPP)',
    'Antirrábica',
    'Bordetella',
    'Parvovirus',
    'Moquillo',
    'Hepatitis',
    'Parainfluenza',
    'Leptospirosis',
    'Coronavirus',
    'Giardia',
    'Lyme',
    'Otra',
  ];

  final List<String> administrationRoutes = [
    'Subcutánea',
    'Intramuscular',
    'Intranasal',
    'Oral',
  ];

  final List<String> administrationSites = [
    'Región interescapular',
    'Músculo del muslo',
    'Región cervical lateral',
    'Abdomen lateral',
    'Fosa nasal',
  ];

  final List<String> reactionSeverities = [
    'Leve',
    'Moderada',
    'Severa',
  ];

  final Map<String, Map<String, dynamic>> vaccineProtocols = {
    'Múltiple (DHPP)': {
      'nextInterval': 365, // días
      'description': 'Vacuna contra Moquillo, Hepatitis, Parvovirus y Parainfluenza',
      'route': 'Subcutánea',
      'site': 'Región interescapular',
    },
    'Antirrábica': {
      'nextInterval': 365,
      'description': 'Vacuna contra la rabia - obligatoria',
      'route': 'Subcutánea',
      'site': 'Región interescapular',
    },
    'Bordetella': {
      'nextInterval': 180,
      'description': 'Vacuna contra la tos de las perreras',
      'route': 'Intranasal',
      'site': 'Fosa nasal',
    },
    'Parvovirus': {
      'nextInterval': 365,
      'description': 'Vacuna contra el parvovirus canino',
      'route': 'Subcutánea',
      'site': 'Región interescapular',
    },
  };

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
    _updateNextDueDate();
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
        'lastVaccination': '15 Oct 2023',
        'vaccinationHistory': [
          {'vaccine': 'Múltiple (DHPP)', 'date': '15 Oct 2023'},
          {'vaccine': 'Antirrábica', 'date': '20 Sep 2023'},
        ],
      };
    });
  }

  void _updateNextDueDate() {
    if (vaccineProtocols.containsKey(selectedVaccineType)) {
      final interval = vaccineProtocols[selectedVaccineType]!['nextInterval'] as int;
      setState(() {
        nextDueDate = vaccinationDate.add(Duration(days: interval));
      });
    }
  }

  void _updateVaccineDefaults() {
    if (vaccineProtocols.containsKey(selectedVaccineType)) {
      final protocol = vaccineProtocols[selectedVaccineType]!;
      setState(() {
        selectedRoute = protocol['route'];
        selectedSite = protocol['site'];
      });
    }
    _updateNextDueDate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _vaccineNameController.dispose();
    _batchNumberController.dispose();
    _manufacturerController.dispose();
    _notesController.dispose();
    _reactionNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Registrar Vacuna',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.vaccines, color: Color(0xFF27AE60)),
            onPressed: () => _showVaccinationHistory(),
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
              
              // Formulario principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información de la vacuna
                        _buildVaccineInfoSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Detalles de administración
                        _buildAdministrationSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Información del lote
                        _buildBatchInfoSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Programación de próxima vacuna
                        _buildSchedulingSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Reacciones adversas
                        _buildReactionsSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Notas adicionales
                        _buildNotesSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Certificación
                        _buildCertificationSection(),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Botones de acción
              _buildActionButtons(),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.vaccines,
              color: Color(0xFF27AE60),
              size: 28,
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
                  '${patientInfo['breed']} • ${patientInfo['age']} • ${patientInfo['weight']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (patientInfo['lastVaccination'] != null)
                  Text(
                    'Última vacuna: ${patientInfo['lastVaccination']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3498DB),
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
              _formatDate(vaccinationDate),
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

  Widget _buildVaccineInfoSection() {
    return _buildSection(
      'Información de la Vacuna',
      Icons.medical_information,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedVaccineType,
            decoration: const InputDecoration(
              labelText: 'Tipo de Vacuna',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.vaccines),
            ),
            items: vaccineTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedVaccineType = value!;
                _vaccineNameController.text = value;
              });
              _updateVaccineDefaults();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecciona el tipo de vacuna';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _vaccineNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre Comercial de la Vacuna',
              hintText: 'Ej: Nobivac, Vanguard, etc.',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
          ),
          
          if (vaccineProtocols.containsKey(selectedVaccineType)) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF3498DB).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF3498DB),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vaccineProtocols[selectedVaccineType]!['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3498DB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text(
                    'Es refuerzo',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: isBooster,
                  onChanged: (value) {
                    setState(() => isBooster = value!);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrationSection() {
    return _buildSection(
      'Detalles de Administración',
      Icons.medical_services,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedRoute,
                  decoration: const InputDecoration(
                    labelText: 'Vía de Administración',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.route),
                  ),
                  items: administrationRoutes.map((route) {
                    return DropdownMenuItem(
                      value: route,
                      child: Text(route),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedRoute = value!);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectVaccinationDate(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha de Aplicación',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _formatDate(vaccinationDate),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
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
          
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: selectedSite,
            decoration: const InputDecoration(
              labelText: 'Sitio de Aplicación',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.place),
            ),
            items: administrationSites.map((site) {
              return DropdownMenuItem(
                value: site,
                child: Text(site),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedSite = value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBatchInfoSection() {
    return _buildSection(
      'Información del Lote',
      Icons.qr_code,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _batchNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Lote',
                    hintText: 'Ej: VX2024-001',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _manufacturerController,
                  decoration: const InputDecoration(
                    labelText: 'Laboratorio',
                    hintText: 'Ej: Merck, Zoetis, etc.',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
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
        ],
      ),
    );
  }

  Widget _buildSchedulingSection() {
    return _buildSection(
      'Programación de Próxima Vacuna',
      Icons.schedule,
      child: Column(
        children: [
          if (nextDueDate != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF27AE60).withOpacity(0.1),
                    const Color(0xFF2ECC71).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF27AE60).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event_available,
                      color: Color(0xFF27AE60),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Próxima aplicación sugerida:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          _formatDate(nextDueDate!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                        Text(
                          '${_calculateDaysUntil(nextDueDate!)} días desde hoy',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar, color: Color(0xFF27AE60)),
                    onPressed: () => _selectNextDueDate(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _scheduleNextAppointment(),
              icon: const Icon(Icons.calendar_month),
              label: const Text('Programar Cita para Próxima Vacuna'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3498DB),
                side: const BorderSide(color: Color(0xFF3498DB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReactionsSection() {
    return _buildSection(
      'Reacciones Adversas',
      Icons.warning_amber,
      child: Column(
        children: [
          CheckboxListTile(
            title: const Text('¿Hubo alguna reacción adversa?'),
            value: hasReaction,
            onChanged: (value) {
              setState(() => hasReaction = value!);
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          
          if (hasReaction) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: reactionSeverity,
              decoration: const InputDecoration(
                labelText: 'Severidad de la Reacción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: reactionSeverities.map((severity) {
                return DropdownMenuItem(
                  value: severity,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getReactionColor(severity),
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
                setState(() => reactionSeverity = value!);
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _reactionNotesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción de la Reacción',
                hintText: 'Describe los síntomas observados, tiempo de aparición, tratamiento aplicado...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              validator: hasReaction
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Describe la reacción observada';
                      }
                      return null;
                    }
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildSection(
      'Notas Adicionales',
      Icons.note_add,
      child: TextFormField(
        controller: _notesController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Observaciones generales, recomendaciones para el propietario, próximas vacunas pendientes...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCertificationSection() {
    return _buildSection(
      'Certificación',
      Icons.verified,
      child: Column(
        children: [
          CheckboxListTile(
            title: const Text('Emitir certificado de vacunación'),
            subtitle: const Text('Se generará un certificado oficial para el propietario'),
            value: certificateIssued,
            onChanged: (value) {
              setState(() => certificateIssued = value!);
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          
          if (certificateIssued) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF3498DB),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El certificado incluirá todos los datos de la vacuna y será válido oficialmente.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, {required Widget child}) {
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
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF27AE60),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _clearForm,
              icon: const Icon(Icons.refresh),
              label: const Text('Limpiar'),
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
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveVaccination,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Guardando...' : 'Registrar Vacuna'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
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

  Color _getReactionColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'leve':
        return const Color(0xFFF39C12);
      case 'moderada':
        return const Color(0xFFE67E22);
      case 'severa':
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

  int _calculateDaysUntil(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  void _selectVaccinationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: vaccinationDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != vaccinationDate) {
      setState(() {
        vaccinationDate = picked;
      });
      _updateNextDueDate();
    }
  }

  void _selectNextDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: nextDueDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)), // 3 años
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        nextDueDate = picked;
      });
    }
  }

  void _scheduleNextAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Programar Próxima Cita',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Deseas programar una cita para la próxima vacunación de ${patientInfo['petName']}?',
              style: const TextStyle(
                color: Color(0xFF7F8C8D),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha sugerida: ${nextDueDate != null ? _formatDate(nextDueDate!) : 'No definida'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                  Text(
                    'Vacuna: $selectedVaccineType',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No ahora',
              style: TextStyle(color: Color(0xFF7F8C8D)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita programada exitosamente'),
                  backgroundColor: Color(0xFF27AE60),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Programar'),
          ),
        ],
      ),
    );
  }

  void _showVaccinationHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: Color(0xFF27AE60),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Historial de Vacunas - ${patientInfo['petName']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de vacunas
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: (patientInfo['vaccinationHistory'] as List).length,
                  itemBuilder: (context, index) {
                    final vaccination = (patientInfo['vaccinationHistory'] as List)[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.vaccines,
                              color: Color(0xFF27AE60),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vaccination['vaccine'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                Text(
                                  vaccination['date'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF27AE60),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Limpiar Formulario',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: const Text(
          '¿Estás seguro de que quieres limpiar todos los datos del formulario?',
          style: TextStyle(
            color: Color(0xFF7F8C8D),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF7F8C8D)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Formulario limpiado'),
                  backgroundColor: Color(0xFF3498DB),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF39C12),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      selectedVaccineType = 'Múltiple (DHPP)';
      selectedRoute = 'Subcutánea';
      selectedSite = 'Región interescapular';
      vaccinationDate = DateTime.now();
      nextDueDate = null;
      hasReaction = false;
      reactionSeverity = 'Leve';
      isBooster = false;
      certificateIssued = true;
    });

    _vaccineNameController.clear();
    _batchNumberController.clear();
    _manufacturerController.clear();
    _notesController.clear();
    _reactionNotesController.clear();

    _updateNextDueDate();
  }

  void _saveVaccination() async {
    if (!_formKey.currentState!.validate()) {
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
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al registrar la vacuna. Inténtalo de nuevo.'),
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
                Icons.vaccines,
                color: Color(0xFF27AE60),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Vacuna Registrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'La vacuna ${_vaccineNameController.text} ha sido registrada exitosamente para ${patientInfo['petName']}.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (nextDueDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Próxima vacuna programada:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(nextDueDate!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                if (certificateIssued) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _generateCertificate();
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Certificado'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                        side: const BorderSide(color: Color(0xFF3498DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar diálogo
                      Navigator.pop(context); // Volver a la vista anterior
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Finalizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _registerNewVaccination();
                },
                icon: const Icon(Icons.add),
                label: const Text('Registrar Otra Vacuna'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF27AE60),
                  side: const BorderSide(color: Color(0xFF27AE60)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateCertificate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando certificado de vacunación...'),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
    // En una implementación real, aquí se generaría el certificado PDF
  }

  void _registerNewVaccination() {
    _resetForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listo para registrar una nueva vacuna'),
        backgroundColor: Color(0xFF27AE60),
      ),
    );
  }
}