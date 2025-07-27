import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/veterinary_constants.dart';
import '../../../../core/injection/injection.dart';
import '../../../widgets/cards/veterinarian_card.dart';
import '../../../blocs/veterinarian/veterinarian_bloc.dart';
import '../../../blocs/veterinarian/veterinarian_event.dart';
import '../../../blocs/veterinarian/veterinarian_state.dart';

// PASO 1: La página principal ahora solo se encarga de PROVEER el Bloc.
class SearchVeterinariansPage extends StatelessWidget {
  const SearchVeterinariansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VeterinarianBloc>(
      create:
          (context) =>
              sl<VeterinarianBloc>()..add(
                SearchVeterinariansEvent(
                  limit: 100,
                  location: VeterinaryConstants.getLocationForApi(VeterinaryConstants.chiapasLocations.first),
                  specialty: VeterinaryConstants.getSpecialtyForApi(VeterinaryConstants.veterinarySpecialties.first),
                ),
              ),
      child: const _SearchVeterinariansView(),
    );
  }
}

// PASO 2: Un nuevo widget interno contiene TODA la lógica y la UI.
class _SearchVeterinariansView extends StatefulWidget {
  const _SearchVeterinariansView();

  @override
  State<_SearchVeterinariansView> createState() =>
      _SearchVeterinariansViewState();
}

