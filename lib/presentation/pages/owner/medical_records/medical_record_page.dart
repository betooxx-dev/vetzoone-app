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

  Map<String, String> pet = {};

  // Mock data
  final List<Map<String, dynamic>> _medicalRecords = [
    {
      'id': '1',
      'date': DateTime(2024, 11, 15),
      'type': 'Consulta General',
      'veterinarian': 'Dr. María González',
      'clinic': 'Clínica VetCare Tuxtla',
      'diagnosis': 'Estado de salud excelente',
      'treatment': 'Continuar con dieta actual y ejercicio regular',
      'notes':
          'Mascota en perfecto estado. Se recomienda próxima visita en 6 meses.',
      'medications': [
        {
          'name': 'Vitamina C',
          'dosage': '1 tableta diaria',
          'duration': '30 días',
        },
      ],
      'weight': '25.2 kg',
      'temperature': '38.5°C',
      'heartRate': '80 bpm',
    },
    {
      'id': '2',
      'date': DateTime(2024, 10, 20),
      'type': 'Vacunación',
      'veterinarian': 'Dr. Carlos López',
      'clinic': 'Hospital Veterinario Central',
      'diagnosis': 'Vacunación preventiva',
      'treatment': 'Vacuna múltiple DHPP',
      'notes': 'Aplicación exitosa. Próxima dosis en 1 año.',
      'vaccines': [
        {
          'name': 'DHPP',
          'batch': 'VAC-2024-001',
          'nextDate': DateTime(2025, 10, 20),
        },
      ],
      'weight': '25.0 kg',
      'temperature': '38.3°C',
    },
    {
      'id': '3',
      'date': DateTime(2024, 9, 5),
      'type': 'Desparasitación',
      'veterinarian': 'Dra. Ana García',
      'clinic': 'Centro Veterinario Especializado',
      'diagnosis': 'Prevención parasitaria',
      'treatment': 'Desparasitante oral',
      'notes': 'Tratamiento preventivo exitoso. Repetir en 3 meses.',
      'medications': [
        {
          'name': 'Drontal Plus',
          'dosage': '1 tableta',
          'duration': 'Dosis única',
        },
      ],
      'weight': '24.8 kg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _initializePetData();
    _animationController.forward();
  }

  void _initializePetData() {
    final defaultPet = {
      'name': 'Max',
      'species': 'Perro',
      'breed': 'Labrador Retriever',
      'age': '3 años',
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, String>) {
        setState(() {
          pet = arguments;
        });
      } else {
        setState(() {
          pet = defaultPet;
        });
      }
    });

    pet = defaultPet;
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildAppBar(),
              _buildPetHeader(),
              _buildQuickActionsSection(), // ← NUEVA SECCIÓN AGREGADA
              _buildTabBar(),
              Expanded(child: _buildTabBarView()),
            ],
          ),
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
              // ignore: deprecated_member_use
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
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {
                // Compartir expediente
              },
              icon: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetHeader() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet['name'] ?? 'Mascota',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet['species']} - ${pet['breed']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pet['age'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_medicalRecords.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const Text(
                'Registros',
                style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ← NUEVA FUNCIÓN AGREGADA: Botones de navegación a vistas 30-31
  Widget _buildQuickActionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          const Row(
            children: [
              Icon(Icons.medical_services, color: Color(0xFF4CAF50), size: 24),
              SizedBox(width: 8),
              Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botones para las nuevas vistas 30-31
          Row(
            children: [
              // Vista 30: Historial de Vacunas
              Expanded(
                child: _buildActionButton(
                  icon: Icons.vaccines,
                  title: 'Historial de Vacunas',
                  subtitle: 'Ver todas las vacunas',
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    Navigator.pushNamed(context, '/vaccination-history');
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Vista 31: Tratamientos Activos
              Expanded(
                child: _buildActionButton(
                  icon: Icons.medication,
                  title: 'Tratamientos Activos',
                  subtitle: 'Ver medicamentos',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.pushNamed(context, '/active-treatments');
                  },
                ),
              ),
            ],
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
            // ignore: deprecated_member_use
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
            final delay = index * 0.1;
            final animationValue = (_animationController.value - delay).clamp(
              0.0,
              1.0,
            );

            return Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: _buildConsultationCard(record),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToConsultationDetail(record),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record['veterinarian'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF81D4FA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            record['clinic'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDate(record['date']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diagnóstico',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w600,
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
                  ),
                ),
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
        ),
      ),
    );
  }

  Widget _buildMedicationsTab() {
    final allMedications = <Map<String, dynamic>>[];

    // Recopilar medicamentos de todos los registros
    for (final record in _medicalRecords) {
      if (record['medications'] != null) {
        final medications = record['medications'] as List<Map<String, dynamic>>;
        for (final medication in medications) {
          allMedications.add({
            ...medication,
            'date': record['date'],
            'veterinarian': record['veterinarian'],
          });
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
              // ignore: deprecated_member_use
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

    // Recopilar signos vitales de todos los registros
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
        // Más que solo fecha y veterinario
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
            // ignore: deprecated_member_use
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
                _formatDate(signs['date']),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              Text(
                signs['veterinarian'],
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
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
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ← NUEVA FUNCIÓN AGREGADA: Botones de acción reutilizables
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos auxiliares
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'consulta general':
        return const Color(0xFF4CAF50);
      case 'vacunación':
        return const Color(0xFF81D4FA);
      case 'desparasitación':
        return const Color(0xFFFF7043);
      case 'cirugía':
        return const Color(0xFF9C27B0);
      case 'emergencia':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'consulta general':
        return Icons.medical_services_outlined;
      case 'vacunación':
        return Icons.vaccines_outlined;
      case 'desparasitación':
        return Icons.bug_report_outlined;
      case 'cirugía':
        return Icons.healing_outlined;
      case 'emergencia':
        return Icons.local_hospital_outlined;
      default:
        return Icons.description_outlined;
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
