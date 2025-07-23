import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/injection/injection.dart';
import '../../../widgets/cards/veterinarian_card.dart';
import '../../../blocs/veterinarian/veterinarian_bloc.dart';
import '../../../blocs/veterinarian/veterinarian_event.dart';
import '../../../blocs/veterinarian/veterinarian_state.dart';

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
  bool _showAllVeterinarians = false;
  List<dynamic> _allVeterinarians = [];
  List<dynamic> _filteredVeterinarians = [];

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
    return BlocProvider<VeterinarianBloc>(
      create:
          (context) =>
              sl<VeterinarianBloc>()
                ..add(const SearchVeterinariansEvent(limit: 100)),
      child: Scaffold(
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
                                const SizedBox(height: AppSizes.spaceXL),
                                _buildVeterinariansSection(),
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
        onChanged: _performSearch,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, especialidad, ubicación...',
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
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
        ),
      ),
    );
  }

  Widget _buildVeterinariansSection() {
    return BlocBuilder<VeterinarianBloc, VeterinarianState>(
      builder: (context, state) {
        if (state is VeterinarianLoading) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is VeterinarianSearchSuccess) {
          _allVeterinarians = state.veterinarians;
          if (_filteredVeterinarians.isEmpty &&
              _searchController.text.isEmpty) {
            _filteredVeterinarians = _allVeterinarians;
          }

          final displayVets =
              _searchController.text.isNotEmpty
                  ? _filteredVeterinarians
                  : _allVeterinarians;
          final isSearching = _searchController.text.isNotEmpty;

          if (displayVets.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(displayVets.length, isSearching),
              const SizedBox(height: AppSizes.spaceM),
              _buildVeterinariansList(displayVets, isSearching),
            ],
          );
        }

        if (state is VeterinarianError) {
          return _buildErrorState(state.message);
        }

        return const SizedBox(height: 300);
      },
    );
  }

  Widget _buildSectionHeader(int count, bool isSearching) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSearching
                    ? 'Resultados de búsqueda'
                    : 'Veterinarios Disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$count veterinarios encontrados',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (!isSearching && count > 3)
            TextButton(
              onPressed:
                  () => Navigator.pushNamed(context, '/veterinarians-list'),
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
    );
  }

  Widget _buildVeterinariansList(
    List<dynamic> veterinarians,
    bool isSearching,
  ) {
    final displayVets =
        isSearching ? veterinarians : veterinarians.take(3).toList();

    if (isSearching) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        itemCount: displayVets.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceM),
        itemBuilder:
            (context, index) =>
                _buildVeterinarianCard(displayVets[index], false),
      );
    } else {
      return SizedBox(
        height: 280,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
          itemCount: displayVets.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSizes.spaceM),
          itemBuilder:
              (context, index) =>
                  _buildVeterinarianCard(displayVets[index], true),
        ),
      );
    }
  }

  Widget _buildVeterinarianCard(dynamic vet, bool isHorizontal) {
    return VeterinarianCard(
      veterinarian: {
        'id': vet.id,
        'name': vet.fullName,
        'specialty':
            vet.specialties.isNotEmpty
                ? vet.specialties.first
                : 'Medicina General',
        'clinic': 'Clínica ${vet.fullName}',
        'rating': 4.5,
        'experience': vet.experienceText,
        'distance': '2.5 km',
        'consultationFee': vet.consultationFee ?? 150,
        'available': true,
        'profileImage': vet.profilePhoto,
      },
      isHorizontal: isHorizontal,
      onTap:
          () => Navigator.pushNamed(
            context,
            '/veterinarian-profile',
            arguments: {'vetId': vet.id},
          ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.spaceL),
            Text(
              'No se encontraron veterinarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              'Intenta con otro término de búsqueda',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSizes.spaceL),
            Text(
              'Error al cargar veterinarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              message,
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVeterinarians = _allVeterinarians;
      } else {
        _filteredVeterinarians =
            _allVeterinarians.where((vet) {
              final name = vet.fullName.toLowerCase();
              final specialties = vet.specialties.join(' ').toLowerCase();
              final location = vet.location.toLowerCase();
              final searchTerm = query.toLowerCase();

              return name.contains(searchTerm) ||
                  specialties.contains(searchTerm) ||
                  location.contains(searchTerm);
            }).toList();
      }
    });
  }
}
