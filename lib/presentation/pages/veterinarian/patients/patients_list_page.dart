import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

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
  String _searchQuery = '';
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];

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

  void _searchPatients(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = _allPatients;

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
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundShapes(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildModernAppBar(),
                    _buildSearchBar(),
                    Expanded(
                      child:
                          _isLoading
                              ? _buildLoadingState()
                              : _filteredPatients.isEmpty
                              ? _buildEmptyState()
                              : _buildPatientsList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: AppSizes.decorativeShapeXL,
            height: AppSizes.decorativeShapeXL,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(125),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: -80,
          child: Container(
            width: AppSizes.decorativeShapeL,
            height: AppSizes.decorativeShapeL,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(90),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -60,
          child: Container(
            width: AppSizes.decorativeShapeM,
            height: AppSizes.decorativeShapeM,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Mis Pacientes',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchPatients,
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar pacientes...',
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: AppColors.primary),
          hintStyle: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: AppSizes.spaceM),
          const Text(
            'Cargando pacientes...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return _buildPatientCard(patient);
      },
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/patient-history', arguments: patient);
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      image:
                          patient['profileImage'] != null
                              ? DecorationImage(
                                image: NetworkImage(patient['profileImage']),
                                fit: BoxFit.cover,
                              )
                              : null,
                      gradient:
                          patient['profileImage'] == null
                              ? AppColors.primaryGradient
                              : null,
                    ),
                    child:
                        patient['profileImage'] == null
                            ? const Icon(
                              Icons.pets_rounded,
                              color: AppColors.white,
                              size: 30,
                            )
                            : null,
                  ),
                  const SizedBox(width: AppSizes.spaceM),
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
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            _buildStatusBadge(patient['status']),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spaceS),
                        Text(
                          '${patient['breed']} • ${patient['age']} • ${patient['gender']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spaceXS),
                        Text(
                          'Propietario: ${patient['ownerName']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceM),
              Row(
                children: [
                  _buildInfoBadge(
                    Icons.access_time_rounded,
                    _formatTimeAgo(patient['lastVisit']),
                    AppColors.primary,
                  ),
                  const SizedBox(width: AppSizes.spaceS),
                  _buildInfoBadge(
                    Icons.medical_services_rounded,
                    '${patient['consultationsCount']} consultas',
                    AppColors.secondary,
                  ),
                  const SizedBox(width: AppSizes.spaceS),
                  _buildInfoBadge(
                    Icons.monitor_weight_rounded,
                    patient['weight'],
                    AppColors.accent,
                  ),
                ],
              ),
              if (patient['lastDiagnosis'] != null) ...[
                const SizedBox(height: AppSizes.spaceM),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medical_information_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSizes.spaceS),
                          const Text(
                            'Último diagnóstico:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceS),
                      Text(
                        patient['lastDiagnosis'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (patient['nextAppointment'] != null) ...[
                const SizedBox(height: AppSizes.spaceM),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    gradient: AppColors.orangeGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: AppSizes.spaceS),
                      Text(
                        'Próxima cita: ${_formatDate(patient['nextAppointment'])}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
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
        color = AppColors.success;
        break;
      case 'Seguimiento':
        color = AppColors.warning;
        break;
      case 'Inactivo':
        color = AppColors.textSecondary;
        break;
      default:
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingS,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSizes.spaceXS),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
      icon = Icons.search_off_rounded;
    } else {
      title = 'No tienes pacientes registrados';
      subtitle = 'Los pacientes aparecerán aquí después de su primera consulta';
      icon = Icons.pets_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(icon, size: 60, color: AppColors.white),
            ),
            const SizedBox(height: AppSizes.spaceL),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
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
