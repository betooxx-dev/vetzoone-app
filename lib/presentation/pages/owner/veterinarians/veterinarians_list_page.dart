import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../widgets/cards/veterinarian_card.dart';

class VeterinariansListPage extends StatefulWidget {
  const VeterinariansListPage({super.key});

  @override
  State<VeterinariansListPage> createState() => _VeterinariansListPageState();
}

class _VeterinariansListPageState extends State<VeterinariansListPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _veterinarians = [
    {
      'id': '1',
      'name': 'Dra. María González',
      'specialty': 'Medicina Interna',
      'clinic': 'Clínica VetCare',
      'rating': 4.8,
      'experience': '8 años',
      'distance': '1.2 km',
      'consultationFee': 45,
      'available': true,
      'profileImage': null,
    },
    {
      'id': '2',
      'name': 'Dr. Carlos Mendoza',
      'specialty': 'Cirugía',
      'clinic': 'Hospital Veterinario Central',
      'rating': 4.9,
      'experience': '12 años',
      'distance': '2.1 km',
      'consultationFee': 60,
      'available': true,
      'profileImage': null,
    },
    {
      'id': '3',
      'name': 'Dra. Ana López',
      'specialty': 'Dermatología',
      'clinic': 'Clínica PetSkin',
      'rating': 4.7,
      'experience': '6 años',
      'distance': '3.5 km',
      'consultationFee': 50,
      'available': false,
      'profileImage': null,
    },
    {
      'id': '4',
      'name': 'Dr. Roberto Silva',
      'specialty': 'Cardiología',
      'clinic': 'Centro Veterinario Especializado',
      'rating': 4.9,
      'experience': '15 años',
      'distance': '4.2 km',
      'consultationFee': 70,
      'available': true,
      'profileImage': null,
    },
  ];

  List<Map<String, dynamic>> get _filteredVeterinarians {
    return _veterinarians.where((vet) {
      final matchesSearch =
          vet['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          vet['specialty'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesFilter =
          _selectedFilter == 'all' ||
          (_selectedFilter == 'available' && vet['available']);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
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
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Fondo decorativo similar al dashboard
          _buildDecorativeBackground(),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildSearchBar(),
                _buildFilters(),
                Expanded(child: _buildListView()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeBackground() {
    return Stack(
      children: [
        // Fondo base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.backgroundLight, AppColors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Formas decorativas
        Positioned(
          top: -50,
          right: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(75),
            ),
          ),
        ),

        Positioned(
          top: 100,
          left: -40,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),

        Positioned(
          bottom: 200,
          right: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          const Expanded(
            child: Text(
              'Veterinarios',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Buscar veterinarios...',
            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.textSecondary,
                      ),
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingM,
        AppSizes.paddingL,
        AppSizes.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_filteredVeterinarians.length} veterinarios encontrados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceS),
          Row(
            children: [
              _buildFilterChip('Todos', 'all'),
              const SizedBox(width: AppSizes.spaceS),
              _buildFilterChip('Disponibles', 'available'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color:
                isSelected
                    ? Colors.transparent
                    : AppColors.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_filteredVeterinarians.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        0,
        AppSizes.paddingL,
        AppSizes.paddingL,
      ),
      itemCount: _filteredVeterinarians.length,
      itemBuilder: (context, index) {
        final vet = _filteredVeterinarians[index];
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
                  child: VeterinarianCard(
                    veterinarian: vet,
                    isHorizontal: false,
                    onTap: () => _navigateToVeterinarianProfile(vet),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),
            const Text(
              'No se encontraron veterinarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              'Intenta ajustar los filtros de búsqueda\no busca en una ubicación diferente',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToVeterinarianProfile(Map<String, dynamic> vet) {
    Navigator.pushNamed(context, '/veterinarian-profile', arguments: vet);
  }
}
