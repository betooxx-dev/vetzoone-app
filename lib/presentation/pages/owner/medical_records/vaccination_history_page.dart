import 'package:flutter/material.dart';

class VaccinationHistoryPage extends StatefulWidget {
  const VaccinationHistoryPage({super.key});

  @override
  State<VaccinationHistoryPage> createState() => _VaccinationHistoryPageState();
}

class _VaccinationHistoryPageState extends State<VaccinationHistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> vaccinations = [];
  List<Map<String, dynamic>> filteredVaccinations = [];
  String selectedFilter = 'Todas';
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
    
    _loadVaccinations();
  }

  void _loadVaccinations() {
    // Simulación de datos - en producción vendrían del backend
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          vaccinations = [
            {
              'id': '1',
              'name': 'Vacuna Múltiple (DHPP)',
              'date': DateTime.now().subtract(const Duration(days: 30)),
              'nextDate': DateTime.now().add(const Duration(days: 335)),
              'veterinarian': 'Dr. María González',
              'clinic': 'Clínica VetCare',
              'batch': 'VM2024-001',
              'status': 'Aplicada',
              'type': 'Refuerzo',
              'notes': 'Refuerzo anual, sin reacciones adversas',
            },
            {
              'id': '2',
              'name': 'Vacuna Antirrábica',
              'date': DateTime.now().subtract(const Duration(days: 45)),
              'nextDate': DateTime.now().add(const Duration(days: 320)),
              'veterinarian': 'Dr. Carlos Mendoza',
              'clinic': 'Hospital Veterinario Central',
              'batch': 'VAR2024-015',
              'status': 'Aplicada',
              'type': 'Anual',
              'notes': 'Vacuna obligatoria aplicada correctamente',
            },
            {
              'id': '3',
              'name': 'Vacuna Bordetella',
              'date': DateTime.now().subtract(const Duration(days: 180)),
              'nextDate': DateTime.now().add(const Duration(days: 185)),
              'veterinarian': 'Dr. Ana López',
              'clinic': 'Clínica VetCare',
              'batch': 'VB2024-008',
              'status': 'Próxima',
              'type': 'Semestral',
              'notes': 'Programada para renovación',
            },
            {
              'id': '4',
              'name': 'Vacuna Parvovirus',
              'date': DateTime.now().subtract(const Duration(days: 400)),
              'nextDate': DateTime.now().subtract(const Duration(days: 35)),
              'veterinarian': 'Dr. Roberto Silva',
              'clinic': 'Veterinaria Mascotas Felices',
              'batch': 'VP2023-012',
              'status': 'Vencida',
              'type': 'Inicial',
              'notes': 'Primera aplicación - requiere refuerzo urgente',
            },
          ];
          filteredVaccinations = vaccinations;
          isLoading = false;
        });
      }
    });
    _animationController.forward();
  }

  void _filterVaccinations(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Todas') {
        filteredVaccinations = vaccinations;
      } else {
        filteredVaccinations = vaccinations
            .where((vaccination) => vaccination['status'] == filter)
            .toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aplicada':
        return Colors.green;
      case 'próxima':
        return Colors.orange;
      case 'vencida':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'aplicada':
        return Icons.check_circle;
      case 'próxima':
        return Icons.schedule;
      case 'vencida':
        return Icons.warning;
      default:
        return Icons.help;
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
          'Historial de Vacunas',
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
            icon: const Icon(Icons.add, color: Color(0xFF3498DB)),
            onPressed: () {
              // Navegar a agendar nueva vacuna
              _showScheduleVaccinationDialog();
            },
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
              
              // Lista de vacunas
              Expanded(
                child: isLoading
                    ? _buildLoadingState()
                    : filteredVaccinations.isEmpty
                        ? _buildEmptyState()
                        : _buildVaccinationsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final filters = ['Todas', 'Aplicada', 'Próxima', 'Vencida'];
    
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
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) => _filterVaccinations(filter),
                    backgroundColor: Colors.grey[100],
                    // ignore: deprecated_member_use
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
            'Cargando historial de vacunas...',
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
            Icons.vaccines_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            selectedFilter == 'Todas' 
                ? 'No hay vacunas registradas'
                : 'No hay vacunas con estado "$selectedFilter"',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las vacunas aparecerán aquí una vez registradas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showScheduleVaccinationDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Programar Vacuna'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredVaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = filteredVaccinations[index];
        return _buildVaccinationCard(vaccination, index);
      },
    );
  }

  Widget _buildVaccinationCard(Map<String, dynamic> vaccination, int index) {
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
                  onTap: () => _showVaccinationDetail(vaccination),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con nombre y estado
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                vaccination['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(vaccination['status'])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getStatusColor(vaccination['status'])
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(vaccination['status']),
                                    size: 16,
                                    color: _getStatusColor(vaccination['status']),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    vaccination['status'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(vaccination['status']),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Información de fechas
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Fecha aplicada',
                          vaccination['status'] == 'Aplicada'
                              ? _formatDate(vaccination['date'])
                              : 'Pendiente',
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildInfoRow(
                          Icons.schedule,
                          'Próxima aplicación',
                          _formatDate(vaccination['nextDate']),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildInfoRow(
                          Icons.local_hospital,
                          'Veterinario',
                          vaccination['veterinarian'],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildInfoRow(
                          Icons.location_on,
                          'Clínica',
                          vaccination['clinic'],
                        ),
                        
                        if (vaccination['notes'].isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.notes,
                                  size: 16,
                                  color: Color(0xFF7F8C8D),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    vaccination['notes'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF7F8C8D),
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

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showVaccinationDetail(Map<String, dynamic> vaccination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
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
                      Text(
                        'Detalle de Vacuna',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Información detallada
                      _buildDetailRow('Vacuna', vaccination['name']),
                      _buildDetailRow('Tipo', vaccination['type']),
                      _buildDetailRow('Estado', vaccination['status']),
                      _buildDetailRow('Lote', vaccination['batch']),
                      _buildDetailRow('Fecha aplicada', 
                          vaccination['status'] == 'Aplicada'
                              ? _formatDate(vaccination['date'])
                              : 'Pendiente'),
                      _buildDetailRow('Próxima aplicación', 
                          _formatDate(vaccination['nextDate'])),
                      _buildDetailRow('Veterinario', vaccination['veterinarian']),
                      _buildDetailRow('Clínica', vaccination['clinic']),
                      
                      if (vaccination['notes'].isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Notas adicionales:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vaccination['notes'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Botones de acción
                      if (vaccination['status'] == 'Próxima' || 
                          vaccination['status'] == 'Vencida') ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showScheduleVaccinationDialog();
                            },
                            icon: const Icon(Icons.schedule),
                            label: Text(vaccination['status'] == 'Vencida' 
                                ? 'Reagendar Vacuna'
                                : 'Programar Cita'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
                              foregroundColor: Colors.white,
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

  void _showScheduleVaccinationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Programar Vacuna',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: const Text(
          '¿Deseas programar una cita para aplicar esta vacuna?',
          style: TextStyle(
            color: Color(0xFF7F8C8D),
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
              // Navegar a pantalla de agendar cita
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Redirigiendo a agendar cita...'),
                  backgroundColor: Color(0xFF27AE60),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Agendar'),
          ),
        ],
      ),
    );
  }
}