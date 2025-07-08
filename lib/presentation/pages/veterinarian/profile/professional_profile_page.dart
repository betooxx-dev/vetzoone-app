import 'package:flutter/material.dart';

class ProfessionalProfilePage extends StatefulWidget {
  const ProfessionalProfilePage({super.key});

  @override
  State<ProfessionalProfilePage> createState() => _ProfessionalProfilePageState();
}

class _ProfessionalProfilePageState extends State<ProfessionalProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  bool _profileVisible = true;
  
  // Controladores para campos editables
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _clinicController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _consultationFeeController = TextEditingController();

  // Datos del veterinario profesional (simulados)
  Map<String, dynamic> professionalData = {
    'name': 'Dr. Ana Martínez Gómez',
    'license': 'MVZCOL-2024-789',
    'email': 'ana.martinez@vetcare.com',
    'phone': '+52 961 234 5678',
    'clinic': 'Clínica VetSalud Tuxtla',
    'address': 'Av. Central Norte 567, Col. Centro, Tuxtla Gutiérrez',
    'specialties': ['Medicina General', 'Cirugía', 'Dermatología'],
    'experience': 5,
    'consultationFee': 400,
    'rating': 4.8,
    'totalPatients': 234,
    'totalConsultations': 567,
    'description': 'Veterinaria especializada en medicina general y cirugía con más de 5 años de experiencia. Comprometida con brindar atención de calidad y trato empático a cada paciente.',
    'services': [
      'Consulta general',
      'Vacunación',
      'Desparasitación',
      'Cirugía menor',
      'Diagnóstico por imagen',
      'Análisis clínicos'
    ],
    'workingHours': {
      'monday': {'start': '08:00', 'end': '18:00', 'enabled': true},
      'tuesday': {'start': '08:00', 'end': '18:00', 'enabled': true},
      'wednesday': {'start': '08:00', 'end': '18:00', 'enabled': true},
      'thursday': {'start': '08:00', 'end': '18:00', 'enabled': true},
      'friday': {'start': '08:00', 'end': '18:00', 'enabled': true},
      'saturday': {'start': '09:00', 'end': '14:00', 'enabled': true},
      'sunday': {'start': '10:00', 'end': '13:00', 'enabled': false},
    },
    'profileImage': 'https://via.placeholder.com/120',
    'registrationDate': '10 de Enero, 2024',
    'verified': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfessionalData();
  }

  void _loadProfessionalData() {
    _nameController.text = professionalData['name'];
    _phoneController.text = professionalData['phone'];
    _clinicController.text = professionalData['clinic'];
    _addressController.text = professionalData['address'];
    _descriptionController.text = professionalData['description'];
    _consultationFeeController.text = professionalData['consultationFee'].toString();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _clinicController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _consultationFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: Column(
        children: [
          // Header con información básica
          _buildProfileHeader(),
          
          // TabBar
          _buildTabBar(),
          
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfessionalInfoTab(),
                _buildServicesTab(),
                _buildScheduleTab(),
                _buildSettingsTab(),
              ],
            ),
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
              // Foto de perfil
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0D9488), width: 3),
                    ),
                    child: ClipOval(
                      child: professionalData['profileImage'] != null
                          ? Image.network(
                              professionalData['profileImage'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar();
                              },
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                  if (professionalData['verified'])
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Información básica
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            professionalData['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        Switch(
                          value: _profileVisible,
                          onChanged: (value) {
                            setState(() {
                              _profileVisible = value;
                            });
                          },
                          activeColor: const Color(0xFF0D9488),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Céd. ${professionalData['license']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${professionalData['rating']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${professionalData['experience']} años exp.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_outline,
                  count: professionalData['totalPatients'].toString(),
                  label: 'Pacientes',
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.medical_services_outlined,
                  count: professionalData['totalConsultations'].toString(),
                  label: 'Consultas',
                  color: const Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.attach_money,
                  count: '\$${professionalData['consultationFee']}',
                  label: 'Consulta',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F9FF),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 40,
        color: Color(0xFF0D9488),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF0D9488),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFF0D9488),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Información'),
          Tab(text: 'Servicios'),
          Tab(text: 'Horarios'),
          Tab(text: 'Configuración'),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Información profesional
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
            ],
          ),
          const SizedBox(height: 20),
          
          // Información de la clínica
          _buildInfoCard(
            title: 'Información de la Clínica',
            children: [
              _buildInfoField(
                icon: Icons.local_hospital_outlined,
                label: 'Nombre de la clínica',
                controller: _clinicController,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                icon: Icons.location_on_outlined,
                label: 'Dirección',
                controller: _addressController,
                enabled: _isEditing,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                icon: Icons.attach_money,
                label: 'Tarifa de consulta (\$)',
                controller: _consultationFeeController,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Especialidades
          _buildSpecialtiesCard(),
          const SizedBox(height: 20),
          
          // Descripción profesional
          _buildInfoCard(
            title: 'Descripción Profesional',
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _isEditing ? const Color(0xFFF9FAFB) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isEditing ? const Color(0xFFD1D5DB) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: TextField(
                  controller: _descriptionController,
                  enabled: _isEditing,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isEditing ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Describe tu experiencia y especialidades...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
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
              ...professionalData['services'].map<Widget>((service) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D9488),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          service,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (_isEditing)
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() {
                              professionalData['services'].remove(service);
                            });
                          },
                        ),
                    ],
                  ),
                );
              }).toList(),
              if (_isEditing)
                TextButton.icon(
                  onPressed: _addService,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar servicio'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    final days = [
      {'key': 'monday', 'label': 'Lunes'},
      {'key': 'tuesday', 'label': 'Martes'},
      {'key': 'wednesday', 'label': 'Miércoles'},
      {'key': 'thursday', 'label': 'Jueves'},
      {'key': 'friday', 'label': 'Viernes'},
      {'key': 'saturday', 'label': 'Sábado'},
      {'key': 'sunday', 'label': 'Domingo'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoCard(
            title: 'Horarios de Atención',
            children: [
              ...days.map((day) {
                final dayData = professionalData['workingHours'][day['key']];
                return _buildScheduleDay(
                  day['label']!,
                  dayData,
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleDay(String dayName, Map<String, dynamic> dayData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              dayName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: dayData['enabled'],
            onChanged: _isEditing ? (value) {
              setState(() {
                dayData['enabled'] = value;
              });
            } : null,
            activeColor: const Color(0xFF0D9488),
          ),
          const SizedBox(width: 16),
          if (dayData['enabled'])
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${dayData['start']} - ${dayData['end']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  if (_isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: () => _editSchedule(dayName, dayData),
                    ),
                ],
              ),
            )
          else
            const Expanded(
              child: Text(
                'Cerrado',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoCard(
            title: 'Visibilidad del Perfil',
            children: [
              Row(
                children: [
                  Icon(
                    _profileVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF0D9488),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Perfil visible',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _profileVisible 
                              ? 'Tu perfil es visible para los usuarios'
                              : 'Tu perfil está oculto',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _profileVisible,
                    onChanged: (value) {
                      setState(() {
                        _profileVisible = value;
                      });
                    },
                    activeColor: const Color(0xFF0D9488),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildInfoCard(
            title: 'Opciones',
            children: [
              _buildOptionItem(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                subtitle: 'Configurar alertas y recordatorios',
                onTap: () {},
              ),
              _buildDivider(),
              _buildOptionItem(
                icon: Icons.analytics_outlined,
                title: 'Estadísticas',
                subtitle: 'Ver métricas de tu práctica',
                onTap: () {},
              ),
              _buildDivider(),
              _buildOptionItem(
                icon: Icons.security_outlined,
                title: 'Cambiar Contraseña',
                subtitle: 'Actualizar credenciales',
                onTap: _showChangePasswordDialog,
              ),
              _buildDivider(),
              _buildOptionItem(
                icon: Icons.help_outline,
                title: 'Ayuda y Soporte',
                subtitle: 'Obtener asistencia',
                onTap: () {},
              ),
              _buildDivider(),
              _buildOptionItem(
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                subtitle: 'Salir de la aplicación',
                onTap: _showLogoutDialog,
                isDestructive: true,
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
    required bool enabled,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFF9FAFB) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? const Color(0xFFD1D5DB) : const Color(0xFFE5E7EB),
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14,
              color: enabled ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: enabled ? const Color(0xFF0D9488) : const Color(0xFF9CA3AF),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtiesCard() {
    return _buildInfoCard(
      title: 'Especialidades',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: professionalData['specialties'].map<Widget>((specialty) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0D9488).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    specialty,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          professionalData['specialties'].remove(specialty);
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
        if (_isEditing) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _addSpecialty,
            icon: const Icon(Icons.add),
            label: const Text('Agregar especialidad'),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive 
                    ? const Color(0xFFEF4444).withOpacity(0.1)
                    : const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive 
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF0D9488),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDestructive 
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFE5E7EB),
      margin: const EdgeInsets.symmetric(vertical: 8),
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
      professionalData['clinic'] = _clinicController.text;
      professionalData['address'] = _addressController.text;
      professionalData['description'] = _descriptionController.text;
      professionalData['consultationFee'] = int.tryParse(_consultationFeeController.text) ?? 0;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil profesional actualizado'),
        backgroundColor: Color(0xFF0D9488),
      ),
    );
  }

  void _addSpecialty() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Agregar Especialidad'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Especialidad',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    professionalData['specialties'].add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _addService() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Agregar Servicio'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Servicio',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    professionalData['services'].add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _editSchedule(String dayName, Map<String, dynamic> dayData) {
    // Implementar editor de horarios
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Horario - $dayName'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Funcionalidad de edición de horarios'),
            Text('Por implementar'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                border: OutlineInputBorder(),
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
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}