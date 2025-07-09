import 'package:flutter/material.dart';

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

  final _searchController = TextEditingController();
  bool _isLoading = true;
  String _selectedFilter = 'Todos';
  String _searchQuery = '';
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];

  final List<String> _filterOptions = [
    'Todos',
    'Recientes',
    'Seguimiento',
    'Activos',
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
      begin: const Offset(0, 0.1),
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
              'name': 'Max',
              'species': 'Perro',
              'breed': 'Golden Retriever',
              'age': '5 años',
              'gender': 'Macho',
              'weight': '32.5 kg',
              'ownerName': 'Ana María López',
              'ownerPhone': '+52 961 123 4567',
              'lastVisit': DateTime.now().subtract(const Duration(days: 15)),
              'nextAppointment': DateTime.now().add(const Duration(days: 7)),
              'status': 'Activo',
              'priority': 'Normal',
              'consultationsCount': 12,
              'profileImage':
                  'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=400&fit=crop&crop=face',
              'medicalNotes':
                  'Paciente muy cooperativo. Responde bien a tratamientos. Dueña muy responsable con seguimientos.',
              'conditions': ['Displasia de cadera leve'],
              'lastDiagnosis': 'Control rutinario - Estado general excelente',
            },
            {
              'id': '2',
              'name': 'Luna',
              'species': 'Gato',
              'breed': 'Siamés',
              'age': '3 años',
              'gender': 'Hembra',
              'weight': '4.2 kg',
              'ownerName': 'Carlos Mendoza',
              'ownerPhone': '+52 961 234 5678',
              'lastVisit': DateTime.now().subtract(const Duration(days: 8)),
              'nextAppointment': DateTime.now().add(const Duration(days: 30)),
              'status': 'Seguimiento',
              'priority': 'Alta',
              'consultationsCount': 8,
              'profileImage':
                  'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=400&fit=crop&crop=face',
              'medicalNotes':
                  'Gata nerviosa durante consultas. Requiere manejo cuidadoso. Historial de problemas urinarios.',
              'conditions': ['Cistitis recurrente'],
              'lastDiagnosis': 'Cistitis tratada - En observación',
            },
            {
              'id': '3',
              'name': 'Buddy',
              'species': 'Perro',
              'breed': 'Mestizo',
              'age': '2 años',
              'gender': 'Macho',
              'weight': '18.0 kg',
              'ownerName': 'Patricia Ruiz',
              'ownerPhone': '+52 961 345 6789',
              'lastVisit': DateTime.now().subtract(const Duration(days: 3)),
              'nextAppointment': null,
              'status': 'Activo',
              'priority': 'Normal',
              'consultationsCount': 5,
              'profileImage':
                  'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400&h=400&fit=crop&crop=face',
              'medicalNotes':
                  'Perro joven muy enérgico. Dueña nueva, necesita educación sobre cuidados preventivos.',
              'conditions': [],
              'lastDiagnosis': 'Vacunación completa - Estado óptimo',
            },
            {
              'id': '4',
              'name': 'Mimi',
              'species': 'Gato',
              'breed': 'Persa',
              'age': '8 años',
              'gender': 'Hembra',
              'weight': '5.8 kg',
              'ownerName': 'Roberto García',
              'ownerPhone': '+52 961 456 7890',
              'lastVisit': DateTime.now().subtract(const Duration(days: 120)),
              'nextAppointment': DateTime.now().add(const Duration(days: 14)),
              'status': 'Inactivo',
              'priority': 'Baja',
              'consultationsCount': 15,
              'profileImage':
                  'https://images.unsplash.com/photo-1526336024174-e58f5cdd8e13?w=400&h=400&fit=crop&crop=face',
              'medicalNotes':
                  'Última consulta hace 4 meses. Recordar contactar.',
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
              case 'Activos':
                return patient['status'] == 'Activo';
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
            return patient['name'].toLowerCase().contains(searchLower) ||
                patient['breed'].toLowerCase().contains(searchLower) ||
                patient['ownerName'].toLowerCase().contains(searchLower);
          }).toList();
    }

    _filteredPatients = filtered;
  }

  String _formatTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date).inDays;
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        return _buildPatientCard(patient);
      },
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
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
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/patient-history', arguments: patient);
        },
        borderRadius: BorderRadius.circular(16),
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
                      borderRadius: BorderRadius.circular(12),
                      image:
                          patient['profileImage'] != null
                              ? DecorationImage(
                                image: NetworkImage(patient['profileImage']),
                                fit: BoxFit.cover,
                              )
                              : null,
                      color:
                          patient['profileImage'] == null
                              ? const Color(0xFF3498DB).withOpacity(0.1)
                              : null,
                    ),
                    child:
                        patient['profileImage'] == null
                            ? const Icon(
                              Icons.pets,
                              color: Color(0xFF3498DB),
                              size: 30,
                            )
                            : null,
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
                            _buildStatusBadge(patient['status']),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patient['breed']} • ${patient['age']} • ${patient['gender']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Propietario: ${patient['ownerName']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                  _buildInfoBadge(
                    Icons.access_time,
                    _formatTimeAgo(patient['lastVisit']),
                    const Color(0xFF3498DB),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoBadge(
                    Icons.medical_services,
                    '${patient['consultationsCount']} consultas',
                    const Color(0xFF27AE60),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoBadge(
                    Icons.monitor_weight,
                    patient['weight'],
                    const Color(0xFF9B59B6),
                  ),
                ],
              ),
              if (patient['lastDiagnosis'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Último diagnóstico:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient['lastDiagnosis'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (patient['nextAppointment'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF27AE60).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF27AE60),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Próxima cita: ${_formatDate(patient['nextAppointment'])}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF27AE60),
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
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Activo':
        color = const Color(0xFF27AE60);
        break;
      case 'Seguimiento':
        color = const Color(0xFFF39C12);
        break;
      case 'Inactivo':
        color = const Color(0xFF95A5A6);
        break;
      default:
        color = const Color(0xFF3498DB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
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
    return '${date.day} ${months[date.month - 1]}';
  }
}
