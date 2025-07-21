import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../widgets/cards/veterinarian_card.dart';

class SearchVeterinariansPage extends StatefulWidget {
  const SearchVeterinariansPage({super.key});

  @override
  State<SearchVeterinariansPage> createState() =>
      _SearchVeterinariansPageState();
}

class _SearchVeterinariansPageState extends State<SearchVeterinariansPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialty = 'Todas las especialidades';
  String _selectedLocation = 'Cualquier ubicación';
  bool _isLoading = false;

  final List<String> _specialties = [
    'Todas las especialidades',
    'Medicina General',
    'Cirugía',
    'Cardiología',
    'Dermatología',
    'Oftalmología',
    'Neurología',
    'Emergencias',
    'Exóticos',
  ];

  final List<String> _locations = [
    'Cualquier ubicación',
    'Cerca de mí',
    'Centro',
    'Norte',
    'Sur',
    'Este',
    'Oeste',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFBDE3FF), Color(0xFFE8F5E8), Color(0xFFE5F3FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildDecorativeShapes(),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildModernAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSizes.spaceL),
                              _buildSearchField(),
                              const SizedBox(height: AppSizes.spaceL),
                              _buildFilters(),
                              const SizedBox(height: AppSizes.spaceXL),
                              _buildSearchButton(),
                              const SizedBox(height: AppSizes.spaceXL),
                              _buildFeaturedVeterinarians(),
                              const SizedBox(height: AppSizes.spaceXL),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeShapes() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        Positioned(
          top: 150,
          left: -80,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(75),
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
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buscar Veterinarios',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Encuentra el especialista ideal',
                  style: TextStyle(fontSize: 14, color: AppColors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, especialidad...',
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros de Búsqueda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceM),
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  'Especialidad',
                  _selectedSpecialty,
                  _specialties,
                  (value) => setState(() => _selectedSpecialty = value!),
                ),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: _buildDropdownFilter(
                  'Ubicación',
                  _selectedLocation,
                  _locations,
                  (value) => setState(() => _selectedLocation = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
              ),
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              items:
                  options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    final quickFilters = [
      {'name': 'Medicina General', 'icon': Icons.local_hospital},
      {'name': 'Cirugía', 'icon': Icons.medical_services},
      {'name': 'Emergencias', 'icon': Icons.emergency},
      {'name': 'Vacunación', 'icon': Icons.vaccines},
      {'name': 'Cerca de mí', 'icon': Icons.location_on},
      {'name': 'Mejor valorados', 'icon': Icons.star},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
          child: Text(
            'Filtros Rápidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceM),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
            itemCount: quickFilters.length,
            itemBuilder: (context, index) {
              final filter = quickFilters[index];
              return Container(
                margin: EdgeInsets.only(
                  right: index < quickFilters.length - 1 ? AppSizes.spaceM : 0,
                ),
                child: _buildQuickFilterCard(
                  filter['name'] as String,
                  filter['icon'] as IconData,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilterCard(String label, IconData icon) {
    return GestureDetector(
      onTap: () => _applyQuickFilter(label),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 28),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    final canSearch =
        _searchController.text.isNotEmpty ||
        _selectedSpecialty != 'Todas las especialidades' ||
        _selectedLocation != 'Cualquier ubicación';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      height: 56,
      decoration: BoxDecoration(
        gradient:
            canSearch
                ? AppColors.primaryGradient
                : LinearGradient(
                  colors: [
                    AppColors.textSecondary.withOpacity(0.3),
                    AppColors.textSecondary.withOpacity(0.3),
                  ],
                ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow:
            canSearch
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
                : null,
      ),
      child: ElevatedButton(
        onPressed: canSearch && !_isLoading ? _performSearch : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    strokeWidth: 2.5,
                  ),
                )
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded, size: 24),
                    SizedBox(width: AppSizes.spaceS),
                    Text(
                      'Buscar Veterinarios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildFeaturedVeterinarians() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Veterinarios Destacados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToVeterinariansList(),
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spaceM),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
            children: [
              VeterinarianCard(
                veterinarian: {
                  'id': '1',
                  'name': 'Dr. María González',
                  'specialty': 'Medicina General',
                  'clinic': 'Clínica VetCare',
                  'rating': 4.9,
                  'experience': '8 años',
                  'distance': '1.2 km',
                  'consultationFee': 150,
                  'available': true,
                  'profileImage': null,
                },
                isHorizontal: true,
              ),
              const SizedBox(width: AppSizes.spaceM),
              VeterinarianCard(
                veterinarian: {
                  'id': '2',
                  'name': 'Dr. Carlos Ruiz',
                  'specialty': 'Cirugía',
                  'clinic': 'Hospital Animal Plus',
                  'rating': 4.8,
                  'experience': '12 años',
                  'distance': '2.1 km',
                  'consultationFee': 200,
                  'available': true,
                  'profileImage': null,
                },
                isHorizontal: true,
              ),
              const SizedBox(width: AppSizes.spaceM),
              VeterinarianCard(
                veterinarian: {
                  'id': '3',
                  'name': 'Dra. Ana Pérez',
                  'specialty': 'Cardiología',
                  'clinic': 'Centro Veterinario Integral',
                  'rating': 4.7,
                  'experience': '6 años',
                  'distance': '3.5 km',
                  'consultationFee': 180,
                  'available': false,
                  'profileImage': null,
                },
                isHorizontal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      switch (filter) {
        case 'Medicina General':
        case 'Cirugía':
        case 'Emergencias':
        case 'Vacunación':
          _selectedSpecialty = filter;
          break;
        case 'Cerca de mí':
          _selectedLocation = filter;
          break;
        case 'Mejor valorados':
          // Lógica para ordenar por rating
          break;
      }
    });
  }

  void _performSearch() {
    setState(() => _isLoading = true);

    final searchParams = {
      'query': _searchController.text,
      'specialty': _selectedSpecialty,
      'location': _selectedLocation,
    };

    // Simular búsqueda
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      _navigateToVeterinariansList(searchParams);
    });
  }

  void _navigateToVeterinariansList([Map<String, dynamic>? params]) {
    Navigator.pushNamed(context, '/veterinarians-list', arguments: params);
  }
}
