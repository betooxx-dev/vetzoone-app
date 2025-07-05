import 'package:flutter/material.dart';

class ActiveTreatmentsPage extends StatefulWidget {
  const ActiveTreatmentsPage({super.key});

  @override
  State<ActiveTreatmentsPage> createState() => _ActiveTreatmentsPageState();
}

class _ActiveTreatmentsPageState extends State<ActiveTreatmentsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> treatments = [];
  List<Map<String, dynamic>> filteredTreatments = [];
  String selectedFilter = 'Todos';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _loadTreatments();
  }

  void _loadTreatments() {
    // Simulación de datos - en producción vendrían del backend
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          treatments = [
            {
              'id': '1',
              'medication': 'Amoxicilina',
              'dosage': '250mg',
              'frequency': 'Cada 8 horas',
              'duration': '7 días',
              'startDate': DateTime.now().subtract(const Duration(days: 3)),
              'endDate': DateTime.now().add(const Duration(days: 4)),
              'veterinarian': 'Dr. María González',
              'diagnosis': 'Infección respiratoria',
              'instructions': 'Administrar con alimentos. Si hay vómitos, contactar al veterinario.',
              'status': 'Activo',
              'progress': 0.43, // 3 de 7 días completados
              'nextDose': DateTime.now().add(const Duration(hours: 2)),
              'sideEffects': 'Posible somnolencia',
              'type': 'Antibiótico',
            },
            {
              'id': '2',
              'medication': 'Carprofeno',
              'dosage': '75mg',
              'frequency': 'Cada 12 horas',
              'duration': '5 días',
              'startDate': DateTime.now().subtract(const Duration(days: 1)),
              'endDate': DateTime.now().add(const Duration(days: 4)),
              'veterinarian': 'Dr. Carlos Mendoza',
              'diagnosis': 'Dolor articular',
              'instructions': 'Dar después de las comidas. Suspender si hay pérdida de apetito.',
              'status': 'Activo',
              'progress': 0.20, // 1 de 5 días completados
              'nextDose': DateTime.now().add(const Duration(hours: 6)),
              'sideEffects': 'Posibles problemas gastrointestinales',
              'type': 'Antiinflamatorio',
            },
            {
              'id': '3',
              'medication': 'Vitaminas B Complex',
              'dosage': '1 comprimido',
              'frequency': 'Una vez al día',
              'duration': '30 días',
              'startDate': DateTime.now().subtract(const Duration(days: 15)),
              'endDate': DateTime.now().add(const Duration(days: 15)),
              'veterinarian': 'Dr. Ana López',
              'diagnosis': 'Suplemento nutricional',
              'instructions': 'Administrar por la mañana con el desayuno.',
              'status': 'Activo',
              'progress': 0.50, // 15 de 30 días completados
              'nextDose': DateTime.now().add(const Duration(hours: 16)),
              'sideEffects': 'Ninguno conocido',
              'type': 'Suplemento',
            },
            {
              'id': '4',
              'medication': 'Metronidazol',
              'dosage': '500mg',
              'frequency': 'Cada 12 horas',
              'duration': '10 días',
              'startDate': DateTime.now().subtract(const Duration(days: 12)),
              'endDate': DateTime.now().subtract(const Duration(days: 2)),
              'veterinarian': 'Dr. Roberto Silva',
              'diagnosis': 'Infección gastrointestinal',
              'instructions': 'Completado según indicaciones.',
              'status': 'Completado',
              'progress': 1.0,
              'nextDose': null,
              'sideEffects': 'Náuseas leves reportadas',
              'type': 'Antibiótico',
            },
            {
              'id': '5',
              'medication': 'Prednisolona',
              'dosage': '10mg',
              'frequency': 'Cada 24 horas',
              'duration': '14 días',
              'startDate': DateTime.now().subtract(const Duration(days: 16)),
              'endDate': DateTime.now().subtract(const Duration(days: 2)),
              'veterinarian': 'Dr. María González',
              'diagnosis': 'Dermatitis alérgica',
              'instructions': 'Suspendido por mejoría del paciente.',
              'status': 'Suspendido',
              'progress': 0.86, // 12 de 14 días antes de suspender
              'nextDose': null,
              'sideEffects': 'Aumento del apetito',
              'type': 'Corticosteroide',
            },
          ];
          filteredTreatments = treatments;
          isLoading = false;
        });
      }
    });
    _animationController.forward();
  }

  void _filterTreatments(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Todos') {
        filteredTreatments = treatments;
      } else {
        filteredTreatments = treatments
            .where((treatment) => treatment['status'] == filter)
            .toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return const Color(0xFF27AE60);
      case 'completado':
        return const Color(0xFF3498DB);
      case 'suspendido':
        return const Color(0xFFE74C3C);
      case 'pausado':
        return const Color(0xFFF39C12);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return Icons.play_circle_filled;
      case 'completado':
        return Icons.check_circle;
      case 'suspendido':
        return Icons.cancel;
      case 'pausado':
        return Icons.pause_circle_filled;
      default:
        return Icons.help;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'antibiótico':
        return const Color(0xFFE74C3C);
      case 'antiinflamatorio':
        return const Color(0xFFF39C12);
      case 'suplemento':
        return const Color(0xFF27AE60);
      case 'corticosteroide':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Tratamientos Activos',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF3498DB)),
            onPressed: () => _showTreatmentInfo(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Filtros
              _buildFilterSection(),
              
              // Resumen rápido
              if (!isLoading && treatments.isNotEmpty) _buildQuickSummary(),
              
              // Lista de tratamientos
              Expanded(
                child: isLoading
                    ? _buildLoadingState()
                    : filteredTreatments.isEmpty
                        ? _buildEmptyState()
                        : _buildTreatmentsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final filters = ['Todos', 'Activo', 'Completado', 'Suspendido'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por estado:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                final isSelected = selectedFilter == filter;
                final count = filter == 'Todos' 
                    ? treatments.length
                    : treatments.where((t) => t['status'] == filter).length;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text('$filter ($count)'),
                    selected: isSelected,
                    onSelected: (selected) => _filterTreatments(filter),
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF3498DB) : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF3498DB) : Colors.grey[300]!,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary() {
    final activeTreatments = treatments.where((t) => t['status'] == 'Activo').length;
    final nextDose = treatments
        .where((t) => t['status'] == 'Activo' && t['nextDose'] != null)
        .fold<DateTime?>(null, (closest, treatment) {
      final nextDose = treatment['nextDose'] as DateTime;
      return closest == null || nextDose.isBefore(closest) ? nextDose : closest;
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3498DB).withOpacity(0.1),
            const Color(0xFF2ECC71).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3498DB).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication,
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
                      '$activeTreatments tratamiento${activeTreatments != 1 ? 's' : ''} activo${activeTreatments != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    if (nextDose != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Próxima dosis: ${_formatTime(nextDose)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (nextDose != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: _isNextDoseSoon(nextDose) 
                        ? const Color(0xFFE74C3C) 
                        : const Color(0xFF27AE60),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isNextDoseSoon(nextDose)
                          ? '¡Próxima dosis pronto!'
                          : 'Tratamientos al día',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isNextDoseSoon(nextDose) 
                            ? const Color(0xFFE74C3C) 
                            : const Color(0xFF27AE60),
                      ),
                    ),
                  ),
                  if (_isNextDoseSoon(nextDose))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getTimeUntilNextDose(nextDose),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE74C3C),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando tratamientos...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            selectedFilter == 'Todos' 
                ? 'No hay tratamientos registrados'
                : 'No hay tratamientos "${selectedFilter.toLowerCase()}s"',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los tratamientos aparecerán aquí una vez prescritos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTreatments.length,
      itemBuilder: (context, index) {
        final treatment = filteredTreatments[index];
        return _buildTreatmentCard(treatment, index);
      },
    );
  }

  Widget _buildTreatmentCard(Map<String, dynamic> treatment, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationDelay = index * 0.1;
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(animationDelay, 1.0, curve: Curves.easeOut),
        ));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showTreatmentDetail(treatment),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con medicamento y estado
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    treatment['medication'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getTypeColor(treatment['type'])
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          treatment['type'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: _getTypeColor(treatment['type']),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${treatment['dosage']} • ${treatment['frequency']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
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
                                color: _getStatusColor(treatment['status'])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getStatusColor(treatment['status'])
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(treatment['status']),
                                    size: 16,
                                    color: _getStatusColor(treatment['status']),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    treatment['status'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(treatment['status']),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Barra de progreso
                        if (treatment['status'] == 'Activo' || treatment['status'] == 'Completado') ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Progreso del tratamiento',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '${(treatment['progress'] * 100).round()}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _getStatusColor(treatment['status']),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: treatment['progress'],
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getStatusColor(treatment['status']),
                                      ),
                                      minHeight: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Información adicional
                        _buildInfoRow(Icons.schedule, 'Duración', treatment['duration']),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.local_hospital, 'Veterinario', treatment['veterinarian']),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.medical_information, 'Diagnóstico', treatment['diagnosis']),
                        
                        // Próxima dosis (solo para activos)
                        if (treatment['status'] == 'Activo' && treatment['nextDose'] != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isNextDoseSoon(treatment['nextDose'])
                                  ? const Color(0xFFE74C3C).withOpacity(0.1)
                                  : const Color(0xFF3498DB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isNextDoseSoon(treatment['nextDose'])
                                    ? const Color(0xFFE74C3C).withOpacity(0.3)
                                    : const Color(0xFF3498DB).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  size: 20,
                                  color: _isNextDoseSoon(treatment['nextDose'])
                                      ? const Color(0xFFE74C3C)
                                      : const Color(0xFF3498DB),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Próxima dosis',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        _formatDateTime(treatment['nextDose']),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _isNextDoseSoon(treatment['nextDose'])
                                              ? const Color(0xFFE74C3C)
                                              : const Color(0xFF3498DB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isNextDoseSoon(treatment['nextDose']))
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE74C3C),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getTimeUntilNextDose(treatment['nextDose']),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF7F8C8D),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      final hours = dateTime.hour;
      final minutes = dateTime.minute;
      return 'Hoy a las ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      final hours = dateTime.hour;
      final minutes = dateTime.minute;
      return 'Mañana a las ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } else {
      return _formatDate(dateTime);
    }
  }

  String _formatTime(DateTime dateTime) {
    final hours = dateTime.hour;
    final minutes = dateTime.minute;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _isNextDoseSoon(DateTime nextDose) {
    final now = DateTime.now();
    final difference = nextDose.difference(now);
    return difference.inHours <= 2 && difference.inMinutes > 0;
  }

  String _getTimeUntilNextDose(DateTime nextDose) {
    final now = DateTime.now();
    final difference = nextDose.difference(now);
    
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  void _showTreatmentDetail(Map<String, dynamic> treatment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  treatment['medication'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  treatment['type'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _getTypeColor(treatment['type']),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(treatment['status'])
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(treatment['status'])
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(treatment['status']),
                                  size: 20,
                                  color: _getStatusColor(treatment['status']),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  treatment['status'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(treatment['status']),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Progreso (solo para activos y completados)
                      if (treatment['status'] == 'Activo' || treatment['status'] == 'Completado') ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getStatusColor(treatment['status']).withOpacity(0.1),
                                _getStatusColor(treatment['status']).withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getStatusColor(treatment['status']).withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Progreso del Tratamiento',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    '${(treatment['progress'] * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _getStatusColor(treatment['status']),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: treatment['progress'],
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getStatusColor(treatment['status']),
                                  ),
                                  minHeight: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Inicio: ${_formatDate(treatment['startDate'])}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Fin: ${_formatDate(treatment['endDate'])}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Información de dosificación
                      const Text(
                        'Información de Dosificación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildDetailRow('Dosis', treatment['dosage']),
                      _buildDetailRow('Frecuencia', treatment['frequency']),
                      _buildDetailRow('Duración', treatment['duration']),
                      
                      if (treatment['nextDose'] != null) 
                        _buildDetailRow('Próxima dosis', _formatDateTime(treatment['nextDose'])),
                      
                      const SizedBox(height: 24),
                      
                      // Información médica
                      const Text(
                        'Información Médica',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildDetailRow('Diagnóstico', treatment['diagnosis']),
                      _buildDetailRow('Veterinario', treatment['veterinarian']),
                      _buildDetailRow('Efectos secundarios', treatment['sideEffects']),
                      
                      const SizedBox(height: 24),
                      
                      // Instrucciones especiales
                      const Text(
                        'Instrucciones Especiales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                          ),
                        ),
                        child: Text(
                          treatment['instructions'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2C3E50),
                            height: 1.5,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Botones de acción
                      if (treatment['status'] == 'Activo') ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showPauseTreatmentDialog(treatment);
                                },
                                icon: const Icon(Icons.pause),
                                label: const Text('Pausar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFF39C12),
                                  side: const BorderSide(color: Color(0xFFF39C12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _markDoseAsTaken(treatment);
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Marcar Dosis'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF27AE60),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showStopTreatmentDialog(treatment);
                            },
                            icon: const Icon(Icons.stop),
                            label: const Text('Suspender Tratamiento'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE74C3C),
                              side: const BorderSide(color: Color(0xFFE74C3C)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTreatmentInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Color(0xFF3498DB),
            ),
            const SizedBox(width: 8),
            const Text(
              'Información',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estados de Tratamientos:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 12),
            Text('• Activo: Tratamiento en curso'),
            Text('• Completado: Tratamiento terminado exitosamente'),
            Text('• Suspendido: Tratamiento detenido por el veterinario'),
            Text('• Pausado: Temporalmente interrumpido'),
            SizedBox(height: 16),
            Text(
              'Recordatorio:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Siempre consulta con tu veterinario antes de modificar o suspender cualquier tratamiento.',
              style: TextStyle(
                color: Color(0xFF7F8C8D),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(color: Color(0xFF3498DB)),
            ),
          ),
        ],
      ),
    );
  }

  void _markDoseAsTaken(Map<String, dynamic> treatment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dosis de ${treatment['medication']} marcada como tomada'),
        backgroundColor: const Color(0xFF27AE60),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: Colors.white,
          onPressed: () {
            // Deshacer acción
          },
        ),
      ),
    );
  }

  void _showPauseTreatmentDialog(Map<String, dynamic> treatment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Pausar Tratamiento',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres pausar el tratamiento de ${treatment['medication']}?\n\nRecomendamos consultar con tu veterinario antes de pausar cualquier medicamento.',
          style: const TextStyle(
            color: Color(0xFF7F8C8D),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF7F8C8D)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tratamiento de ${treatment['medication']} pausado'),
                  backgroundColor: const Color(0xFFF39C12),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF39C12),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Pausar'),
          ),
        ],
      ),
    );
  }

  void _showStopTreatmentDialog(Map<String, dynamic> treatment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Suspender Tratamiento',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFFE74C3C),
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres suspender permanentemente el tratamiento de ${treatment['medication']}?\n\n⚠️ Esta acción puede afectar la recuperación de tu mascota. Se recomienda consultar con el veterinario.',
          style: const TextStyle(
            color: Color(0xFF7F8C8D),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF7F8C8D)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tratamiento de ${treatment['medication']} suspendido'),
                  backgroundColor: const Color(0xFFE74C3C),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Suspender'),
          ),
        ],
      ),
    );
  }
}