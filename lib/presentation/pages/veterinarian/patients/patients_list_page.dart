import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../data/datasources/pet/pet_remote_datasource.dart';
import '../../../../data/models/pet/pet_model.dart';
import '../../../../core/injection/injection.dart';

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
  List<PetModel> _allPatients = [];
  List<PetModel> _filteredPatients = [];

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

  Future<void> _loadPatients() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Obtener el ID del veterinario
      final vetId = await SharedPreferencesHelper.getVetId();
      if (vetId == null || vetId.isEmpty) {
        throw Exception('No se encontró el ID del veterinario');
      }

      // Obtener los pacientes desde la API
      final petDataSource = sl<PetRemoteDataSource>();
      final patients = await petDataSource.getVetPatients(vetId);

      if (mounted) {
        setState(() {
          _allPatients = patients;
          _filteredPatients = patients;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando pacientes: $e');
      if (mounted) {
        setState(() {
          _allPatients = [];
          _filteredPatients = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pacientes: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _searchPatients(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<PetModel> filtered = _allPatients;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((patient) {
        final searchLower = _searchQuery.toLowerCase();
        return patient.name.toLowerCase().contains(searchLower) ||
            patient.breed.toLowerCase().contains(searchLower);
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

  Widget _buildPatientCard(PetModel patient) {
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
                      image: patient.imageUrl != null && patient.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(patient.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: patient.imageUrl == null || patient.imageUrl!.isEmpty
                          ? AppColors.primaryGradient
                          : null,
                    ),
                    child: patient.imageUrl == null || patient.imageUrl!.isEmpty
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
                                patient.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            _buildStatusBadge(_getStatusText(patient.status)),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spaceS),
                        Text(
                          '${patient.breed} • ${_getTypeText(patient.type)} • ${_getGenderText(patient.gender)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spaceXS),
                        Text(
                          'Registrado: ${_formatTimeAgo(patient.createdAt ?? DateTime.now())}',
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
                    Icons.cake_rounded,
                    '${_getAge(patient.birthDate)} años',
                    AppColors.primary,
                  ),
                  const SizedBox(width: AppSizes.spaceS),
                  _buildInfoBadge(
                    Icons.pets_rounded,
                    _getTypeText(patient.type),
                    AppColors.secondary,
                  ),
                  const SizedBox(width: AppSizes.spaceS),
                  _buildInfoBadge(
                    Icons.verified_rounded,
                    _getStatusText(patient.status),
                    AppColors.accent,
                  ),
                ],
              ),
              if (patient.description != null && patient.description!.isNotEmpty) ...[
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
                            Icons.description_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSizes.spaceS),
                          const Text(
                            'Descripción:',
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
                        patient.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
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

  String _getStatusText(dynamic status) {
    if (status == null) return 'Sin estado';
    return status.toString().split('.').last.toLowerCase() == 'healthy' ? 'Saludable' : 
           status.toString().split('.').last.toLowerCase() == 'sick' ? 'Enfermo' : 
           status.toString().split('.').last.toLowerCase() == 'injured' ? 'Herido' :
           status.toString();
  }

  String _getTypeText(dynamic type) {
    if (type == null) return 'Otro';
    final typeStr = type.toString().split('.').last.toLowerCase();
    return typeStr == 'dog' ? 'Perro' : 
           typeStr == 'cat' ? 'Gato' : 
           typeStr == 'bird' ? 'Ave' :
           typeStr == 'rabbit' ? 'Conejo' :
           typeStr;
  }

  String _getGenderText(dynamic gender) {
    if (gender == null) return 'No especificado';
    final genderStr = gender.toString().split('.').last.toLowerCase();
    return genderStr == 'male' ? 'Macho' : 
           genderStr == 'female' ? 'Hembra' : 
           genderStr;
  }

  int _getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
