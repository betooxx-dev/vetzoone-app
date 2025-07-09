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
      'diagnosis': 'Control rutinario - Vacunación múltiple',
      'symptoms': 'Ninguno',
      'temperature': '38.5°C',
      'weight': '15.2 kg',
      'pulse': '110 bpm',
      'notes':
          'Mascota en excelente estado de salud. Se aplicó vacuna múltiple según calendario de vacunación. Próxima cita en 3 meses para control.',
      'prescriptions': [
        'Vitaminas - 1 comprimido diario x 30 días',
        'Desparasitante - Cada 3 meses',
      ],
      'attachments': ['radiografia_torax.jpg', 'analisis_sangre.pdf'],
      'cost': 850.00,
      'status': 'Completado',
      'nextAppointment': DateTime.now().add(const Duration(days: 90)),
    },
    {
      'id': '2',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'diagnosis': 'Gastroenteritis leve',
      'symptoms': 'Vómito, diarrea, pérdida de apetito',
      'temperature': '39.2°C',
      'weight': '14.8 kg',
      'pulse': '125 bpm',
      'notes':
          'Cuadro de gastroenteritis leve debido a cambio de dieta. Respuesta favorable al tratamiento. Se recomienda dieta blanda por 5 días.',
      'prescriptions': [
        'Omeprazol - 20mg cada 12 horas x 7 días',
        'Probióticos - 1 sobre diario x 10 días',
        'Dieta blanda - Arroz con pollo x 5 días',
      ],
      'attachments': ['receta_medicamentos.pdf'],
      'cost': 650.00,
      'status': 'Completado',
      'nextAppointment': null,
    },
    {
      'id': '3',
      'date': DateTime.now().subtract(const Duration(days: 60)),
      'diagnosis': 'Limpieza dental',
      'symptoms': 'Mal aliento, sarro dental',
      'temperature': '38.0°C',
      'weight': '15.0 kg',
      'pulse': '105 bpm',
      'notes':
          'Procedimiento de limpieza dental bajo anestesia. Se removió sarro acumulado. Estado dental mejorado considerablemente.',
      'prescriptions': [
        'Antibiótico - Amoxicilina 500mg cada 8 horas x 7 días',
        'Analgésico - Meloxicam 1.5mg cada 24 horas x 3 días',
      ],
      'attachments': ['fotos_before_after.jpg'],
      'cost': 1200.00,
      'status': 'Completado',
      'nextAppointment': DateTime.now().add(const Duration(days: 365)),
    },
  ];

  final List<Map<String, dynamic>> vaccinations = [
    {
      'id': '1',
      'name': 'Vacuna Múltiple (DHPP)',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'batch': 'VM-2024-1157',
      'manufacturer': 'Zoetis',
      'veterinarian': 'Dr. María González',
      'nextDate': DateTime.now().add(const Duration(days: 365)),
      'status': 'Aplicada',
      'notes':
          'Vacuna aplicada sin complicaciones. Mascota toleró bien el procedimiento.',
      'cost': 450.00,
      'sideEffects': 'Ninguno observado',
      'location': 'Músculo cuadriceps derecho',
    },
    {
      'id': '2',
      'name': 'Antirrábica',
      'date': DateTime.now().subtract(const Duration(days: 180)),
      'batch': 'RAB-2024-0892',
      'manufacturer': 'Merck',
      'veterinarian': 'Dr. Carlos López',
      'nextDate': DateTime.now().add(const Duration(days: 185)),
      'status': 'Aplicada',
      'notes': 'Vacuna antirrábica anual aplicada según normativa sanitaria.',
      'cost': 200.00,
      'sideEffects': 'Leve inflamación local por 24 horas',
      'location': 'Región escapular izquierda',
    },
    {
      'id': '3',
      'name': 'Tos de las Perreras',
      'date': DateTime.now().subtract(const Duration(days: 90)),
      'batch': 'KC-2024-0445',
      'manufacturer': 'Nobivac',
      'veterinarian': 'Dr. Ana Martínez',
      'nextDate': DateTime.now().add(const Duration(days: 275)),
      'status': 'Aplicada',
      'notes':
          'Vacuna intranasal aplicada para prevención de traqueobronquitis.',
      'cost': 300.00,
      'sideEffects': 'Estornudos leves por 2 días',
      'location': 'Vía intranasal',
    },
  ];

  final List<Map<String, dynamic>> treatments = [
    {
      'id': '1',
      'name': 'Tratamiento Antiparasitario',
      'startDate': DateTime.now().subtract(const Duration(days: 5)),
      'endDate': DateTime.now().add(const Duration(days: 25)),
      'status': 'Activo',
      'medications': [
        {
          'name': 'Drontal Plus',
          'dosage': '1 comprimido',
          'frequency': 'Cada 12 horas',
          'duration': '3 días',
          'instructions': 'Administrar con alimento',
        },
        {
          'name': 'Vitaminas del complejo B',
          'dosage': '1 comprimido',
          'frequency': 'Diario',
          'duration': '30 días',
          'instructions': 'En ayunas, con abundante agua',
        },
      ],
      'reason': 'Desparasitación preventiva trimestral',
      'veterinarian': 'Dr. María González',
      'notes':
          'Tratamiento preventivo según calendario. Monitorear deposiciones.',
      'cost': 380.00,
      'progress': 'Excelente tolerancia, sin efectos secundarios',
    },
    {
      'id': '2',
      'name': 'Tratamiento Post-Quirúrgico',
      'startDate': DateTime.now().subtract(const Duration(days: 60)),
      'endDate': DateTime.now().subtract(const Duration(days: 50)),
      'status': 'Completado',
      'medications': [
        {
          'name': 'Amoxicilina',
          'dosage': '500mg',
          'frequency': 'Cada 8 horas',
          'duration': '7 días',
          'instructions': 'Con alimento para evitar molestias estomacales',
        },
        {
          'name': 'Meloxicam',
          'dosage': '1.5mg',
          'frequency': 'Cada 24 horas',
          'duration': '5 días',
          'instructions': 'Después de las comidas',
        },
      ],
      'reason': 'Recuperación post-limpieza dental',
      'veterinarian': 'Dr. Carlos López',
      'notes': 'Tratamiento completado exitosamente. Cicatrización adecuada.',
      'cost': 420.00,
      'progress': 'Recuperación completa sin complicaciones',
    },
    {
      'id': '3',
      'name': 'Tratamiento Digestivo',
      'startDate': DateTime.now().subtract(const Duration(days: 30)),
      'endDate': DateTime.now().subtract(const Duration(days: 20)),
      'status': 'Completado',
      'medications': [
        {
          'name': 'Omeprazol',
          'dosage': '20mg',
          'frequency': 'Cada 12 horas',
          'duration': '7 días',
          'instructions': 'Media hora antes de las comidas',
        },
        {
          'name': 'Probióticos',
          'dosage': '1 sobre',
          'frequency': 'Diario',
          'duration': '10 días',
          'instructions': 'Mezclar con alimento húmedo',
        },
      ],
      'reason': 'Gastroenteritis leve',
      'veterinarian': 'Dr. María González',
      'notes': 'Respuesta excelente al tratamiento. Síntomas resueltos.',
      'cost': 290.00,
      'progress': 'Recuperación completa en 7 días',
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
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF3498DB)),
            onPressed: () {},
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
              fontSize: 12,
              color: Color(0xFF3498DB),
              fontWeight: FontWeight.w500,
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
              Icons.medical_services,
              '${consultations.length}',
              'Consultas',
            ),
          ),
          Expanded(
            child: _buildStatCard(
              Icons.vaccines,
              '${vaccinations.length}',
              'Vacunas',
            ),
          ),
          Expanded(
            child: _buildStatCard(
              Icons.medication,
              '${treatments.length}',
              'Tratamientos',
            ),
          ),
          Expanded(child: _buildStatCard(Icons.attach_file, '4', 'Archivos')),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          Text(
            label,
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
        isScrollable: true,
        indicatorColor: const Color(0xFF3498DB),
        labelColor: const Color(0xFF3498DB),
        unselectedLabelColor: const Color(0xFF7F8C8D),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showConsultationDetail(consultation),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  consultation['notes'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF34495E),
                  ),
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
                          '\$${consultation['cost']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF7F8C8D),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showVaccinationDetail(vaccination),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.vaccines,
                        color: Color(0xFF27AE60),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vaccination['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            'Aplicada: ${_formatDate(vaccination['date'])}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          vaccination['status'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
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
                    _buildDataChip('Lote: ${vaccination['batch']}'),
                    const SizedBox(width: 8),
                    _buildDataChip(
                      'Próxima: ${_formatDate(vaccination['nextDate'])}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dr: ${vaccination['veterinarian']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3498DB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF7F8C8D),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showTreatmentDetail(treatment),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE67E22).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medication,
                        color: Color(0xFFE67E22),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            treatment['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            'Inicio: ${_formatDate(treatment['startDate'])}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          treatment['status'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 12),
                Text(
                  treatment['reason'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF34495E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDataChip(
                      '${treatment['medications'].length} medicamentos',
                    ),
                    const SizedBox(width: 8),
                    _buildDataChip('Dr: ${treatment['veterinarian']}'),
                  ],
                ),
                const SizedBox(height: 8),
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
                          '\$${treatment['cost']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF7F8C8D),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsTab() {
    final attachments = [
      {
        'name': 'Radiografía Tórax',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'type': 'image',
        'size': '2.4 MB',
      },
      {
        'name': 'Análisis de Sangre',
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'type': 'pdf',
        'size': '856 KB',
      },
      {
        'name': 'Receta Medicamentos',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'type': 'pdf',
        'size': '123 KB',
      },
      {
        'name': 'Fotos Before/After',
        'date': DateTime.now().subtract(const Duration(days: 60)),
        'type': 'image',
        'size': '5.1 MB',
      },
    ];

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                attachment['type'] == 'image'
                    ? const Color(0xFF9B59B6).withOpacity(0.1)
                    : const Color(0xFFE74C3C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            attachment['type'] == 'image' ? Icons.image : Icons.picture_as_pdf,
            color:
                attachment['type'] == 'image'
                    ? const Color(0xFF9B59B6)
                    : const Color(0xFFE74C3C),
          ),
        ),
        title: Text(
          attachment['name'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Text(
          '${_formatDate(attachment['date'])} • ${attachment['size']}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: Color(0xFF3498DB)),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildDataChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF7F8C8D),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return const Color(0xFF27AE60);
      case 'completado':
      case 'aplicada':
        return const Color(0xFF3498DB);
      case 'pendiente':
        return const Color(0xFFE67E22);
      case 'cancelado':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showConsultationDetail(Map<String, dynamic> consultation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3498DB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.medical_services,
                                color: Color(0xFF3498DB),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detalle de Consulta',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    _formatDate(consultation['date']),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  consultation['status'],
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                consultation['status'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(
                                    consultation['status'],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailSection(
                                'Diagnóstico',
                                consultation['diagnosis'],
                              ),
                              _buildDetailSection(
                                'Síntomas',
                                consultation['symptoms'],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Signos Vitales',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildVitalCard(
                                      'Temperatura',
                                      consultation['temperature'],
                                      Icons.thermostat,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildVitalCard(
                                      'Peso',
                                      consultation['weight'],
                                      Icons.monitor_weight,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildVitalCard(
                                      'Pulso',
                                      consultation['pulse'],
                                      Icons.favorite,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildDetailSection(
                                'Notas del Veterinario',
                                consultation['notes'],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Prescripciones',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...consultation['prescriptions']
                                  .map<Widget>(
                                    (prescription) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE0E0E0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.medication,
                                            size: 16,
                                            color: Color(0xFF27AE60),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              prescription,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF2C3E50),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Costo Total',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    '\$${consultation['cost']}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF27AE60),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showVaccinationDetail(Map<String, dynamic> vaccination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
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
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detalle de Vacuna',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    vaccination['name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  vaccination['status'],
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                vaccination['status'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(vaccination['status']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailSection(
                                'Vacuna',
                                vaccination['name'],
                              ),
                              _buildDetailSection(
                                'Fabricante',
                                vaccination['manufacturer'],
                              ),
                              _buildDetailSection('Lote', vaccination['batch']),
                              _buildDetailSection(
                                'Lugar de Aplicación',
                                vaccination['location'],
                              ),
                              _buildDetailSection(
                                'Veterinario',
                                vaccination['veterinarian'],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoCard(
                                      'Fecha de Aplicación',
                                      _formatDate(vaccination['date']),
                                      Icons.calendar_today,
                                      const Color(0xFF3498DB),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInfoCard(
                                      'Próxima Dosis',
                                      _formatDate(vaccination['nextDate']),
                                      Icons.schedule,
                                      const Color(0xFFE67E22),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildDetailSection(
                                'Notas',
                                vaccination['notes'],
                              ),
                              _buildDetailSection(
                                'Efectos Secundarios',
                                vaccination['sideEffects'],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Costo',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    '\$${vaccination['cost']}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF27AE60),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showTreatmentDetail(Map<String, dynamic> treatment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE67E22).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.medication,
                                color: Color(0xFFE67E22),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detalle de Tratamiento',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    treatment['name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  treatment['status'],
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                treatment['status'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(treatment['status']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailSection(
                                'Motivo',
                                treatment['reason'],
                              ),
                              _buildDetailSection(
                                'Veterinario',
                                treatment['veterinarian'],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoCard(
                                      'Fecha de Inicio',
                                      _formatDate(treatment['startDate']),
                                      Icons.play_arrow,
                                      const Color(0xFF27AE60),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInfoCard(
                                      'Fecha de Fin',
                                      _formatDate(treatment['endDate']),
                                      Icons.stop,
                                      const Color(0xFFE74C3C),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Medicamentos',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...treatment['medications']
                                  .map<Widget>(
                                    (medication) => Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE0E0E0),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.medication,
                                                size: 20,
                                                color: Color(0xFFE67E22),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  medication['name'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2C3E50),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Dosis: ${medication['dosage']} - ${medication['frequency']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF34495E),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Duración: ${medication['duration']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF7F8C8D),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Instrucciones: ${medication['instructions']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF7F8C8D),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              const SizedBox(height: 20),
                              _buildDetailSection(
                                'Notas del Veterinario',
                                treatment['notes'],
                              ),
                              _buildDetailSection(
                                'Progreso',
                                treatment['progress'],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Costo Total',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    '\$${treatment['cost']}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF27AE60),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVitalCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3498DB)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
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
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7F8C8D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
