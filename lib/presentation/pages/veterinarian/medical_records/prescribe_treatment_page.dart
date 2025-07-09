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

  Map<String, dynamic> patientInfo = {};

  List<Map<String, dynamic>> prescribedMedications = [];

  final _medicationController = TextEditingController();
  final _typeController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _routeController = TextEditingController();
  final _sideEffectsController = TextEditingController();
  final _notesController = TextEditingController();

  String selectedDuration = '7 días';
  DateTime startDate = DateTime.now();

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

  @override
  void dispose() {
    _animationController.dispose();
    _medicationController.dispose();
    _typeController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _routeController.dispose();
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
              _buildPatientHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPrescriptionForm(),

                      const SizedBox(height: 24),

                      if (prescribedMedications.isNotEmpty) ...[
                        _buildPrescribedMedicationsList(),
                        const SizedBox(height: 24),
                      ],

                      _buildAdditionalNotesSection(),
                    ],
                  ),
                ),
              ),

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
            child: const Icon(Icons.pets, color: Color(0xFF3498DB), size: 28),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                Icon(Icons.add_circle, color: Color(0xFF27AE60), size: 24),
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

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      hintText: 'Ej: Antibiótico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
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
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _frequencyController,
              decoration: const InputDecoration(
                labelText: 'Frecuencia',
                hintText: 'Ej: Cada 8 horas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedDuration,
              decoration: const InputDecoration(
                labelText: 'Duración',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              items:
                  durations.map((duration) {
                    return DropdownMenuItem(
                      value: duration,
                      child: Text(duration),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() => selectedDuration = value!);
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _routeController,
              decoration: const InputDecoration(
                labelText: 'Vía de Administración',
                hintText: 'Ej: Oral',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

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

            const SizedBox(height: 20),

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

  Widget _buildPrescribedMedicationsList() {
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
              const Icon(Icons.list_alt, color: Color(0xFF3498DB), size: 24),
              const SizedBox(width: 8),
              Text(
                'Medicamentos Prescritos (${prescribedMedications.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
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
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE74C3C),
                ),
                onPressed: () => _removeMedication(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
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
                const SizedBox(height: 8),
                _buildMedicationInfoRow('Dosificación', medication['dosage']),
                _buildMedicationInfoRow('Frecuencia', medication['frequency']),
                _buildMedicationInfoRow('Duración', medication['duration']),
                _buildMedicationInfoRow('Vía', medication['route']),
                if (medication['sideEffects'].isNotEmpty)
                  _buildMedicationInfoRow(
                    'Efectos Secundarios',
                    medication['sideEffects'],
                  ),
              ],
            ),
          ),
        ],
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
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Color(0xFF2C3E50)),
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
              Icon(Icons.note_alt, color: Color(0xFF8E44AD), size: 24),
              SizedBox(width: 8),
              Text(
                'Notas Adicionales',
                style: TextStyle(
                  fontSize: 18,
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
              hintText: 'Agregar notas o observaciones adicionales...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit_note),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearForm,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpiar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF39C12),
                    side: const BorderSide(color: Color(0xFFF39C12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _savePrescription,
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Icon(Icons.save),
                  label: Text(
                    _isLoading ? 'Guardando...' : 'Guardar Prescripción',
                  ),
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

  void _addMedication() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        prescribedMedications.add({
          'name': _medicationController.text.trim(),
          'type': _typeController.text.trim(),
          'dosage': _dosageController.text.trim(),
          'frequency': _frequencyController.text.trim(),
          'duration': selectedDuration,
          'route': _routeController.text.trim(),
          'sideEffects': _sideEffectsController.text.trim(),
          'startDate': startDate,
        });
      });

      _clearMedicationForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_medicationController.text} agregado a la prescripción',
          ),
          backgroundColor: const Color(0xFF27AE60),
        ),
      );
    }
  }

  void _removeMedication(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
              style: const TextStyle(color: Color(0xFF7F8C8D), height: 1.4),
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
    _typeController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _routeController.clear();
    _sideEffectsController.clear();
    setState(() {
      selectedDuration = '7 días';
    });
  }

  void _clearForm() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
              style: TextStyle(color: Color(0xFF7F8C8D), height: 1.4),
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
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error al guardar la prescripción. Inténtalo de nuevo.',
            ),
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
      builder:
          (context) => AlertDialog(
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
                const SizedBox(height: 16),
                const Text(
                  'Prescripción Guardada',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'La prescripción ha sido guardada exitosamente y estará disponible en el expediente del paciente.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _generatePrescription,
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
                          Navigator.pop(context);
                          Navigator.pop(context);
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando prescripción para imprimir...'),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
  }

  void _createNewPrescription() {
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
