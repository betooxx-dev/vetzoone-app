import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../blocs/pet/pet_bloc.dart';
import '../../../blocs/pet/pet_event.dart';
import '../../../blocs/pet/pet_state.dart';
import '../../../widgets/common/image_picker_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _descriptionController = TextEditingController();

  PetType _selectedType = PetType.DOG;
  PetGender _selectedGender = PetGender.MALE;
  PetStatus _selectedStatus = PetStatus.HEALTHY;
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 30));
  File? _selectedImageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFBDE3FF), Color(0xFFE8F5E8), Color(0xFFE5F3FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: BlocListener<PetBloc, PetState>(
          listener: (context, state) {
            if (state is PetLoading) {
              setState(() => _isLoading = true);
            } else {
              setState(() => _isLoading = false);
              if (state is PetOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context, true);
              } else if (state is PetError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
          child: Stack(
            children: [
              _buildDecorativeShapes(),
              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.paddingL),
                        child: Column(
                          children: [
                            _buildFormCard(),
                            const SizedBox(height: AppSizes.spaceL),
                            _buildSubmitButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeShapes() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: -80,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(75),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.spaceXL + 20,
        AppSizes.paddingL,
        AppSizes.paddingL,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agregar Mascota',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Registra una nueva mascota',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ImagePickerWidget(
                imageFile: _selectedImageFile,
                onImageSelected: (file) {
                  setState(() {
                    _selectedImageFile = file;
                  });
                },
                size: 120,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),
            _buildTextField(
              controller: _nameController,
              label: 'Nombre de la mascota',
              icon: Icons.pets,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildDropdown<PetType>(
              label: 'Tipo de mascota',
              icon: Icons.category,
              value: _selectedType,
              items:
                  PetType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getPetTypeText(type)),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildTextField(
              controller: _breedController,
              label: 'Raza',
              icon: Icons.info_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la raza';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildDropdown<PetGender>(
              label: 'Género',
              icon: Icons.male,
              value: _selectedGender,
              items:
                  PetGender.values
                      .map(
                        (gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(_getGenderText(gender)),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedGender = value!),
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildDropdown<PetStatus>(
              label: 'Estado de salud',
              icon: Icons.health_and_safety,
              value: _selectedStatus,
              items:
                  PetStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_getStatusText(status)),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
            const SizedBox(height: AppSizes.spaceL),
            _buildDateField(),
            const SizedBox(height: AppSizes.spaceL),
            _buildTextField(
              controller: _descriptionController,
              label: 'Descripción (opcional)',
              icon: Icons.description,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondary),
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondary),
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingM,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.secondary),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha de nacimiento',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          elevation: 8,
          shadowColor: AppColors.secondary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.white)
                : const Text(
                  'Agregar Mascota',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final userId = await SharedPreferencesHelper.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Usuario no encontrado'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final pet = Pet(
        id: '',
        name: _nameController.text.trim(),
        type: _selectedType,
        breed: _breedController.text.trim(),
        gender: _selectedGender,
        status: _selectedStatus,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        birthDate: _selectedDate,
        imageUrl: null,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<PetBloc>().add(
        AddPetEvent(pet: pet, imageFile: _selectedImageFile),
      );
    }
  }

  String _getPetTypeText(PetType type) {
    switch (type) {
      case PetType.DOG:
        return 'Perro';
      case PetType.CAT:
        return 'Gato';
      case PetType.BIRD:
        return 'Ave';
      case PetType.FISH:
        return 'Pez';
      case PetType.RABBIT:
        return 'Conejo';
      case PetType.HAMSTER:
        return 'Hámster';
      case PetType.REPTILE:
        return 'Reptil';
      case PetType.OTHER:
        return 'Otro';
    }
  }

  String _getGenderText(PetGender gender) {
    switch (gender) {
      case PetGender.MALE:
        return 'Macho';
      case PetGender.FEMALE:
        return 'Hembra';
      case PetGender.UNKNOWN:
        return 'Desconocido';
    }
  }

  String _getStatusText(PetStatus status) {
    switch (status) {
      case PetStatus.HEALTHY:
        return 'Saludable';
      case PetStatus.TREATMENT:
        return 'En tratamiento';
      case PetStatus.ATTENTION:
        return 'Requiere atención';
    }
  }
}
