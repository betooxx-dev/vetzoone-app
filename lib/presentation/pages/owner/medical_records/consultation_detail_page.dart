import 'package:flutter/material.dart';

class ConsultationDetailPage extends StatefulWidget {
  const ConsultationDetailPage({super.key});

  @override
  State<ConsultationDetailPage> createState() => _ConsultationDetailPageState();
}

class _ConsultationDetailPageState extends State<ConsultationDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic> consultation = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _initializeConsultationData();
    _animationController.forward();
  }

  void _initializeConsultationData() {
    final defaultConsultation = {
      'id': '1',
      'date': DateTime(2024, 11, 15),
      'type': 'Consulta General',
      'veterinarian': 'Dr. María González',
      'clinic': 'Clínica VetCare Tuxtla',
      'diagnosis': 'Estado de salud excelente',
      'treatment': 'Continuar con dieta actual y ejercicio regular',
      'notes': 'Mascota en perfecto estado. Se recomienda próxima visita en 6 meses para control preventivo.',
      'medications': [
        {'name': 'Vitamina C', 'dosage': '1 tableta diaria', 'duration': '30 días'},
      ],
      'weight': '25.2 kg',
      'temperature': '38.5°C',
      'heartRate': '80 bpm',
      'followUp': 'Control en 6 meses',
      'cost': 350.0,
      'petName': 'Max',
      'recommendations': [
        'Mantener dieta balanceada',
        'Ejercicio diario de 30 minutos',
        'Cepillado dental semanal',
        'Revisar peso mensualmente',
      ],
      'observations': 'Paciente cooperativo durante la consulta. Excelente estado general.',
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map<String, dynamic>) {
        setState(() {
          consultation = {...defaultConsultation, ...arguments};
        });
      } else {
        setState(() {
          consultation = defaultConsultation;
        });
      }
    });

    consultation = defaultConsultation;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildConsultationHeader(),
                  _buildDetailsSections(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    final typeColor = _getTypeColor(consultation['type'] ?? '');

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: typeColor,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF212121),
            size: 20,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF212121)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    const Text('Compartir'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    const Text('Descargar PDF'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // ignore: deprecated_member_use
              colors: [typeColor, typeColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  _getTypeIcon(consultation['type'] ?? ''),
                  size: 35,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                consultation['type'] ?? 'Consulta',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(consultation['date'] ?? DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsultationHeader() {
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation['veterinarian'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      consultation['clinic'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              if (consultation['cost'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${consultation['cost']?.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const Text(
                      'Costo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.pets_rounded, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Paciente: ${consultation['petName'] ?? 'Mascota'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildDiagnosisSection(),
          const SizedBox(height: 24),
          _buildVitalSignsSection(),
          const SizedBox(height: 24),
          if (consultation['medications'] != null && consultation['medications'].isNotEmpty)
            _buildMedicationsSection(),
          if (consultation['medications'] != null && consultation['medications'].isNotEmpty)
            const SizedBox(height: 24),
          if (consultation['recommendations'] != null && consultation['recommendations'].isNotEmpty)
            _buildRecommendationsSection(),
          if (consultation['recommendations'] != null && consultation['recommendations'].isNotEmpty)
            const SizedBox(height: 24),
          _buildNotesSection(),
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    return _buildDetailCard(
      title: 'Diagnóstico y Tratamiento',
      icon: Icons.assignment_outlined,
      iconColor: const Color(0xFF4CAF50),
      children: [
        _buildInfoContainer(
          'Diagnóstico',
          consultation['diagnosis'] ?? '',
          const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 12),
        _buildInfoContainer(
          'Tratamiento',
          consultation['treatment'] ?? '',
          const Color(0xFF81D4FA),
        ),
        if (consultation['followUp'] != null) ...[
          const SizedBox(height: 12),
          _buildInfoContainer(
            'Seguimiento',
            consultation['followUp'],
            const Color(0xFFFF7043),
          ),
        ],
      ],
    );
  }

  Widget _buildVitalSignsSection() {
    final hasVitalSigns = consultation['weight'] != null ||
        consultation['temperature'] != null ||
        consultation['heartRate'] != null;

    if (!hasVitalSigns) return const SizedBox.shrink();

    return _buildDetailCard(
      title: 'Signos Vitales',
      icon: Icons.monitor_heart_outlined,
      iconColor: const Color(0xFFFF7043),
      children: [
        Row(
          children: [
            if (consultation['weight'] != null)
              Expanded(
                child: _buildVitalSignItem(
                  'Peso',
                  consultation['weight'],
                  Icons.monitor_weight_outlined,
                  const Color(0xFF4CAF50),
                ),
              ),
            if (consultation['temperature'] != null)
              Expanded(
                child: _buildVitalSignItem(
                  'Temperatura',
                  consultation['temperature'],
                  Icons.thermostat_outlined,
                  const Color(0xFFFF7043),
                ),
              ),
            if (consultation['heartRate'] != null)
              Expanded(
                child: _buildVitalSignItem(
                  'Freq. Cardíaca',
                  consultation['heartRate'],
                  Icons.monitor_heart_outlined,
                  const Color(0xFF81D4FA),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicationsSection() {
    final medications = consultation['medications'] as List<Map<String, dynamic>>;

    return _buildDetailCard(
      title: 'Medicamentos Recetados',
      icon: Icons.medication_outlined,
      iconColor: const Color(0xFF9C27B0),
      children: [
        ...medications.map((medication) => _buildMedicationItem(medication)),
      ],
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: Color(0xFF9C27B0),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                Text(
                  'Dosis: ${medication['dosage']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  'Duración: ${medication['duration']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final recommendations = consultation['recommendations'] as List<String>;

    return _buildDetailCard(
      title: 'Recomendaciones',
      icon: Icons.lightbulb_outlined,
      iconColor: const Color(0xFFFFB74D),
      children: [
        ...recommendations.map((recommendation) => _buildRecommendationItem(recommendation)),
      ],
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFB74D),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF212121),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    final notes = consultation['notes'] ?? '';
    final observations = consultation['observations'] ?? '';

    return _buildDetailCard(
      title: 'Notas y Observaciones',
      icon: Icons.note_outlined,
      iconColor: const Color(0xFF81D4FA),
      children: [
        if (notes.isNotEmpty) ...[
          _buildInfoContainer('Notas', notes, const Color(0xFF81D4FA)),
          if (observations.isNotEmpty) const SizedBox(height: 12),
        ],
        if (observations.isNotEmpty)
          _buildInfoContainer('Observaciones', observations, const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color iconColor,
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoContainer(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF212121),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignItem(String label, String value, IconData icon, Color color) {
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
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Agendar seguimiento
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendar cita de seguimiento'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      },
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.event_note_outlined),
      label: const Text(
        'Seguimiento',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                   'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    
    final weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    
    return '$weekday, ${date.day} de $month de ${date.year}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compartir consulta'),
            backgroundColor: Color(0xFF81D4FA),
          ),
        );
        break;
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Descargando PDF...'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        break;
    }
  }
}