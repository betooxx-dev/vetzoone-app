import 'package:flutter/material.dart';

class EditPetPage extends StatefulWidget {
  final Map<String, dynamic>? petData;

  const EditPetPage({super.key, this.petData});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSpecies;
  String? _selectedGender;
  DateTime? _selectedBirthDate;

  final List<String> _species = [
    'Perro',
    'Gato',
    'Ave',
    'Pez',
    'Reptil',
    'Hamster',
    'Conejo',
    'Otro',
  ];

  final List<String> _genders = ['Macho', 'Hembra'];

  late Map<String, dynamic> petData;

  @override
  void initState() {
    super.initState();
    _initializePetData();
  }

  void _initializePetData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        setState(() {
          petData = arguments;
          _populateFields();
        });
      } else if (widget.petData != null) {
        setState(() {
          petData = widget.petData!;
          _populateFields();
        });
      }
    });
  }

  void _populateFields() {
    _nameController.text = petData['name'] ?? '';
    _breedController.text = petData['breed'] ?? '';
    _weightController.text =
        petData['weight']?.toString().replaceAll(' kg', '') ?? '';
    _colorController.text = petData['color'] ?? '';
    _notesController.text = petData['notes'] ?? '';
    _selectedSpecies = petData['species'];
    _selectedGender = petData['gender'];

    if (petData['birthDate'] != null) {
      try {
        _selectedBirthDate = DateTime.parse(petData['birthDate']);
      } catch (e) {
        _selectedBirthDate = null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Editar Mascota',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF212121)),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [_buildHeader(), const SizedBox(height: 32), _buildForm()],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: Color(0xFF4CAF50),
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar Mascota',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              Text(
                'Actualiza la información de tu mascota',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          _buildPhysicalInfoSection(),
          const SizedBox(height: 24),
          _buildAdditionalInfoSection(),
          const SizedBox(height: 40),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Básica',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'Nombre',
          hint: 'Ej: Max, Luna, Rocky',
          icon: Icons.pets_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el nombre';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildSpeciesDropdown(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _breedController,
          label: 'Raza',
          hint: 'Ej: Labrador, Persa, Mestizo',
          icon: Icons.category_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa la raza';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildGenderDropdown(),
      ],
    );
  }

  Widget _buildPhysicalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Física',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        _buildBirthDateField(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _weightController,
          label: 'Peso (kg)',
          hint: 'Ej: 15.5',
          icon: Icons.monitor_weight_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _colorController,
          label: 'Color',
          hint: 'Ej: Dorado, Negro, Blanco con manchas',
          icon: Icons.palette_outlined,
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Adicional',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _notesController,
          label: 'Notas (opcional)',
          hint: 'Características especiales, comportamiento, etc.',
          icon: Icons.note_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSpeciesDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSpecies,
      decoration: InputDecoration(
        labelText: 'Especie',
        hintText: 'Selecciona la especie',
        prefixIcon: const Icon(Icons.pets_rounded, color: Color(0xFF4CAF50)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items:
          _species.map((String species) {
            return DropdownMenuItem<String>(
              value: species,
              child: Text(species),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedSpecies = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona una especie';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Género',
        hintText: 'Selecciona el género',
        prefixIcon: Icon(
          _selectedGender == 'Hembra'
              ? Icons.female
              : _selectedGender == 'Macho'
              ? Icons.male
              : Icons.pets_rounded,
          color: const Color(0xFF4CAF50),
        ),

        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items:
          _genders.map((String gender) {
            return DropdownMenuItem<String>(value: gender, child: Text(gender));
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona el género';
        }
        return null;
      },
    );
  }

  Widget _buildBirthDateField() {
    return GestureDetector(
      onTap: _selectBirthDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined, color: Color(0xFF4CAF50)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha de nacimiento',
                    style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedBirthDate != null
                        ? _formatDate(_selectedBirthDate!)
                        : 'Selecciona la fecha de nacimiento',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _selectedBirthDate != null
                              ? const Color(0xFF212121)
                              : const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF757575),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: _savePet,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Guardar Cambios',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              onSurface: Color(0xFF212121),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _savePet() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedPet = {
      ...petData,
      'name': _nameController.text.trim(),
      'species': _selectedSpecies,
      'breed': _breedController.text.trim(),
      'gender': _selectedGender,
      'weight':
          _weightController.text.isNotEmpty
              ? '${_weightController.text.trim()} kg'
              : null,
      'color': _colorController.text.trim(),
      'notes': _notesController.text.trim(),
      'birthDate': _selectedBirthDate?.toIso8601String(),
    };

    Navigator.pop(context, updatedPet);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_nameController.text} actualizado exitosamente'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
