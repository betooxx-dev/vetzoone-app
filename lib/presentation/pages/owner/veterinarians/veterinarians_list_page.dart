import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/veterinary_constants.dart';
import '../../../../core/injection/injection.dart';
import '../../../widgets/cards/veterinarian_card.dart';
import '../../../blocs/veterinarian/veterinarian_bloc.dart';
import '../../../blocs/veterinarian/veterinarian_event.dart';
import '../../../blocs/veterinarian/veterinarian_state.dart';

class VeterinariansListPage extends StatefulWidget {
  const VeterinariansListPage({super.key});

  @override
  State<VeterinariansListPage> createState() => _VeterinariansListPageState();
}

class _VeterinariansListPageState extends State<VeterinariansListPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

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
        backgroundColor: AppColors.backgroundLight,
        body: Stack(
          children: [
            _buildDecorativeBackground(),
            SafeArea(
              child: Column(
                children: [_buildAppBar(), Expanded(child: _buildListView())],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.backgroundLight, AppColors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
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
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
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
                    color: AppColors.black.withOpacity(0.1),
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
              'Todos los Veterinarios',
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

  Widget _buildListView() {
    return BlocBuilder<VeterinarianBloc, VeterinarianState>(
      builder: (context, state) {
        if (state is VeterinarianLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is VeterinarianError) {
          return _buildErrorState(state.message);
        }

        if (state is VeterinarianSearchSuccess) {
          if (state.veterinarians.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingL,
              0,
              AppSizes.paddingL,
              AppSizes.paddingL,
            ),
            itemCount: state.veterinarians.length,
            itemBuilder: (context, index) {
              final vet = state.veterinarians[index];
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final delay = index * 0.1;
                  final animationValue = (_animationController.value - delay)
                      .clamp(0.0, 1.0);

                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - animationValue)),
                    child: Opacity(
                      opacity: animationValue,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
                        child: VeterinarianCard(
                          veterinarian: {
                            'id': vet.id,
                            'name': _getFullName(vet),
                            'specialty': _getSpecialty(vet),
                            'clinic': _getLocation(vet),
                            'rating': 4.5,
                            'experience': _getExperience(vet),
                            'distance': '',
                            'consultationFee': _getConsultationFee(vet),
                            'available': true,
                            'profileImage': _getProfileImage(vet),
                          },
                          isHorizontal: false,
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                '/veterinarian-profile',
                                arguments: {'vetId': vet.id},
                              ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }

        return _buildEmptyState();
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
              'No hay veterinarios disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              'No se encontraron veterinarios registrados',
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

  Widget _buildErrorState(String message) {
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
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 50,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),
            const Text(
              'Error al cargar veterinarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceL),
            ElevatedButton(
              onPressed:
                  () => context.read<VeterinarianBloc>().add(
                    const SearchVeterinariansEvent(limit: 100),
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos helper para manejo consistente de datos
  String _getFullName(dynamic vet) {
    if (vet.user != null) {
      final firstName = vet.user!.firstName ?? '';
      final lastName = vet.user!.lastName ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '${firstName.trim()} ${lastName.trim()}'.trim();
      }
    }
    return 'Nombre no definido';
  }

  String _getSpecialty(dynamic vet) {
    if (vet.specialties != null && vet.specialties!.isNotEmpty) {
      // 🤖 Mapear código de especialidad a nombre legible
      final specialtyCode = vet.specialties!.first;
      return VeterinaryConstants.getDisplayNameFromAICode(specialtyCode);
    }
    return 'Medicina General';
  }

  String _getLocation(dynamic vet) {
    if (vet.locationCity != null && vet.locationState != null) {
      return '${vet.locationCity}, ${vet.locationState}';
    } else if (vet.locationCity != null) {
      return vet.locationCity!;
    } else if (vet.locationState != null) {
      return vet.locationState!;
    }
    return 'Ubicación no definida';
  }

  String _getExperience(dynamic vet) {
    return vet.experienceText ?? 'Sin experiencia';
  }

  String _getConsultationFee(dynamic vet) {
    if (vet.consultationFee != null) {
      try {
        final fee = double.tryParse(vet.consultationFee.toString());
        if (fee != null && fee > 0) {
          return '\$${fee.toInt()}';
        }
      } catch (e) {
        // Error en conversión
      }
    }
    return 'No especificada';
  }

  String? _getProfileImage(dynamic vet) {
    if (vet.user?.profilePhoto != null && vet.user!.profilePhoto!.isNotEmpty) {
      return vet.user!.profilePhoto;
    } else if (vet.profilePhoto != null && vet.profilePhoto!.isNotEmpty) {
      return vet.profilePhoto;
    }
    return null;
  }
}
