import 'package:flutter/material.dart';

class MedicalRecordPage extends StatefulWidget {
  const MedicalRecordPage({super.key});

  @override
  State<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _medicalRecords = [
    {
      'id': '1',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'type': 'Consulta General',
      'veterinarian': 'Dr. María González',
      'clinic': 'Clínica VetCare Tuxtla',
      'diagnosis': 'Salud general excelente',
      'treatment': 'Control de rutina completado',
      'notes':
          'Mascota en perfecto estado de salud. Mantener rutina de ejercicio.',
      'weight': '25.5 kg',
      'temperature': '38.2°C',
      'heartRate': '95 bpm',
      'medications': [
        {
          'name': 'Vitaminas multiples',
          'dosage': '1 tablet diaria',
          'duration': '30 días',
        },
      ],
    },
    {
      'id': '2',
      'date': DateTime.now().subtract(const Duration(days: 45)),
      'type': 'Vacunación',
      'veterinarian': 'Dr. Carlos López',
      'clinic': 'Hospital Veterinario Central',
      'diagnosis': 'Protocolo de vacunación completado',
      'treatment': 'Vacuna múltiple aplicada',
      'notes': 'Próxima vacuna en 6 meses. Sin reacciones adversas.',
      'weight': '25.0 kg',
      'medications': [],
    },
    {
      'id': '3',
      'date': DateTime.now().subtract(const Duration(days: 120)),
      'type': 'Cirugía Menor',
      'veterinarian': 'Dra. Ana García',
      'clinic': 'Centro Veterinario Especializado',
      'diagnosis': 'Extracción dental exitosa',
      'treatment': 'Cirugía dental completada sin complicaciones',
      'notes': 'Recuperación excelente. Dieta blanda por 7 días.',
      'weight': '24.8 kg',
      'temperature': '37.9°C',
      'medications': [
        {
          'name': 'Antibiótico',
          'dosage': '250mg cada 12h',
          'duration': '7 días',
        },
        {'name': 'Analgésico', 'dosage': '100mg cada 8h', 'duration': '5 días'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildPetHeader(),
            const SizedBox(height: 16),
            _buildTabBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildTabBarView()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expediente Médico',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Historial completo de salud',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pets, color: Color(0xFF4CAF50), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Max',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Golden Retriever • 3 años',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.monitor_weight_outlined,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Último peso: 25.5 kg',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Saludable',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(6),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF757575),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Consultas'),
          Tab(text: 'Medicamentos'),
          Tab(text: 'Signos Vitales'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildConsultationsTab(),
        _buildMedicationsTab(),
        _buildVitalSignsTab(),
      ],
    );
  }

  Widget _buildConsultationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: _medicalRecords.length,
      itemBuilder: (context, index) {
        final record = _medicalRecords[index];
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 0.5 + (index * 0.1)),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    1.0,
                    curve: Curves.easeOut,
                  ),
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildConsultationCard(record),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> record) {
    return GestureDetector(
      onTap: () => _navigateToConsultationDetail(record),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getTypeColor(record['type']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTypeIcon(record['type']),
                          color: _getTypeColor(record['type']),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record['type'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(record['date']),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        record['veterinarian'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.local_hospital_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          record['clinic'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (record['diagnosis'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Diagnóstico:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record['diagnosis'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                  if (record['notes'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      record['notes'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsTab() {
    final allMedications = <Map<String, dynamic>>[];

    for (final record in _medicalRecords) {
      if (record['medications'] != null && record['medications'] is List) {
        final medications = record['medications'] as List;
        for (final medication in medications) {
          if (medication is Map<String, dynamic>) {
            allMedications.add({
              ...medication,
              'date': record['date'],
              'veterinarian': record['veterinarian'],
            });
          }
        }
      }
    }

    if (allMedications.isEmpty) {
      return _buildEmptyState(
        'No hay medicamentos registrados',
        'Los tratamientos médicos aparecerán aquí',
        Icons.medication_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: allMedications.length,
      itemBuilder: (context, index) {
        final medication = allMedications[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: Color(0xFFFF7043),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dosis: ${medication['dosage']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  'Duración: ${medication['duration']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recetado: ${_formatDate(medication['date'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsTab() {
    final vitalSigns = <Map<String, dynamic>>[];

    for (final record in _medicalRecords) {
      final signs = <String, dynamic>{
        'date': record['date'],
        'veterinarian': record['veterinarian'],
      };

      if (record['weight'] != null) signs['weight'] = record['weight'];
      if (record['temperature'] != null)
        signs['temperature'] = record['temperature'];
      if (record['heartRate'] != null) signs['heartRate'] = record['heartRate'];

      if (signs.length > 2) {
        vitalSigns.add(signs);
      }
    }

    if (vitalSigns.isEmpty) {
      return _buildEmptyState(
        'No hay signos vitales registrados',
        'Los datos de peso, temperatura y frecuencia cardíaca aparecerán aquí',
        Icons.monitor_heart_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: vitalSigns.length,
      itemBuilder: (context, index) {
        final signs = vitalSigns[index];
        return _buildVitalSignsCard(signs);
      },
    );
  }

  Widget _buildVitalSignsCard(Map<String, dynamic> signs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF81D4FA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  color: Color(0xFF81D4FA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(signs['date']),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      signs['veterinarian'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (signs['weight'] != null)
                Expanded(
                  child: _buildVitalSignItem(
                    'Peso',
                    signs['weight'],
                    Icons.monitor_weight_outlined,
                    const Color(0xFF4CAF50),
                  ),
                ),
              if (signs['temperature'] != null)
                Expanded(
                  child: _buildVitalSignItem(
                    'Temperatura',
                    signs['temperature'],
                    Icons.thermostat_outlined,
                    const Color(0xFFFF7043),
                  ),
                ),
              if (signs['heartRate'] != null)
                Expanded(
                  child: _buildVitalSignItem(
                    'Freq. Cardíaca',
                    signs['heartRate'],
                    Icons.monitor_heart_outlined,
                    const Color(0xFF81D4FA),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'consulta general':
        return const Color(0xFF4CAF50);
      case 'vacunación':
        return const Color(0xFF81D4FA);
      case 'cirugía menor':
      case 'cirugía':
        return const Color(0xFFFF7043);
      case 'emergencia':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'consulta general':
        return Icons.medical_services_outlined;
      case 'vacunación':
        return Icons.vaccines_outlined;
      case 'cirugía menor':
      case 'cirugía':
        return Icons.healing_outlined;
      case 'emergencia':
        return Icons.emergency_outlined;
      default:
        return Icons.health_and_safety_outlined;
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

  void _navigateToConsultationDetail(Map<String, dynamic> record) {
    Navigator.pushNamed(context, '/consultation-detail', arguments: record);
  }
}
