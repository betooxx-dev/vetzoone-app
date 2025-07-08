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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadPatients();
    _animationController.forward();
  }

  void _loadPatients() {
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
              'profileImage':
                  'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=400&fit=crop&crop=face',
              'medicalNotes':
                  'Paciente cooperativo. Historial de alergias alimentarias. Vacunación al día.',
              'conditions': ['Alergia alimentaria'],
              'lastDiagnosis': 'Control preventivo - Estado óptimo',
            },
            {
              'id': '2',
              'name': 'Max',
              'species': 'Perro',
              'breed': 'Labrador',
              'age': '5 años',
              'gender': 'Macho',
              'weight': '32.0 kg',
              'ownerName': 'Carlos Ruiz',
              'ownerPhone': '+52 961 234 5678',
              'lastVisit': DateTime.now().subtract(const Duration(days: 3)),
              'nextAppointment': DateTime.now().add(const Duration(days: 21)),
              'status': 'Seguimiento',
              'priority': 'Alta',
              'consultationsCount': 12,
              'profileImage':
                  'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400&h=400&fit=crop&crop=face',
              'medicalNotes':
                  'Post-cirugía de cadera. Requiere seguimiento continuo y fisioterapia.',
              'conditions': ['Displasia de cadera', 'Post-cirugía'],
              'lastDiagnosis': 'Recuperación post-cirugía - Progreso favorable',
            },
            {
              'id': '3',
              'name': 'Milo',
              'species': 'Gato',
              'breed': 'Persa',
              'age': '2 años',
              'gender': 'Macho',
              'weight': '4.2 kg',
              'ownerName': 'Ana García',
              'ownerPhone': '+52 961 345 6789',
              'lastVisit': DateTime.now().subtract(const Duration(days: 60)),
              'nextAppointment': DateTime.now().add(const Duration(days: 10)),
              'status': 'Crítico',
              'priority': 'Crítica',
              'consultationsCount': 6,
              'profileImage':
                  'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=400&fit=crop&crop=face',
              'medicalNotes':
                  'Problemas respiratorios crónicos. Monitoreo constante requerido.',
              'conditions': ['Asma felino', 'Problemas respiratorios'],
              'lastDiagnosis': 'Crisis asmática - Tratamiento intensivo',
            },
            {
              'id': '4',
              'name': 'Bella',
              'species': 'Perro',
              'breed': 'Pastor Alemán',
              'age': '7 años',
              'gender': 'Hembra',
              'weight': '26.8 kg',
              'ownerName': 'Jorge Méndez',
              'ownerPhone': '+52 961 456 7890',
              'lastVisit': DateTime.now().subtract(const Duration(days: 120)),
              'nextAppointment': null,
              'status': 'Inactivo',
              'priority': 'Baja',
              'consultationsCount': 15,
              'profileImage':
                  'https://images.unsplash.com/photo-1605568427561-40dd23c2acea?w=400&h=400&fit=crop&crop=face',
              'medicalNotes':
                  'Paciente senior. Última consulta hace 4 meses. Recordar contactar.',
              'conditions': [],
              'lastDiagnosis': 'Control geriátrico - Estado general bueno',
            },
            {
              'id': '5',
              'name': 'Rocky',
              'species': 'Perro',
              'breed': 'Bulldog',
              'age': '4 años',
              'gender': 'Macho',
              'weight': '22.5 kg',
              'ownerName': 'Sofía Morales',
              'ownerPhone': '+52 961 567 8901',
              'lastVisit': DateTime.now().subtract(const Duration(days: 2)),
              'nextAppointment': DateTime.now().add(const Duration(days: 14)),
              'status': 'Activo',
              'priority': 'Normal',
              'consultationsCount': 9,
              'profileImage':
                  'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&h=400&fit=crop&crop=face',
              'medicalNotes':
                  'Paciente cooperativo. Historial de alergias alimentarias. Vacunación al día.',
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

    if (_selectedFilter != 'Todos') {
      filtered =
          filtered.where((patient) {
            switch (_selectedFilter) {
              case 'Recientes':
                final daysSinceLastVisit =
                    DateTime.now()
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

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((patient) {
            final searchLower = _searchQuery.toLowerCase();
            return patient['name'].toString().toLowerCase().contains(
                  searchLower,
                ) ||
                patient['ownerName'].toString().toLowerCase().contains(
                  searchLower,
                ) ||
                patient['breed'].toString().toLowerCase().contains(
                  searchLower,
                ) ||
                patient['species'].toString().toLowerCase().contains(
                  searchLower,
                );
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
            onPressed: () {},
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
              _buildSearchBar(),
              _buildFiltersSection(),
              Expanded(
                child:
                    _isLoading
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
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'Buscar pacientes...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFF7F8C8D)),
          hintStyle: TextStyle(color: Color(0xFF95A5A6)),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = filter == _selectedFilter;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => _filterPatients(filter),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF3498DB).withOpacity(0.1),
              checkmarkColor: const Color(0xFF3498DB),
              labelStyle: TextStyle(
                color:
                    isSelected
                        ? const Color(0xFF3498DB)
                        : const Color(0xFF7F8C8D),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    isSelected
                        ? const Color(0xFF3498DB)
                        : const Color(0xFFE0E0E0),
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
                Row(
                  children: [
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
                                  color: _getStatusColor(
                                    patient['status'],
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
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
                    children:
                        (patient['conditions'] as List<String>).map((
                          condition,
                        ) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              condition,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],

                if (patient['medicalNotes'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      patient['medicalNotes'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                        height: 1.4,
                      ),
                    ),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    if (_searchQuery.isNotEmpty) {
      title = 'No se encontraron pacientes';
      subtitle = 'Intenta con otros términos de búsqueda';
      icon = Icons.search_off;
    } else if (_selectedFilter != 'Todos') {
      title = 'No hay pacientes $_selectedFilter';
      subtitle = 'Cambia el filtro para ver más pacientes';
      icon = Icons.filter_list_off;
    } else {
      title = 'No tienes pacientes registrados';
      subtitle = 'Los pacientes aparecerán aquí después de su primera consulta';
      icon = Icons.pets_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(icon, size: 60, color: const Color(0xFF3498DB)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Filtrar pacientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                ..._filterOptions.map((filter) {
                  return ListTile(
                    title: Text(filter),
                    trailing:
                        _selectedFilter == filter
                            ? const Icon(Icons.check, color: Color(0xFF3498DB))
                            : null,
                    onTap: () {
                      _filterPatients(filter);
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }
}