class _SearchVeterinariansViewState extends State<_SearchVeterinariansView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();

  String _selectedLocation = VeterinaryConstants.chiapasLocations.first;
  String _selectedSpecialty = VeterinaryConstants.veterinarySpecialties.first;

  bool _isSearching = false;

  Timer? _searchDebounce;

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
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PASO 3: El BlocProvider se ha ido de aquí. Ahora este widget es un hijo y puede acceder al Bloc.
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
                    _isSearching
                        ? _buildSearchResultsAppBar()
                        : _buildModernAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_isSearching) ...[
                                const SizedBox(height: AppSizes.spaceL),
                                _buildSearchField(),
                                const SizedBox(height: AppSizes.spaceM),
                                _buildFilters(),
                                const SizedBox(height: AppSizes.spaceM),
                                _buildSymptomsSearchButton(),
                                const SizedBox(height: AppSizes.spaceXL),
                              ],
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
    );
  }

  // ... TODOS LOS DEMÁS MÉTODOS HELPER PERMANECEN EXACTAMENTE IGUALES ...
  // (Pégalos aquí sin cambios)

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
          if (Navigator.canPop(context))
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
                onPressed: () {
                  if (_isSearching) {
                    _startNewSearch();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          SizedBox(
            width:
                Navigator.canPop(context) ? AppSizes.spaceM : AppSizes.spaceM,
          ),
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

  Widget _buildSearchResultsAppBar() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
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
              onPressed: _startNewSearch,
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultados de Búsqueda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Veterinarios encontrados',
                  style: TextStyle(fontSize: 14, color: AppColors.white),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
              onPressed: _startNewSearch,
              tooltip: 'Nueva Búsqueda',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 56,
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
        onChanged: (value) {
          // Solo actualizar el estado, no buscar automáticamente
          setState(() {});
        },
        onSubmitted: (value) {
          // Buscar cuando el usuario presiona Enter
          _performManualSearch();
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre... (selecciona filtros y presiona 🔍)',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _resetToInitialState();
                  },
                ),
              // Botón de búsqueda principal
              Container(
                margin: const EdgeInsets.only(right: AppSizes.paddingS),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                  onPressed: _performManualSearch,
                  tooltip: 'Buscar veterinarios',
                ),
              ),
            ],
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildLocationFilter()),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(child: _buildSpecialtyFilter()),
            ],
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: AppSizes.spaceS),
            _buildClearFiltersButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLocation,
          isExpanded: true,
          icon: const Icon(
            Icons.location_on_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items:
              VeterinaryConstants.chiapasLocations.map((String location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          location == VeterinaryConstants.chiapasLocations.first
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedLocation = newValue;
              });
              // Eliminado: _performFilteredSearch() - ahora solo actualiza el estado
            }
          },
        ),
      ),
    );
  }

  Widget _buildSpecialtyFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSpecialty,
          isExpanded: true,
          icon: const Icon(
            Icons.medical_services_outlined,
            color: AppColors.accent,
            size: 18,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items:
              VeterinaryConstants.veterinarySpecialties.map((String specialty) {
                return DropdownMenuItem<String>(
                  value: specialty,
                  child: Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          specialty ==
                                  VeterinaryConstants
                                      .veterinarySpecialties
                                      .first
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedSpecialty = newValue;
              });
              // Eliminado: _performFilteredSearch() - ahora solo actualiza el estado
            }
          },
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedLocation != VeterinaryConstants.chiapasLocations.first ||
        _selectedSpecialty != VeterinaryConstants.veterinarySpecialties.first;
  }

  Widget _buildClearFiltersButton() {
    return GestureDetector(
      onTap: _clearFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear_rounded, color: AppColors.error, size: 16),
            SizedBox(width: AppSizes.spaceS),
            Text(
              'Limpiar filtros',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSearchButton() {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSymptomsSearchModal(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
            child: Row(
              children: [
                SizedBox(width: AppSizes.spaceM),
                Expanded(
                  child: Text(
                    '🧠 Buscar por Síntomas con IA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.white),
              ],
            ),
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
          final displayVets =
              _isSearching
                  ? state.veterinarians
                  : state.veterinarians.take(3).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isSearching) ...[
                _buildSectionHeader(state.veterinarians.length, false),
                const SizedBox(height: AppSizes.spaceM),
              ] else ...[
                // ✨ Mostrar información de predicción de IA si está disponible (SIEMPRE, aunque no haya resultados)
                if (state.aiPrediction != null) ...[
                  _buildAIPredictionCard(state.aiPrediction!),
                  const SizedBox(height: AppSizes.spaceM),
                ],
              ],
              
              // Mostrar resultados o estado vacío
              if (displayVets.isEmpty) ...[
                if (_isSearching) 
                  _buildSearchEmptyState() 
                else 
                  _buildEmptyState(),
              ] else ...[
                if (_isSearching) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${displayVets.length} ${displayVets.length == 1 ? 'veterinario encontrado' : 'veterinarios encontrados'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_hasActiveFilters())
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingS,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusS,
                              ),
                            ),
                            child: const Text(
                              'Filtrado',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                ],
                _isSearching
                    ? _buildVerticalVeterinariansList(displayVets)
                    : _buildHorizontalVeterinariansList(displayVets),
              ],
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

  Widget _buildSectionHeader(int totalCount, bool isSearching) {
    final hasFilters = _hasActiveFilters();
    final countToShow =
        isSearching ? totalCount : (totalCount > 3 ? 3 : totalCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSearching
                      ? 'Resultados de búsqueda'
                      : 'Veterinarios Disponibles',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$countToShow de $totalCount veterinarios',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (hasFilters) ...[
                      const SizedBox(width: AppSizes.spaceS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: const Text(
                          'Filtrado',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (hasFilters) ...[
                  const SizedBox(height: 4),
                  _buildActiveFiltersInfo(),
                ],
              ],
            ),
          ),
          if (!isSearching && totalCount > 3)
            TextButton(
              onPressed:
                  () => Navigator.pushNamed(context, '/veterinarians-list'),
              child: const Text(
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

  Widget _buildActiveFiltersInfo() {
    List<String> activeFilters = [];

    if (_selectedLocation != VeterinaryConstants.chiapasLocations.first) {
      activeFilters.add('📍 $_selectedLocation');
    }

    if (_selectedSpecialty != VeterinaryConstants.veterinarySpecialties.first) {
      activeFilters.add('🩺 $_selectedSpecialty');
    }

    return Text(
      activeFilters.join(' • '),
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Método para verificar si hay búsqueda por texto activa




  Widget _buildHorizontalVeterinariansList(List<dynamic> veterinarians) {
    return SizedBox(
      height: 200, // Reducido de 280 a 200 píxeles
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        itemCount: veterinarians.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.spaceM),
        itemBuilder:
            (context, index) =>
                _buildVeterinarianCard(veterinarians[index], true),
      ),
    );
  }

  Widget _buildVerticalVeterinariansList(List<dynamic> veterinarians) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      itemCount: veterinarians.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceM),
      itemBuilder:
          (context, index) =>
              _buildVeterinarianCard(veterinarians[index], false),
    );
  }

  Widget _buildVeterinarianCard(dynamic vet, bool isHorizontal) {
    // Obtener la imagen prioritizando user.profile_photo sobre profile_photo del veterinario
    String? profileImage;
    if (vet.user?.profilePhoto != null && vet.user!.profilePhoto!.isNotEmpty) {
      profileImage = vet.user!.profilePhoto;
    } else if (vet.profilePhoto != null && vet.profilePhoto!.isNotEmpty) {
      profileImage = vet.profilePhoto;
    }

    // Obtener el nombre completo del usuario
    String fullName = 'Nombre no definido';
    if (vet.user != null) {
      final firstName = vet.user!.firstName ?? '';
      final lastName = vet.user!.lastName ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
      }
    }

    // Obtener especialidades o mostrar texto por defecto
    String specialty = 'Medicina General';
    if (vet.specialties != null && vet.specialties!.isNotEmpty) {
      // 🤖 Mapear código de especialidad a nombre legible
      final specialtyCode = vet.specialties!.first;
      specialty = VeterinaryConstants.getDisplayNameFromAICode(specialtyCode);
    }

    // Obtener tarifa de consulta
    String consultationFee = 'No especificada';
    if (vet.consultationFee != null) {
      try {
        final fee = double.tryParse(vet.consultationFee.toString());
        if (fee != null && fee > 0) {
          consultationFee = '\$${fee.toInt()}';
        }
      } catch (e) {
        consultationFee = 'No especificada';
      }
    }

    // Obtener ubicación
    String location = 'Ubicación no definida';
    if (vet.locationCity != null && vet.locationState != null) {
      location = '${vet.locationCity}, ${vet.locationState}';
    } else if (vet.locationCity != null) {
      location = vet.locationCity!;
    } else if (vet.locationState != null) {
      location = vet.locationState!;
    }

    return VeterinarianCard(
      veterinarian: {
        'id': vet.id,
        'name': fullName,
        'specialty': specialty,
        'clinic': location,
        'rating': 4.5, // Este valor podría venir del backend en el futuro
        'experience': vet.experienceText ?? 'Experiencia no definida',
        'distance': '', // Este valor podría calcularse en el futuro
        'consultationFee': consultationFee,
        'available': true, // Este valor podría venir del backend en el futuro
        'profileImage': profileImage,
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

  Widget _buildSearchEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 60,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),
            const Text(
              'No encontramos veterinarios',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceM),
            const Text(
              'La IA procesó tu consulta correctamente, pero no hay veterinarios disponibles para esa especialidad en este momento.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceL),
            // Sugerencias específicas
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.spaceS),
                      const Text(
                        'Sugerencias:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceS),
                  const Text(
                    '• Intenta con una búsqueda más general\n• Prueba describiendo los síntomas de otra forma\n• Busca especialistas en medicina general',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _searchBySymptomsWithAI('medicina general emergencia veterinaria'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    icon: const Icon(Icons.medical_services, size: 16),
                    label: const Text(
                      'Medicina General',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceS),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startNewSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text(
                      'Nueva Búsqueda',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.spaceL),
            const Text(
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
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSizes.spaceL),
            const Text(
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
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSymptomsSearchModal(BuildContext pageContext) {
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => _buildSymptomsSearchContent(pageContext),
    );
  }

  Widget _buildSymptomsSearchContent(BuildContext pageContext) {
    final symptomsController = TextEditingController();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusXL),
              topRight: Radius.circular(AppSizes.radiusXL),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar para arrastrar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: AppSizes.paddingL,
                    left: AppSizes.paddingL,
                    right: AppSizes.paddingL,
                    bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingL,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header con icono
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.psychology_rounded,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Búsqueda Inteligente',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Describe los síntomas de tu mascota',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSizes.spaceXL),
                      
                      // Card informativo mejorado
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingL),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent.withOpacity(0.1),
                              AppColors.accent.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_rounded,
                                    color: AppColors.accent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.spaceM),
                                const Expanded(
                                  child: Text(
                                    'IA Veterinaria Especializada',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.spaceM),
                            const Text(
                              'Nuestra inteligencia artificial analizará los síntomas de tu mascota y te recomendará los especialistas veterinarios más adecuados para el caso.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.spaceXL),
                      
                      // Label del campo
                      const Text(
                        'Describe los síntomas detalladamente:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.spaceM),
                      
                      // Campo de texto mejorado
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: symptomsController,
                          maxLines: 6,
                          minLines: 4,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: 'Ejemplo:\n"Mi perro de 3 años está vomitando desde ayer, tiene diarrea, está muy decaído y no quiere comer. También noto que bebe mucha agua..."',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              height: 1.4,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(AppSizes.paddingL),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.spaceXL),
                      
                      // Botones mejorados
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.paddingL,
                                ),
                                side: BorderSide(
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceM),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                final symptoms = symptomsController.text.trim();
                                if (symptoms.isNotEmpty) {
                                  Navigator.pop(context);
                                  _searchBySymptomsWithAI(symptoms);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.paddingL,
                                ),
                                elevation: 8,
                                shadowColor: AppColors.accent.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.psychology_rounded,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: AppSizes.spaceS),
                                  Text(
                                    'Buscar con IA',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Espacio adicional para el teclado
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? AppSizes.spaceXL : AppSizes.spaceM),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _searchBySymptomsWithAI(String symptoms) {
    setState(() {
      _isSearching = true;
      _searchController.text = '🧠 Búsqueda por síntomas: $symptoms';
    });

    context.read<VeterinarianBloc>().add(
      SearchVeterinariansEvent(
        search: symptoms,
        location: VeterinaryConstants.getLocationForApi(_selectedLocation),
        specialty: VeterinaryConstants.getSpecialtyForApi(_selectedSpecialty),
        symptoms: true,
        useAI: true, // 🤖 Activar IA explícitamente
        limit: 100,
      ),
    );
  }

  void _startNewSearch() {
    _searchDebounce?.cancel();

    setState(() {
      _isSearching = false;
      _searchController.clear();
      _selectedLocation = VeterinaryConstants.chiapasLocations.first;
      _selectedSpecialty = VeterinaryConstants.veterinarySpecialties.first;
    });

    context.read<VeterinarianBloc>().add(
      SearchVeterinariansEvent(
        limit: 100,
        location: VeterinaryConstants.getLocationForApi(VeterinaryConstants.chiapasLocations.first),
        specialty: VeterinaryConstants.getSpecialtyForApi(VeterinaryConstants.veterinarySpecialties.first),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedLocation = VeterinaryConstants.chiapasLocations.first;
      _selectedSpecialty = VeterinaryConstants.veterinarySpecialties.first;
    });

    // Si estamos en modo búsqueda, ejecutar búsqueda con filtros limpiados
    if (_isSearching) {
      _performManualSearch();
    }
  }

  // Nuevo método para resetear al estado inicial
  void _resetToInitialState() {
    _searchDebounce?.cancel();
    
    setState(() {
      _isSearching = false;
    });

    // Cargar veterinarios iniciales con filtros actuales
    context.read<VeterinarianBloc>().add(
      SearchVeterinariansEvent(
        limit: 100,
        location: VeterinaryConstants.getLocationForApi(_selectedLocation),
        specialty: VeterinaryConstants.getSpecialtyForApi(_selectedSpecialty),
      ),
    );
  }

  // Nuevo método para búsqueda manual combinada
  void _performManualSearch() {
    if (_searchController.text.isEmpty && !_hasActiveFilters()) {
      // Si no hay texto ni filtros, mostrar veterinarios por defecto
      _resetToInitialState();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Búsqueda combinada: texto + filtros
    context.read<VeterinarianBloc>().add(
      SearchVeterinariansEvent(
        search: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
        location: VeterinaryConstants.getLocationForApi(_selectedLocation),
        specialty: VeterinaryConstants.getSpecialtyForApi(_selectedSpecialty),
        limit: 100,
      ),
    );
  }

  // ✨ NUEVO: Widget para mostrar información de predicción de IA
  Widget _buildAIPredictionCard(AIPrediction aiPrediction) {
    // 🤖 Convertir el código de IA a nombre legible
    final specialtyDisplayName = VeterinaryConstants.getDisplayNameFromAICode(
      aiPrediction.specialtyCode
    );
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              const Text(
                'Búsqueda Inteligente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            'Interpretamos tu consulta: "${aiPrediction.originalQuery}"',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSizes.spaceXS),
          Row(
            children: [
              const Text(
                'Especialidad sugerida: ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Text(
                  specialtyDisplayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceXS),
          Row(
            children: [
              const Text(
                'Confianza:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSizes.spaceXS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(aiPrediction.confidence),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  '${(aiPrediction.confidence * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              if (aiPrediction.confidence >= 0.8)
                const Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 16,
                )
              else if (aiPrediction.confidence >= 0.6)
                const Icon(
                  Icons.help_outline,
                  color: Colors.orange,
                  size: 16,
                )
              else
                const Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.red,
                  size: 16,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper para obtener el color según el nivel de confianza
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
