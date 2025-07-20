import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/pet/pet_bloc.dart';
import '../../../blocs/pet/pet_event.dart';
import '../../../blocs/pet/pet_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../widgets/cards/pet_card.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../domain/entities/pet.dart';

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  @override
  void didUpdateWidget(MyPetsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadPets();
  }

  Future<void> _loadPets() async {
    final userId = await SharedPreferencesHelper.getUserId();
    if (userId != null && mounted) {
      context.read<PetBloc>().add(LoadPetsEvent(userId: userId));
    }
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
            // Formas decorativas
            _buildDecorativeShapes(),

            // Contenido principal
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: BlocConsumer<PetBloc, PetState>(
                      listener: (context, state) {
                        if (state is PetError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        } else if (state is PetOperationSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          _loadPets();
                        }
                      },
                      builder: (context, state) {
                        if (state is PetLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.secondary,
                            ),
                          );
                        } else if (state is PetsLoaded) {
                          if (state.pets.isEmpty) {
                            return _buildEmptyState();
                          }
                          return _buildPetsList(state.pets);
                        } else if (state is PetError) {
                          return _buildErrorState(state.message);
                        }
                        return _buildEmptyState();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "add_pet_fab",
        onPressed: () => Navigator.pushNamed(context, '/add-pet'),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          'Agregar Mascota',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
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
          top: 200,
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis Mascotas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Gestiona la información de tus mascotas',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList(List<Pet> pets) {
    return RefreshIndicator(
      onRefresh: () async => _loadPets(),
      color: AppColors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return PetCard(
            pet: pet,
            isHorizontal: true,
            onTap:
                () => Navigator.pushNamed(
                  context,
                  '/pet-detail',
                  arguments: pet.id,
                ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
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
                  AppColors.secondary,
                  AppColors.secondary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: AppColors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: AppSizes.spaceXL),
          const Text(
            'No tienes mascotas registradas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceM),
          const Text(
            'Agrega tu primera mascota para comenzar a gestionar su cuidado y salud.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceXXL),
          Container(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary,
                  AppColors.secondary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add-pet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppColors.white, size: 24),
                  const SizedBox(width: AppSizes.spaceS),
                  const Text(
                    'Agregar Primera Mascota',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(Icons.error_outline, color: AppColors.error, size: 48),
          ),
          const SizedBox(height: AppSizes.spaceXL),
          const Text(
            'Error al cargar mascotas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceM),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spaceXL),
          ElevatedButton.icon(
            onPressed: () => _loadPets(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Reintentar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
