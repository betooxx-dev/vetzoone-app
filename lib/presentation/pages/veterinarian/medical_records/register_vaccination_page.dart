import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

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

  final _vaccineNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime administeredDate = DateTime.now();
  DateTime nextDueDate = DateTime.now().add(const Duration(days: 365));

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
        'lastVaccination': '15 Oct 2023',
      };
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _vaccineNameController.dispose();
    _manufacturerController.dispose();
    _batchNumberController.dispose();
    _notesController.dispose();
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
                    Expanded(child: _buildFormContent()),
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
              'Registrar Vacuna',
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
              icon: const Icon(Icons.vaccines, color: AppColors.white),
              onPressed: _saveVaccination,
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
            child: const Icon(Icons.vaccines, color: AppColors.white, size: 30),
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
                  'Dueño: ${patientInfo['ownerName']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Aplicación',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '${administeredDate.day}/${administeredDate.month}/${administeredDate.year}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormSection(
              'Información de la Vacuna',
              Icons.vaccines,
              child: Column(
                children: [
                  TextFormField(
                    controller: _vaccineNameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _buildInputDecoration(
                      'Nombre de la vacuna',
                      'Ej: Triple Viral Canina, Antirrábica, Parvovirus...',
                      Icons.medical_information,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  TextFormField(
                    controller: _manufacturerController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _buildInputDecoration(
                      'Laboratorio/Fabricante',
                      'Ej: Pfizer, Merck, Zoetis, Boehringer...',
                      Icons.business,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  TextFormField(
                    controller: _batchNumberController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _buildInputDecoration(
                      'Número de Lote',
                      'Ej: TV2024-001, VX2024-123...',
                      Icons.confirmation_number,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildFormSection(
              'Fechas de Aplicación',
              Icons.calendar_today,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _selectAdministeredDate(),
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
                          Icon(Icons.event, color: AppColors.primary),
                          const SizedBox(width: AppSizes.spaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fecha de Aplicación',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${administeredDate.day}/${administeredDate.month}/${administeredDate.year}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  InkWell(
                    onTap: () => _selectNextDueDate(),
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
                          Icon(Icons.schedule, color: AppColors.primary),
                          const SizedBox(width: AppSizes.spaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Próxima Dosis (Vencimiento)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${nextDueDate.day}/${nextDueDate.month}/${nextDueDate.year}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildFormSection(
              'Notas Adicionales',
              Icons.note,
              child: TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _buildInputDecoration(
                  'Observaciones',
                  'Aplicada en el muslo derecho, reacciones observadas, próximas vacunas...',
                  null,
                ),
              ),
            ),
          ],
        ),
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
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSizes.spaceS),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    String hint,
    IconData? icon,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
      labelStyle: TextStyle(color: AppColors.textSecondary),
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
                onPressed: _isLoading ? null : _saveVaccination,
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
                        : const Icon(Icons.vaccines),
                label: Text(_isLoading ? 'Guardando...' : 'Registrar Vacuna'),
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

  void _selectAdministeredDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: administeredDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != administeredDate) {
      setState(() {
        administeredDate = picked;
        nextDueDate = picked.add(const Duration(days: 365));
      });
    }
  }

  void _selectNextDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: nextDueDate,
      firstDate: administeredDate,
      lastDate: administeredDate.add(const Duration(days: 1095)),
    );

    if (picked != null && picked != nextDueDate) {
      setState(() {
        nextDueDate = picked;
      });
    }
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
              '¿Estás seguro de que quieres limpiar todos los datos del formulario?',
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
                  _resetForm();
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

  void _resetForm() {
    setState(() {
      administeredDate = DateTime.now();
      nextDueDate = DateTime.now().add(const Duration(days: 365));
    });

    _vaccineNameController.clear();
    _manufacturerController.clear();
    _batchNumberController.clear();
    _notesController.clear();
  }

  void _saveVaccination() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor completa todos los campos obligatorios',
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

    final vaccinationData = {
      'pet_id': '82756d69-b1ea-48c8-8cb8-bb1c01047f6f',
      'vet_id': 'c608e323-3bc8-46dc-9847-a5e19bbfc0b4',
      'vaccine_name': _vaccineNameController.text.trim(),
      'manufacturer': _manufacturerController.text.trim(),
      'batch_number': _batchNumberController.text.trim(),
      'administered_date': administeredDate.toIso8601String().split('T')[0],
      'next_due_date': nextDueDate.toIso8601String().split('T')[0],
      'notes':
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
    };

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
                  '¡Vacuna Registrada!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceS),
                Text(
                  'La vacuna ha sido registrada exitosamente y estará disponible en el historial del paciente.',
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
                            _resetForm();
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
                          child: const Text('Otra Vacuna'),
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
}
