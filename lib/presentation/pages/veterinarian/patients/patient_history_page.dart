import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientHistoryPage extends StatefulWidget {
  final Map<String, dynamic>? patient;
  
  const PatientHistoryPage({super.key, this.patient});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late TabController _tabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic> patient = {};
  List<Map<String, dynamic>> consultations = [];
  List<Map<String, dynamic>> vaccinations = [];
  List<Map<String, dynamic>> treatments = [];
  List<Map<String, dynamic>> attachments = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _tabController = TabController(length: 4, vsync: this);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _initializePatientData();
    _animationController.forward();
  }

  void _initializePatientData() {
    // Usar los datos pasados por parámetro o datos mock
    patient = widget.patient ?? {
      'id': '1',
      'name': 'Luna',
      'species': 'Perro',
      'breed': 'Golden Retriever',
      'age': '3 años',
      'gender': 'Hembra',
      'weight': '28.5 kg',
      'ownerName': 'María López',
      'ownerPhone': '+52 961 123 4567',
      'ownerEmail': 'maria.lopez@email.com',
      'birthDate': DateTime(2021, 3, 15),
      'registrationDate': DateTime(2021, 6, 10),
      'lastVisit': DateTime.now().subtract(const Duration(days: 15)),
      'nextAppointment': DateTime.now().add(const Duration(days: 30)),
      'status': 'Activo',
      'priority': 'Normal',
      'consultationsCount': 8,
      'profileImage': 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=400&fit=crop&crop=face',
      'medicalNotes': 'Paciente cooperativo. Historial de alergias alimentarias.',
      'conditions': ['Alergia alimentaria'],
      'allergies': ['Pollo', 'Lácteos'],
      'microchipId': '982000123456789',
    };
    
    _loadMedicalHistory();
  }

  void _loadMedicalHistory() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          // Consultas
          consultations = [
            {
              'id': '1',
              'date': DateTime.now().subtract(const Duration(days: 15)),
              'type': 'Consulta General',
              'diagnosis': 'Estado de salud excelente',
              'treatment': 'Continuar con dieta actual',
              'weight': '28.5 kg',
              'temperature': '38.2°C',
              'cost': 350.0,
              'notes': 'Paciente en excelente estado general.',
              'veterinarian': 'Dr. María González',
            },
            {
              'id': '2',
              'date': DateTime.now().subtract(const Duration(days: 45)),
              'type': 'Vacunación',
              'diagnosis': 'Aplicación de refuerzo anual',
              'treatment': 'Vacuna polivalente',
              'weight': '27.8 kg',
              'temperature': '37.9°C',
              'cost': 280.0,
              'notes': 'Vacunación completada sin reacciones adversas.',
              'veterinarian': 'Dr. María González',
            },
            {
              'id': '3',
              'date': DateTime.now().subtract(const Duration(days: 90)),
              'type': 'Emergencia',
              'diagnosis': 'Reacción alérgica alimentaria',
              'treatment': 'Antihistamínicos y dieta especial',
              'weight': '27.2 kg',
              'temperature': '38.8°C',
              'cost': 520.0,
              'notes': 'Reacción severa a nueva comida. Se estableció dieta hipoalergénica.',
              'veterinarian': 'Dr. Carlos López',
            },
          ];
          
          // Vacunas
          vaccinations = [
            {
              'id': '1',
              'name': 'Vacuna Polivalente',
              'date': DateTime.now().subtract(const Duration(days: 45)),
              'nextDate': DateTime.now().add(const Duration(days: 320)),
              'batch': 'VB2024-007',
              'status': 'Aplicada',
              'veterinarian': 'Dr. María González',
            },
            {
              'id': '2',
              'name': 'Vacuna Antirrábica',
              'date': DateTime.now().subtract(const Duration(days: 200)),
              'nextDate': DateTime.now().add(const Duration(days: 165)),
              'batch': 'VR2024-003',
              'status': 'Aplicada',
              'veterinarian': 'Dr. María González',
            },
          ];
          
          // Tratamientos
          treatments = [
            {
              'id': '1',
              'name': 'Dieta Hipoalergénica',
              'startDate': DateTime.now().subtract(const Duration(days: 90)),
              'endDate': null,
              'status': 'Activo',
              'description': 'Alimento especial para perros con alergias alimentarias',
              'instructions': 'Únicamente este alimento, sin premios comerciales',
              'veterinarian': 'Dr. Carlos López',
            },
            {
              'id': '2',
              'name': 'Suplemento Articular',
              'startDate': DateTime.now().subtract(const Duration(days: 60)),
              'endDate': DateTime.now().add(const Duration(days: 90)),
              'status': 'Activo',
              'description': 'Glucosamina y condroitina para prevención articular',
              'instructions': '1 tableta diaria con la comida',
              'veterinarian': 'Dr. María González',
            },
          ];
          
          // Archivos adjuntos
          attachments = [
            {
              'id': '1',
              'name': 'Radiografía Torácica',
              'type': 'image',
              'date': DateTime.now().subtract(const Duration(days: 90)),
              'url': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=600&h=400',
              'description': 'Radiografía durante consulta de emergencia',
            },
            {
              'id': '2',
              'name': 'Análisis de Sangre',
              'type': 'document',
              'date': DateTime.now().subtract(const Duration(days: 45)),
              'url': 'https://example.com/lab-results.pdf',
              'description': 'Perfil bioquímico completo',
            },
          ];
          
          _isLoading = false;
        });
      }
    });
  }

  void _callOwner() {
    HapticFeedback.lightImpact();
    // Implementar llamada
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Llamando a ${patient['ownerName']}...'),
        backgroundColor: const Color(0xFF3498DB),
      ),
    );
  }

  void _messageOwner() {
    HapticFeedback.lightImpact();
    // Implementar mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo chat con ${patient['ownerName']}...'),
        backgroundColor: const Color(0xFF27AE60),
      ),
    );
  }

  void _scheduleAppointment() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/schedule-appointment');
  }

  void _addMedicalRecord() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/create-medical-record');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'completado':
        return Colors.blue;
      case 'suspendido':
        return Colors.red;
      case 'aplicada':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBar(),
                _buildPatientHeader(),
              ];
            },
            body: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildTabBarView(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMedicalRecord,
        backgroundColor: const Color(0xFF3498DB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo Registro',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        patient['name'] ?? 'Paciente',
        style: const TextStyle(
          color: Color(0xFF2C3E50),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Color(0xFF3498DB)),
          onPressed: _callOwner,
        ),
        IconButton(
          icon: const Icon(Icons.message, color: Color(0xFF27AE60)),
          onPressed: _messageOwner,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF2C3E50)),
          onPressed: () {
            _showMoreOptions();
          },
        ),
      ],
    );
  }

  Widget _buildPatientHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Foto y datos principales
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: _getStatusColor(patient['status']),
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(37),
                    child: Image.network(
                      patient['profileImage'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF0F0F0),
                          child: const Icon(
                            Icons.pets,
                            color: Color(0xFF7F8C8D),
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patient['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(patient['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              patient['status'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(patient['status']),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${patient['breed']} • ${patient['age']} • ${patient['gender']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dueño: ${patient['ownerName']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF95A5A6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información básica
            Row(
              children: [
                _buildInfoCard('Peso', patient['weight'], Icons.scale),
                _buildInfoCard('Consultas', '${patient['consultationsCount']}', Icons.medical_services),
                _buildInfoCard('Edad', patient['age'], Icons.cake),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF3498DB), size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF3498DB),
        labelColor: const Color(0xFF3498DB),
        unselectedLabelColor: const Color(0xFF7F8C8D),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Consultas'),
          Tab(text: 'Vacunas'),
          Tab(text: 'Tratamientos'),
          Tab(text: 'Archivos'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildConsultationsTab(),
        _buildVaccinationsTab(),
        _buildTreatmentsTab(),
        _buildAttachmentsTab(),
      ],
    );
  }

  Widget _buildConsultationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: consultations.length,
      itemBuilder: (context, index) {
        final consultation = consultations[index];
        return _buildConsultationCard(consultation);
      },
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> consultation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  consultation['type'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3498DB),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(consultation['date']),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            consultation['diagnosis'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            consultation['notes'],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildConsultationDetail('Peso', consultation['weight']),
              _buildConsultationDetail('Temp.', consultation['temperature']),
              _buildConsultationDetail('Costo', '\$${consultation['cost']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF95A5A6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = vaccinations[index];
        return _buildVaccinationCard(vaccination);
      },
    );
  }

  Widget _buildVaccinationCard(Map<String, dynamic> vaccination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                Icons.vaccines,
                color: _getStatusColor(vaccination['status']),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vaccination['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(vaccination['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  vaccination['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(vaccination['status']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildVaccineDetail('Aplicada', _formatDate(vaccination['date'])),
              _buildVaccineDetail('Próxima', _formatDate(vaccination['nextDate'])),
              _buildVaccineDetail('Lote', vaccination['batch']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF95A5A6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: treatments.length,
      itemBuilder: (context, index) {
        final treatment = treatments[index];
        return _buildTreatmentCard(treatment);
      },
    );
  }

  Widget _buildTreatmentCard(Map<String, dynamic> treatment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                Icons.medication,
                color: _getStatusColor(treatment['status']),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  treatment['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(treatment['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  treatment['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(treatment['status']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            treatment['description'],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            treatment['instructions'],
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF95A5A6),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTreatmentDetail('Inicio', _formatDate(treatment['startDate'])),
              _buildTreatmentDetail(
                'Fin',
                treatment['endDate'] != null
                    ? _formatDate(treatment['endDate'])
                    : 'Indefinido',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF95A5A6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        final attachment = attachments[index];
        return _buildAttachmentCard(attachment);
      },
    );
  }

  Widget _buildAttachmentCard(Map<String, dynamic> attachment) {
    final isImage = attachment['type'] == 'image';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            if (isImage) {
              // Abrir visor de imágenes
              // ImageViewerModal.show(context, imageUrl: attachment['url']);
            } else {
              // Abrir documento
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Abriendo documento...'),
                  backgroundColor: Color(0xFF3498DB),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (isImage ? Colors.blue : Colors.green).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isImage ? Icons.image : Icons.description,
                    color: isImage ? Colors.blue : Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attachment['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(attachment['date']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF95A5A6),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF95A5A6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF3498DB)),
                title: const Text('Agendar Cita'),
                onTap: () {
                  Navigator.pop(context);
                  _scheduleAppointment();
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_add, color: Color(0xFF27AE60)),
                title: const Text('Nuevo Registro Médico'),
                onTap: () {
                  Navigator.pop(context);
                  _addMedicalRecord();
                },
              ),
              ListTile(
                leading: const Icon(Icons.medication, color: Color(0xFF9B59B6)),
                title: const Text('Prescribir Tratamiento'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/prescribe-treatment');
                },
              ),
              ListTile(
                leading: const Icon(Icons.vaccines, color: Color(0xFFE67E22)),
                title: const Text('Registrar Vacuna'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/register-vaccination');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFF34495E)),
                title: const Text('Compartir Historial'),
                onTap: () {
                  Navigator.pop(context);
                  _shareHistory();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareHistory() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando reporte del historial médico...'),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
  }
}