import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../data/models/medical_records/vaccination_model.dart';

class EditVaccinationPage extends StatefulWidget {
  final VaccinationModel vaccination;

  const EditVaccinationPage({super.key, required this.vaccination});

  @override
  State<EditVaccinationPage> createState() => _EditVaccinationPageState();
}

class _EditVaccinationPageState extends State<EditVaccinationPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _vaccineNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime administeredDate;
  late DateTime nextDueDate;

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

    _loadVaccinationData();
    _animationController.forward();
  }

  void _loadVaccinationData() {
    _vaccineNameController.text = widget.vaccination.vaccineName;
    _manufacturerController.text = widget.vaccination.manufacturer;
    _batchNumberController.text = widget.vaccination.batchNumber;
    _notesController.text = widget.vaccination.notes ?? '';

    administeredDate = widget.vaccination.administeredDate;
    nextDueDate = widget.vaccination.nextDueDate;
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildModernAppBar(),
                      Expanded(child: _buildFormContent()),
                      _buildActionButtons(),
                    ],
                  ),
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
              'Editar Vacuna',
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
              icon: const Icon(Icons.save_rounded, color: AppColors.white),
              onPressed: _updateVaccination,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationInfo() {
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
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
            child: const Icon(
              Icons.edit_rounded,
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
                  widget.vaccination.vaccineName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Lote: ${widget.vaccination.batchNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Fabricante: ${widget.vaccination.manufacturer}',
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
                'ID',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                widget.vaccination.id.substring(0, 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVaccinationInfo(),
          const SizedBox(height: AppSizes.spaceL),
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
                      return 'El nombre de la vacuna es obligatorio';
                    }
                    if (value.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    if (value.trim().length > 100) {
                      return 'El nombre no puede exceder 100 caracteres';
                    }
                    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'El nombre no puede contener caracteres especiales';
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
                      return 'El fabricante es obligatorio';
                    }
                    if (value.trim().length < 2) {
                      return 'El fabricante debe tener al menos 2 caracteres';
                    }
                    if (value.trim().length > 100) {
                      return 'El fabricante no puede exceder 100 caracteres';
                    }
                    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'El fabricante no puede contener caracteres especiales';
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
                      return 'El número de lote es obligatorio';
                    }
                    if (value.trim().length < 3) {
                      return 'El número de lote debe tener al menos 3 caracteres';
                    }
                    if (value.trim().length > 50) {
                      return 'El número de lote no puede exceder 50 caracteres';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(value.trim())) {
                      return 'El lote solo puede contener letras, números, guiones y guiones bajos';
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
                        color:
                            nextDueDate.isBefore(administeredDate)
                                ? AppColors.error
                                : AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color:
                              nextDueDate.isBefore(administeredDate)
                                  ? AppColors.error
                                  : AppColors.primary,
                        ),
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
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      nextDueDate.isBefore(administeredDate)
                                          ? AppColors.error
                                          : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (nextDueDate.isBefore(administeredDate))
                                const Text(
                                  'La fecha de vencimiento debe ser posterior a la aplicación',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.error,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color:
                              nextDueDate.isBefore(administeredDate)
                                  ? AppColors.error
                                  : AppColors.primary,
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
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (value.trim().length < 5) {
                    return 'Las notas deben tener al menos 5 caracteres';
                  }
                  if (value.trim().length > 500) {
                    return 'Las notas no pueden exceder 500 caracteres';
                  }
                  if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Las notas no pueden contener caracteres especiales';
                  }
                }
                return null;
              },
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      errorStyle: const TextStyle(
        fontSize: 11,
        color: AppColors.error,
        height: 1.3,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingM,
      ),
    );
  }

  Widget _buildActionButtons() {
    final bool hasValidationErrors = nextDueDate.isBefore(administeredDate);

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
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cancelar'),
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
                gradient:
                    hasValidationErrors ? null : AppColors.primaryGradient,
                color:
                    hasValidationErrors
                        ? AppColors.textSecondary.withOpacity(0.3)
                        : null,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow:
                    hasValidationErrors
                        ? null
                        : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: ElevatedButton.icon(
                onPressed:
                    (_isLoading || hasValidationErrors)
                        ? null
                        : _updateVaccination,
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
                        : const Icon(Icons.save_rounded),
                label: Text(_isLoading ? 'Guardando...' : 'Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor:
                      hasValidationErrors
                          ? AppColors.textSecondary
                          : AppColors.white,
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
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != administeredDate) {
      setState(() {
        administeredDate = picked;
        if (nextDueDate.isBefore(picked)) {
          nextDueDate = picked.add(const Duration(days: 365));
        }
      });
    }
  }

  void _selectNextDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          nextDueDate.isBefore(administeredDate)
              ? administeredDate.add(const Duration(days: 365))
              : nextDueDate,
      firstDate: administeredDate,
      lastDate: administeredDate.add(const Duration(days: 1095)),
    );

    if (picked != null && picked != nextDueDate) {
      setState(() {
        nextDueDate = picked;
      });
    }
  }

  void _updateVaccination() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor completa todos los campos obligatorios correctamente',
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

    if (nextDueDate.isBefore(administeredDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha de vencimiento debe ser posterior a la fecha de aplicación',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('💉 INICIANDO ACTUALIZACIÓN DE VACUNA');

      final token = await SharedPreferencesHelper.getToken();

      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      print('🔑 Token obtenido: ${token.substring(0, 10)}...');
      print('💉 Vaccination ID: ${widget.vaccination.id}');

      final vaccinationData = {
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

      print('📋 DATOS DE VACUNA A ACTUALIZAR:');
      vaccinationData.forEach((key, value) => print('$key: $value'));

      final response = await http.patch(
        Uri.parse(ApiEndpoints.updateVaccinationUrl(widget.vaccination.id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(vaccinationData),
      );

      print('📡 RESPUESTA DEL SERVIDOR:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ VACUNA ACTUALIZADA EXITOSAMENTE');

        if (mounted) {
          setState(() => _isLoading = false);
          _showSuccessDialog();
        }
      } else {
        print('❌ ERROR EN LA RESPUESTA DEL SERVIDOR');
        throw Exception(
          'Error del servidor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ ERROR ACTUALIZANDO VACUNA: $e');

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la vacuna: ${e.toString()}'),
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
                  '¡Vacuna Actualizada!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceS),
                Text(
                  'Los cambios se han guardado exitosamente y se actualizó el historial del paciente.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceXL),
                SizedBox(
                  width: double.infinity,
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
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                      ),
                      child: const Text('Continuar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
