import 'package:flutter/material.dart';
import '../../../../core/services/user_service.dart';

class ProfessionalProfilePage extends StatefulWidget {
  const ProfessionalProfilePage({super.key});

  @override
  State<ProfessionalProfilePage> createState() =>
      _ProfessionalProfilePageState();
}

class _ProfessionalProfilePageState extends State<ProfessionalProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  Map<String, dynamic> professionalData = {};

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserService.getCurrentUser();
    setState(() {
      professionalData = {
        'name': user['fullName'],
        'license': 'MV-12345',
        'email': user['email'],
        'phone': user['phone'],
        'address': 'Av. Central 123, Col. Centro, Tuxtla Gutiérrez, Chiapas',
        'experience': '8',
        'bio':
            'Especialista en medicina interna veterinaria con más de 8 años de experiencia. Dedicada al bienestar animal y la atención integral de mascotas.',
        'specialties': [
          'Medicina General',
          'Cirugía Menor',
          'Dermatología Veterinaria',
          'Medicina Preventiva',
        ],
        'services': [
          'Consulta General',
          'Vacunación',
          'Desparasitación',
          'Cirugía Menor',
          'Análisis Clínicos',
          'Radiografías',
        ],
        'profileImage': user['profilePhoto'],
      };
    });
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = professionalData['name'] ?? '';
    _phoneController.text = professionalData['phone'] ?? '';
    _addressController.text = professionalData['address'] ?? '';
    _experienceController.text = professionalData['experience'] ?? '';
    _bioController.text = professionalData['bio'] ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (professionalData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Perfil Profesional',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit,
                color: const Color(0xFF0D9488),
              ),
              onPressed: _isEditing ? _saveProfile : _toggleEditing,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF0D9488),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF0D9488),
            tabs: const [
              Tab(text: 'Información'),
              Tab(text: 'Especialidades'),
              Tab(text: 'Servicios'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfessionalInfoTab(),
            _buildSpecialtiesTab(),
            _buildServicesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'Información Profesional',
            children: [
              _buildInfoField(
                icon: Icons.person_outline,
                label: 'Nombre completo',
                controller: _nameController,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                icon: Icons.badge_outlined,
                label: 'Cédula profesional',
                value: professionalData['license'],
                enabled: false,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                icon: Icons.email_outlined,
                label: 'Correo electrónico',
                value: professionalData['email'],
                enabled: false,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                controller: _phoneController,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                icon: Icons.location_on_outlined,
                label: 'Dirección de consulta',
                controller: _addressController,
                enabled: _isEditing,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                icon: Icons.work_outline,
                label: 'Años de experiencia',
                controller: _experienceController,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'Biografía Profesional',
            children: [
              _buildInfoField(
                icon: Icons.description_outlined,
                label: 'Descripción',
                controller: _bioController,
                enabled: _isEditing,
                maxLines: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoCard(
            title: 'Especialidades',
            children: [
              for (final specialty in professionalData['specialties'] ?? [])
                _buildSpecialtyItem(specialty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoCard(
            title: 'Servicios Ofrecidos',
            children: [
              for (final service in professionalData['services'] ?? [])
                _buildServiceItem(service),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0D9488),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          (professionalData['profileImage'] != null &&
                                  professionalData['profileImage'].isNotEmpty)
                              ? Image.network(
                                professionalData['profileImage'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(
                                      0xFF0D9488,
                                    ).withOpacity(0.1),
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Color(0xFF0D9488),
                                    ),
                                  );
                                },
                              )
                              : Container(
                                color: const Color(0xFF0D9488).withOpacity(0.1),
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Color(0xFF0D9488),
                                ),
                              ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _changeProfileImage,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D9488),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professionalData['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cédula: ${professionalData['license']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Verificado',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    TextEditingController? controller,
    String? value,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (controller != null)
          TextFormField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.white : const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0D9488)),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              value ?? '',
              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ),
      ],
    );
  }

  Widget _buildSpecialtyItem(String specialty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: const Color(0xFF0D9488), size: 20),
          const SizedBox(width: 12),
          Text(
            specialty,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String service) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medical_services,
            color: const Color(0xFF3B82F6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            service,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    setState(() {
      professionalData['name'] = _nameController.text;
      professionalData['phone'] = _phoneController.text;
      professionalData['address'] = _addressController.text;
      professionalData['experience'] = _experienceController.text;
      professionalData['bio'] = _bioController.text;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente'),
        backgroundColor: Color(0xFF0D9488),
      ),
    );
  }

  void _changeProfileImage() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Tomar foto'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Seleccionar de galería'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
