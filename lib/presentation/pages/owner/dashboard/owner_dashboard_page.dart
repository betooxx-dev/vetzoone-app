import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/pet.dart';
import '../../../blocs/pet/pet_bloc.dart';
import '../../../blocs/pet/pet_event.dart';
import '../../../blocs/pet/pet_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../widgets/cards/pet_card.dart';
import '../../../../core/storage/shared_preferences_helper.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _userGreeting = 'Hola';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(OwnerDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Forzar recarga cada vez que la página vuelve a ser visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    await _loadUserData();
    await _loadPets();
  }

  Future<void> _loadPets() async {
    final userId = await SharedPreferencesHelper.getUserId();
    if (userId != null && mounted) {
      context.read<PetBloc>().add(LoadPetsEvent(userId: userId));
    }
  }

  Future<void> _loadUserData() async {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Buenos días';
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
    } else {
      greeting = 'Buenas noches';
    }

    if (mounted) {
      setState(() {
        _userGreeting = greeting;
      });
    }
  }

  void _navigateToPetDetail(String petId) async {
    await Navigator.pushNamed(context, '/pet-detail', arguments: petId);

    if (mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.secondary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: AppSizes.spaceXL),
                      _buildQuickActions(),
                      const SizedBox(height: AppSizes.spaceXL),
                      _buildMyPetsSection(),
                      const SizedBox(height: AppSizes.spaceXL),
                      _buildUpcomingAppointments(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "dashboard_fab",
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-pet');
          if (mounted) {
            // Esperar un poco para que la operación se complete
            await Future.delayed(const Duration(milliseconds: 500));
            _loadData();
          }
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: AppColors.white),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userGreeting,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceS),
                const Text(
                  'Cuida la salud de tus mascotas',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textOnDark,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: AppColors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spaceM),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Buscar Veterinario',
                Icons.search,
                AppColors.accent,
                () => Navigator.pushNamed(context, '/search-veterinarians'),
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: _buildActionCard(
                'Agendar Cita',
                Icons.calendar_today,
                AppColors.primary,
                () => Navigator.pushNamed(context, '/schedule-appointment'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: AppColors.white, size: 30),
            ),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis mascotas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/my-pets'),
              child: Text(
                'Ver todas',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),
        BlocConsumer<PetBloc, PetState>(
          listener: (context, state) {
            if (state is PetOperationSuccess) {
              // Recargar datos cuando se complete una operación exitosa
              _loadData();
            }
          },
          builder: (context, state) {
            if (state is PetLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
              );
            } else if (state is PetsLoaded) {
              if (state.pets.isEmpty) {
                return _buildNoPetsCard();
              }
              return _buildPetsList(state.pets);
            } else if (state is PetError) {
              return _buildErrorCard(state.message);
            }
            return _buildNoPetsCard();
          },
        ),
      ],
    );
  }

  Widget _buildPetsList(List<Pet> pets) {
    final displayPets = pets.take(3).toList();

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayPets.length,
        itemBuilder: (context, index) {
          final pet = displayPets[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < displayPets.length - 1 ? AppSizes.spaceM : 0,
            ),
            child: SizedBox(
              width: 160,
              child: PetCard(
                pet: pet,
                onTap: () => _navigateToPetDetail(pet.id),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoPetsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary,
                  AppColors.secondary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.pets_outlined,
              color: AppColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSizes.spaceL),
          const Text(
            'No tienes mascotas registradas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceS),
          const Text(
            'Agrega tu primera mascota para comenzar',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.spaceL),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, '/add-pet');
              if (mounted) {
                _loadData();
              }
            },
            icon: const Icon(Icons.add, color: AppColors.white),
            label: const Text(
              'Agregar Mascota',
              style: TextStyle(color: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSizes.spaceM),
          const Text(
            'Error al cargar mascotas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceM),
          TextButton(onPressed: _loadData, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Próximas Citas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/my-appointments'),
              child: Text(
                'Ver todas',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceM),
        _buildAppointmentsCard(),
      ],
    );
  }

  Widget _buildAppointmentsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSizes.spaceL),
          const Text(
            'No tienes citas programadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceS),
          const Text(
            'Agenda una cita con un veterinario',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.spaceL),
          ElevatedButton.icon(
            onPressed:
                () => Navigator.pushNamed(context, '/schedule-appointment'),
            icon: const Icon(Icons.add, color: AppColors.white),
            label: const Text(
              'Agendar Cita',
              style: TextStyle(color: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
