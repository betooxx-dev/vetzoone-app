import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterVaccinationPage extends StatefulWidget {
  const RegisterVaccinationPage({super.key});

  @override
  State<RegisterVaccinationPage> createState() =>
      _RegisterVaccinationPageState();
}

class _RegisterVaccinationPageState extends State<RegisterVaccinationPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Map<String, dynamic> patientInfo = {};

  final _vaccineTypeController = TextEditingController();
  final _vaccineNameController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime vaccinationDate = DateTime.now();

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
    // Método mantenido para compatibilidad
  }

  @override
  void dispose() {
    _animationController.dispose();
    _vaccineTypeController.dispose();
    _vaccineNameController.dispose();
    _batchNumberController.dispose();
    _manufacturerController.dispose();
    _notesController.dispose();
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
            icon: const Icon(Icons.save_outlined, color: Color(0xFF27AE60)),
            onPressed: _saveVaccination,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVaccineInfoSection(),

                        const SizedBox(height: 24),

                        _buildBatchInfoSection(),

                        const SizedBox(height: 24),

                        _buildNotesSection(),
                      ],
                    ),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
          TextFormField(
            controller: _vaccineTypeController,
            decoration: const InputDecoration(
              labelText: 'Tipo de Vacuna',
              hintText: 'Ej: Múltiple (DHPP), Antirrábica, Bordetella',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.vaccines),
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

          const SizedBox(height: 16),

          InkWell(
            onTap: () => _selectVaccinationDate(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF27AE60)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de Aplicación',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDate(vaccinationDate),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF27AE60),
                  ),
                ],
              ),
            ),
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

  Widget _buildNotesSection() {
    return _buildSection(
      'Notas Adicionales',
      Icons.note_add,
      child: TextFormField(
        controller: _notesController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText:
              'Observaciones generales, recomendaciones para el propietario, próximas vacunas pendientes...',
          border: OutlineInputBorder(),
        ),
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
                  onPressed: _isLoading ? null : _saveVaccination,
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
              Icon(icon, color: const Color(0xFF27AE60), size: 24),
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
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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

  void _selectVaccinationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: vaccinationDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != vaccinationDate) {
      setState(() {
        vaccinationDate = picked;
      });
      _updateNextDueDate();
    }
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
              '¿Estás seguro de que quieres limpiar todos los datos del formulario?',
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
      vaccinationDate = DateTime.now();
    });

    _vaccineTypeController.clear();
    _vaccineNameController.clear();
    _batchNumberController.clear();
    _manufacturerController.clear();
    _notesController.clear();

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
                  'Vacuna Registrada',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'La vacuna ha sido registrada exitosamente y estará disponible en el historial del paciente.',
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
                      _resetForm();
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
}
