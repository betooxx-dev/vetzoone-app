import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  String _selectedFilter = 'Todos';
  String _searchQuery = '';
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'Todos',
    'Recientes',
    'Seguimiento',
    'Críticos',
    'Inactivos',
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
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
    
    _loadPatients();
    _animationController.forward();
  }

  void _loadPatients() {
    // Simular carga de datos
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _allPatients = [
            {
              'id': '1',
              'name': 'Luna',
              'species': 'Perro',
              'breed': 'Golden Retriever',
              'age': '3 años',
              'gender': 'Hembra',
              'weight': '28.5 kg',
              'ownerName': 'María López',
              'ownerPhone': '+52 961 123 4567',
              'lastVisit': DateTime.now().subtract(const Duration(days: 15)),
              'nextAppointment': DateTime.now().add(const Duration(days: 30)),
              'status': 'Activo',
              'priority': 'Normal',
              'consultationsCount': 8,
              'profileImage': 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=400&fit=crop&crop=face',
              'medicalNotes': 'Paciente cooperativo. Historial de alergias alimentarias.',
              'conditions': ['Alergia alimentaria'],
              'lastDiagnosis': 'Revisión de rutina - Estado excelente',
            },
            {
              'id': '2',
              'name': 'Milo',
              'species': 'Gato',
              'breed': 'Persa',
              'age': '5 años',
              'gender': 'Macho',
              'weight': '4.2 kg',
              'ownerName': 'Carlos Hernández',
              'ownerPhone': '+52 961 987 6543',
              'lastVisit': DateTime.now().subtract(const Duration(days: 7)),
              'nextAppointment': DateTime.now().add(const Duration(days: 14)),
              'status': 'Seguimiento',
              'priority': 'Alta',
              'consultationsCount': 12,
              'profileImage': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=400&fit=crop&crop=face',
              'medicalNotes': 'Tratamiento post-quirúrgico. Requiere seguimiento.',
              'conditions': ['Post-cirugía', 'Diabetes'],
              'lastDiagnosis': 'Recuperación post-cirugía de cálculos urinarios',
            },
            {
              'id': '3',
              'name': 'Bella',
              'species': 'Perro',
              'breed': 'Bulldog Francés',
              'age': '2 años',
              'gender': 'Hembra',
              'weight': '12.1 kg',
              'ownerName': 'Ana García',
              'ownerPhone': '+52 961 456 7890',
              'lastVisit': DateTime.now().subtract(const Duration(days: 45)),
              'nextAppointment': null,
              'status': 'Inactivo',
              'priority': 'Baja',
              'consultationsCount': 3,
              'profileImage': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=400&fit=crop&crop=face',
              'medicalNotes': 'Problemas respiratorios típicos de la raza.',
              'conditions': ['Problemas respiratorios'],
              'lastDiagnosis': 'Consulta de rutina - Recomendaciones preventivas',
            },
            {
              'id': '4',
              'name': 'Rocky',
              'species': 'Perro',
              'breed': 'Pastor Alemán',
              'age': '7 años',
              'gender': 'Macho',
              'weight': '32.8 kg',
              'ownerName': 'Roberto Silva',
              'ownerPhone': '+52 961 321 6547',
              'lastVisit': DateTime.now().subtract(const Duration(days: 3)),
              'nextAppointment': DateTime.now().add(const Duration(days: 7)),
              'status': 'Crítico',
              'priority': 'Crítica',
              'consultationsCount': 15,
              'profileImage': 'https://images.unsplash.com/photo-1551717743-49959800b1f6?w=400&h=400&fit=crop&crop=face',
              'medicalNotes': 'Displasia de cadera. Tratamiento de dolor crónico.',
              'conditions': ['Displasia de cadera', 'Artritis'],
              'lastDiagnosis': 'Exacerbación de displasia de cadera',
            },
            {
              'id': '5',
              'name': 'Whiskers',
              'species': 'Gato',
              'breed': 'Maine Coon',
              'age': '4 años',
              'gender': 'Macho',
              'weight': '6.8 kg',
              'ownerName': 'Laura Martínez',
              'ownerPhone': '+52 961 789 0123',
              'lastVisit': DateTime.now().subtract(const Duration(days: 2)),
              'nextAppointment': DateTime.now().add(const Duration(days: 21)),
              'status': 'Reciente',
              'priority': 'Normal',
              'consultationsCount': 6,
              'profileImage': 'https://images.unsplash.com/photo-1596854407944-bf87f6fdd49e?w=400&h=400&fit=crop&crop=face',
              'medicalNotes': 'Paciente muy tranquilo. Vacunación al día.',
              'conditions': [],
              'lastDiagnosis': 'Control preventivo - Estado óptimo',
            },
          ];
          _filteredPatients = _allPatients;
          _isLoading = false;
        });
      }
    });
  }

  void _filterPatients(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _searchPatients(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = _allPatients;

    // Aplicar filtro por categoría
    if (_selectedFilter != 'Todos') {
      filtered = filtered.where((patient) {
        switch (_selectedFilter) {
          case 'Recientes':
            final daysSinceLastVisit = DateTime.now()
                .difference(patient['lastVisit'] as DateTime)
                .inDays;
            return daysSinceLastVisit <= 7;
          case 'Seguimiento':
            return patient['status'] == 'Seguimiento';
          case 'Críticos':
            return patient['status'] == 'Crítico';
          case 'Inactivos':
            return patient['status'] == 'Inactivo';
          default:
            return true;
        }
      }).toList();
    }

    // Aplicar búsqueda por texto
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((patient) {
        final searchLower = _searchQuery.toLowerCase();
        return patient['name'].toString().toLowerCase().contains(searchLower) ||
               patient['ownerName'].toString().toLowerCase().contains(searchLower) ||
               patient['breed'].toString().toLowerCase().contains(searchLower) ||
               patient['species'].toString().toLowerCase().contains(searchLower);
      }).toList();
    }

    _filteredPatients = filtered;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'crítica':
        return Colors.red;
      case 'alta':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'baja':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'seguimiento':
        return Colors.orange;
      case 'crítico':
        return Colors.red;
      case 'reciente':
        return Colors.blue;
      case 'inactivo':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Ayer';
    } else if (difference < 7) {
      return 'Hace $difference días';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return 'Hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else {
      final months = (difference / 30).floor();
      return 'Hace $months mes${months > 1 ? 'es' : ''}';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Mis Pacientes',
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
            icon: const Icon(Icons.search, color: Color(0xFF3498DB)),
            onPressed: () {
              // Expandir barra de búsqueda
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF3498DB)),
            onPressed: () {
              _showFilterBottomSheet();
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
              // Estadísticas rápidas
              _buildStatsSection(),
              
              // Barra de búsqueda
              _buildSearchBar(),
              
              // Filtros
              _buildFiltersSection(),
              
              // Lista de pacientes
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredPatients.isEmpty
                        ? _buildEmptyState()
                        : _buildPatientsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final totalPatients = _allPatients.length;
    final activePatients = _allPatients.where((p) => p['status'] == 'Activo').length;
    final criticalPatients = _allPatients.where((p) => p['status'] == 'Crítico').length;
    final recentPatients = _allPatients.where((p) {
      final daysSinceLastVisit = DateTime.now()
          .difference(p['lastVisit'] as DateTime)
          .inDays;
      return daysSinceLastVisit <= 7;
    }).length;

    return Container(
      margin: const EdgeInsets.all(16),
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
          _buildStatItem('Total', totalPatients.toString(), Colors.blue),
          _buildStatItem('Activos', activePatients.toString(), Colors.green),
          _buildStatItem('Críticos', criticalPatients.toString(), Colors.red),
          _buildStatItem('Recientes', recentPatients.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7F8C8D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchPatients,
        decoration: const InputDecoration(
          hintText: 'Buscar por nombre, dueño, raza...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFF7F8C8D)),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => _filterPatients(filter),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
              checkmarkColor: const Color(0xFF3498DB),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF3498DB) : const Color(0xFF7F8C8D),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF3498DB) : const Color(0xFFE0E0E0),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return _buildPatientCard(patient, index);
      },
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient, int index) {
    return Container(
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
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(
              context,
              '/patient-history',
              arguments: patient,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header con foto y info básica
                Row(
                  children: [
                    // Foto del paciente
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _getPriorityColor(patient['priority']),
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(27),
                        child: Image.network(
                          patient['profileImage'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF0F0F0),
                              child: const Icon(
                                Icons.pets,
                                color: Color(0xFF7F8C8D),
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Info principal
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
                                    fontSize: 18,
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
                                    fontSize: 10,
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
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dueño: ${patient['ownerName']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF95A5A6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Info adicional
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.access_time,
                      'Última visita: ${_formatDate(patient['lastVisit'])}',
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.medical_services,
                      '${patient['consultationsCount']} consultas',
                      Colors.green,
                    ),
                  ],
                ),
                
                if (patient['conditions'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (patient['conditions'] as List<String>).map((condition) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          condition,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
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
            Icons.pets_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron pacientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Intenta con otros términos de búsqueda'
                : 'Los pacientes aparecerán aquí después de su primera consulta',
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

  void _showFilterBottomSheet() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar Pacientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              ...(_filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return ListTile(
                  title: Text(filter),
                  leading: Radio<String>(
                    value: filter,
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      _filterPatients(value!);
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    _filterPatients(filter);
                    Navigator.pop(context);
                  },
                );
              }).toList()),
            ],
          ),
        );
      },
    );
  }
}