import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Información del paciente
  Map<String, dynamic> patientInfo = {};
  
  // Lista de medicamentos prescritos
  List<Map<String, dynamic>> prescribedMedications = [];

  // Controladores para el formulario actual
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _sideEffectsController = TextEditingController();
  final _notesController = TextEditingController();

  // Variables del formulario
  String selectedFrequency = 'Cada 8 horas';
  String selectedDuration = '7 días';
  String selectedMedicationType = 'Antibiótico';
  String selectedRoute = 'Oral';
  DateTime startDate = DateTime.now();
  bool withFood = false;
  bool isGeneric = false;

  final List<String> frequencies = [
    'Cada 4 horas',
    'Cada 6 horas', 
    'Cada 8 horas',
    'Cada 12 horas',
    'Cada 24 horas',
    'Dos veces al día',
    'Tres veces al día',
    'Una vez al día',
    'Según necesidad',
  ];

  final List<String> durations = [
    '3 días',
    '5 días',
    '7 días',
    '10 días',
    '14 días',
    '21 días',
    '30 días',
    'Hasta completar',
    'Uso continuo',
  ];

  final List<String> medicationTypes = [
    'Antibiótico',
    'Antiinflamatorio',
    'Analgésico',
    'Antihistamínico',
    'Corticosteroide',
    'Antiparasitario',
    'Suplemento',
    'Vitamina',
    'Probiótico',
    'Otro',
  ];

  final List<String> routes = [
    'Oral',
    'Tópica',
    'Inyectable',
    'Oftálmica',
    'Ótica',
    'Subcutánea',
    'Intramuscular',
    'Intravenosa',
  ];

  final List<Map<String, dynamic>> commonMedications = [
    {
      'name': 'Amoxicilina',
      'type': 'Antibiótico',
      'dosage': '250mg',
      'route': 'Oral',
      'frequency': 'Cada 8 horas',
      'duration': '7 días',
      'withFood': true,
    },
    {
      'name': 'Carprofeno',
      'type': 'Antiinflamatorio',
      'dosage': '75mg',
      'route': 'Oral',
      'frequency': 'Cada 12 horas',
      'duration': '5 días',
      'withFood': true,
    },
    {
      'name': 'Metronidazol',
      'type': 'Antibiótico',
      'dosage': '500mg',
      'route': 'Oral',
      'frequency': 'Cada 12 horas',
      'duration': '10 días',
      'withFood': false,
    },
    {
      'name': 'Prednisolona',
      'type': 'Corticosteroide',
      'dosage': '10mg',
      'route': 'Oral',
      'frequency': 'Cada 24 horas',
      'duration': '14 días',
      'withFood': true,
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
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
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

  @override
  void dispose() {
    _animationController.dispose();
    _medicationController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _sideEffectsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Prescribir Tratamiento',
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
            icon: const Icon(Icons.save_outlined, color: Color(0xFF3498DB)),
            onPressed: _savePrescription,
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
              
              // Contenido principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medicamentos comunes
                      _buildCommonMedicationsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Formulario de prescripción
                      _buildPrescriptionForm(),
                      
                      const SizedBox(height: 24),
                      
                      // Lista de medicamentos prescritos
                      if (prescribedMedications.isNotEmpty) ...[
                        _buildPrescribedMedicationsList(),
                        const SizedBox(height: 24),
                      ],
                      
                      // Notas adicionales
                      _buildAdditionalNotesSection(),
                    ],
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
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.pets,
              color: Color(0xFF3498DB),
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
                Text(
                  'Diagnóstico: ${patientInfo['diagnosis']}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF27AE60),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.medication,
                  size: 16,
                  color: Color(0xFF27AE60),
                ),
                const SizedBox(width: 4),
                Text(
                  '${prescribedMedications.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF27AE60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.medication_liquid,
              color: Color(0xFF3498DB),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Medicamentos Comunes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: commonMedications.length,
            itemBuilder: (context, index) {
              final medication = commonMedications[index];
              return _buildMedicationQuickCard(medication);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationQuickCard(Map<String, dynamic> medication) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _fillFromCommonMedication(medication),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(medication['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        medication['type'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(medication['type']),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF3498DB),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  medication['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${medication['dosage']} • ${medication['frequency']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionForm() {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.add_circle,
                  color: Color(0xFF27AE60),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Agregar Medicamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Nombre del medicamento
            TextFormField(
              controller: _medicationController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Medicamento',
                hintText: 'Ej: Amoxicilina',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Tipo y dosificación
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMedicationType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: medicationTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedMedicationType = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosificación',
                      hintText: 'Ej: 250mg',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Frecuencia y duración
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frecuencia',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    items: frequencies.map((frequency) {
                      return DropdownMenuItem(
                        value: frequency,
                        child: Text(frequency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedFrequency = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDuration,
                    decoration: const InputDecoration(
                      labelText: 'Duración',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    items: durations.map((duration) {
                      return DropdownMenuItem(
                        value: duration,
                        child: Text(duration),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedDuration = value!);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Vía de administración
            DropdownButtonFormField<String>(
              value: selectedRoute,
              decoration: const InputDecoration(
                labelText: 'Vía de Administración',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
              items: routes.map((route) {
                return DropdownMenuItem(
                  value: route,
                  child: Text(route),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedRoute = value!);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Instrucciones especiales
            TextFormField(
              controller: _instructionsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Instrucciones Especiales',
                hintText: 'Ej: Administrar con alimentos, suspender si hay vómitos...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Efectos secundarios
            TextFormField(
              controller: _sideEffectsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Efectos Secundarios Posibles',
                hintText: 'Ej: Somnolencia, pérdida de apetito...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Opciones adicionales
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text(
                      'Con alimentos',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: withFood,
                    onChanged: (value) {
                      setState(() => withFood = value!);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text(
                      'Genérico',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: isGeneric,
                    onChanged: (value) {
                      setState(() => isGeneric = value!);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Botón agregar medicamento
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addMedication,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Medicamento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.list_alt,
              color: Color(0xFF3498DB),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Medicamentos Prescritos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const Spacer(),
            Text(
              '${prescribedMedications.length} medicamento${prescribedMedications.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...prescribedMedications.asMap().entries.map((entry) {
          final index = entry.key;
          final medication = entry.value;
          return _buildPrescribedMedicationCard(medication, index);
        }).toList(),
      ],
    );
  }

  Widget _buildPrescribedMedicationCard(Map<String, dynamic> medication, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(medication['type']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              medication['type'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(medication['type']),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            medication['route'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeMedication(index),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Información de dosificación
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildMedicationInfoRow('Dosificación', medication['dosage']),
                  _buildMedicationInfoRow('Frecuencia', medication['frequency']),
                  _buildMedicationInfoRow('Duración', medication['duration']),
                  if (medication['instructions'].isNotEmpty)
                    _buildMedicationInfoRow('Instrucciones', medication['instructions']),
                  if (medication['sideEffects'].isNotEmpty)
                    _buildMedicationInfoRow('Efectos Secundarios', medication['sideEffects']),
                ],
              ),
            ),
            
            if (medication['withFood'] || medication['isGeneric']) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (medication['withFood'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restaurant, size: 12, color: Color(0xFF27AE60)),
                          SizedBox(width: 4),
                          Text(
                            'Con alimentos',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (medication['withFood'] && medication['isGeneric'])
                    const SizedBox(width: 8),
                  if (medication['isGeneric'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498DB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 12, color: Color(0xFF3498DB)),
                          SizedBox(width: 4),
                          Text(
                            'Genérico',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3498DB),
                            ),
                          ),
                        ],
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

  Widget _buildMedicationInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalNotesSection() {
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
              Icon(
                Icons.note_add,
                color: Color(0xFF3498DB),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Notas Adicionales para el Propietario',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Instrucciones generales, precauciones, cuándo contactar al veterinario...',
              border: OutlineInputBorder(),
            ),
          ),
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
              onPressed: _isLoading ? null : _savePrescription,
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
              label: Text(_isLoading ? 'Guardando...' : 'Guardar Prescripción'),
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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'antibiótico':
        return const Color(0xFFE74C3C);
      case 'antiinflamatorio':
        return const Color(0xFFF39C12);
      case 'analgésico':
        return const Color(0xFF9B59B6);
      case 'antihistamínico':
        return const Color(0xFF3498DB);
      case 'corticosteroide':
        return const Color(0xFFE67E22);
      case 'antiparasitario':
        return const Color(0xFF2ECC71);
      case 'suplemento':
        return const Color(0xFF27AE60);
      case 'vitamina':
        return const Color(0xFF16A085);
      case 'probiótico':
        return const Color(0xFF8E44AD);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  void _fillFromCommonMedication(Map<String, dynamic> medication) {
    setState(() {
      _medicationController.text = medication['name'];
      selectedMedicationType = medication['type'];
      _dosageController.text = medication['dosage'];
      selectedRoute = medication['route'];
      selectedFrequency = medication['frequency'];
      selectedDuration = medication['duration'];
      withFood = medication['withFood'] ?? false;
    });

    // Scroll al formulario
    _scrollToForm();
  }

  void _scrollToForm() {
    // En una implementación real, aquí se haría scroll al formulario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicamento cargado en el formulario'),
        backgroundColor: Color(0xFF3498DB),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addMedication() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        prescribedMedications.add({
          'name': _medicationController.text.trim(),
          'type': selectedMedicationType,
          'dosage': _dosageController.text.trim(),
          'frequency': selectedFrequency,
          'duration': selectedDuration,
          'route': selectedRoute,
          'instructions': _instructionsController.text.trim(),
          'sideEffects': _sideEffectsController.text.trim(),
          'withFood': withFood,
          'isGeneric': isGeneric,
          'startDate': startDate,
        });
      });

      // Limpiar formulario
      _clearMedicationForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_medicationController.text} agregado a la prescripción'),
          backgroundColor: const Color(0xFF27AE60),
        ),
      );
    }
  }

  void _removeMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Eliminar Medicamento',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${prescribedMedications[index]['name']}" de la prescripción?',
          style: const TextStyle(
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
              setState(() {
                prescribedMedications.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medicamento eliminado'),
                  backgroundColor: Color(0xFFE74C3C),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _clearMedicationForm() {
    _medicationController.clear();
    _dosageController.clear();
    _instructionsController.clear();
    _sideEffectsController.clear();
    setState(() {
      selectedMedicationType = 'Antibiótico';
      selectedFrequency = 'Cada 8 horas';
      selectedDuration = '7 días';
      selectedRoute = 'Oral';
      withFood = false;
      isGeneric = false;
    });
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
          '¿Estás seguro de que quieres limpiar toda la prescripción? Se perderán todos los medicamentos agregados.',
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
              setState(() {
                prescribedMedications.clear();
              });
              _clearMedicationForm();
              _notesController.clear();
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

  void _savePrescription() async {
    if (prescribedMedications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un medicamento antes de guardar'),
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
            content: Text('Error al guardar la prescripción. Inténtalo de nuevo.'),
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
                Icons.check_circle,
                color: Color(0xFF27AE60),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Prescripción Guardada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'La prescripción para ${patientInfo['petName']} ha sido guardada exitosamente con ${prescribedMedications.length} medicamento${prescribedMedications.length != 1 ? 's' : ''}.',
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
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar diálogo
                      _generatePrescription();
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimir'),
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
                  Navigator.pop(context); // Cerrar diálogo
                  _createNewPrescription();
                },
                icon: const Icon(Icons.add),
                label: const Text('Nueva Prescripción'),
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

  void _generatePrescription() {
    // En una implementación real, aquí se generaría e imprimiría la prescripción
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando prescripción para imprimir...'),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
  }

  void _createNewPrescription() {
    // Limpiar todo para nueva prescripción
    setState(() {
      prescribedMedications.clear();
    });
    _clearMedicationForm();
    _notesController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listo para crear una nueva prescripción'),
        backgroundColor: Color(0xFF27AE60),
      ),
    );
  }
}