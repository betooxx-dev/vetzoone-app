import 'package:flutter/material.dart';

class PatientHistoryPage extends StatefulWidget {
  final Map<String, dynamic>? patient;

  const PatientHistoryPage({super.key, this.patient});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> consultations = [
    {
      'id': '1',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'diagnosis': 'Control de rutina',
      'veterinarian': 'Dr. María González',
      'notes': 'Mascota en excelente estado de salud.',
      'status': 'Completado',
      'cost': 350.0,
      'weight': '25 kg',
      'temperature': '38.5°C',
    },
    {
      'id': '2',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'diagnosis': 'Vacunación anual',
      'veterinarian': 'Dr. Carlos López',
      'notes': 'Aplicación de vacuna múltiple.',
      'status': 'Completado',
      'cost': 280.0,
      'weight': '24.8 kg',
      'temperature': '38.2°C',
    },
    {
      'id': '3',
      'date': DateTime.now().subtract(const Duration(days: 90)),
      'diagnosis': 'Revisión dental',
      'veterinarian': 'Dr. Ana Martín',
      'notes': 'Limpieza dental profesional. Estado dental excelente.',
      'status': 'Completado',
      'cost': 420.0,
      'weight': '24.5 kg',
      'temperature': '38.3°C',
    },
  ];

  final List<Map<String, dynamic>> treatments = [
    {
      'id': '1',
      'name': 'Tratamiento Preventivo',
      'startDate': DateTime.now().subtract(const Duration(days: 15)),
      'endDate': DateTime.now().add(const Duration(days: 15)),
      'status': 'Activo',
      'medications': [
        {
          'name': 'Desparasitante',
          'dosage': '250mg',
          'frequency': 'Cada 3 meses',
          'duration': 'Permanente',
          'instructions': 'Administrar con alimento',
        },
      ],
      'reason': 'Prevención de parásitos',
      'veterinarian': 'Dr. María González',
      'notes': 'Tratamiento preventivo según calendario.',
      'cost': 380.00,
      'progress': 'Excelente tolerancia',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Historial de ${patient?['name'] ?? 'Paciente'}',
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2C3E50)),
            onSelected: _handleMenuAction,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'create_record',
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_add_rounded,
                          size: 20,
                          color: Color(0xFF81D4FA),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Crear Registro Médico',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'prescribe_medication',
                    child: Row(
                      children: [
                        Icon(
                          Icons.medication_rounded,
                          size: 20,
                          color: Color(0xFF4CAF50),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Prescribir Medicamentos',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'register_vaccine',
                    child: Row(
                      children: [
                        Icon(
                          Icons.vaccines_rounded,
                          size: 20,
                          color: Color(0xFF9C27B0),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Registrar Vacuna',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPatientHeader(patient),
          _buildStatsSection(),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'create_record':
        Navigator.pushNamed(
          context,
          '/create-medical-record',
          arguments: widget.patient,
        );
        break;
      case 'prescribe_medication':
        Navigator.pushNamed(
          context,
          '/prescribe-treatment',
          arguments: widget.patient,
        );
        break;
      case 'register_vaccine':
        Navigator.pushNamed(
          context,
          '/register-vaccination',
          arguments: widget.patient,
        );
        break;
    }
  }

  Widget _buildPatientHeader(Map<String, dynamic>? patient) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              patient?['profileImage'] ?? 'https://via.placeholder.com/80',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.pets,
                    size: 40,
                    color: Color(0xFF3498DB),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient?['name'] ?? 'Nombre no disponible',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${patient?['species'] ?? 'Especie'} • ${patient?['breed'] ?? 'Raza'} • ${patient?['age'] ?? 'Edad'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip(Icons.person, patient?['ownerName'] ?? ''),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.monitor_weight,
                      patient?['weight'] ?? '',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3498DB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF3498DB)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF3498DB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Consultas',
              '${consultations.length}',
              Icons.medical_services,
              const Color(0xFF3498DB),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Tratamientos',
              '${treatments.length}',
              Icons.medication,
              const Color(0xFF27AE60),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Vacunas',
              '12',
              Icons.vaccines,
              const Color(0xFFE74C3C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
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
        labelColor: const Color(0xFF3498DB),
        unselectedLabelColor: const Color(0xFF7F8C8D),
        indicatorColor: const Color(0xFF3498DB),
        tabs: const [
          Tab(text: 'Consultas'),
          Tab(text: 'Tratamientos'),
          Tab(text: 'Vacunas'),
          Tab(text: 'Notas'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildConsultationsTab(),
        _buildTreatmentsTab(),
        _buildVaccinationsTab(),
        _buildNotesTab(),
      ],
    );
  }

  Widget _buildConsultationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Color(0xFF3498DB),
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    consultation['status'],
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  consultation['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(consultation['status']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            consultation['diagnosis'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(consultation['date']),
            style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
          ),
          const SizedBox(height: 8),
          Text(
            consultation['notes'],
            style: const TextStyle(fontSize: 14, color: Color(0xFF34495E)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Color(0xFF27AE60),
                  ),
                  Text(
                    '\$${consultation['cost'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                ],
              ),
              Text(
                consultation['veterinarian'],
                style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                treatment['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTreatmentStatusColor(
                    treatment['status'],
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  treatment['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getTreatmentStatusColor(treatment['status']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            treatment['reason'],
            style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
          ),
          const SizedBox(height: 12),
          Text(
            'Medicamentos:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          ...treatment['medications'].map<Widget>((medication) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${medication['name']} - ${medication['dosage']} (${medication['frequency']})',
                style: const TextStyle(fontSize: 13, color: Color(0xFF34495E)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVaccinationsTab() {
    return const Center(
      child: Text(
        'Historial de vacunas',
        style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
      ),
    );
  }

  Widget _buildNotesTab() {
    return const Center(
      child: Text(
        'Notas médicas',
        style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completado':
        return const Color(0xFF27AE60);
      case 'pendiente':
        return const Color(0xFFF39C12);
      case 'cancelado':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  Color _getTreatmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return const Color(0xFF27AE60);
      case 'completado':
        return const Color(0xFF3498DB);
      case 'pausado':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
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
}
