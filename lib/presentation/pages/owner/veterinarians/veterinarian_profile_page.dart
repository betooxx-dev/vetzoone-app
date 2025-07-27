import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/veterinary_constants.dart';
import '../../../../core/injection/injection.dart';
import '../../../../domain/entities/veterinarian.dart';
import '../../../blocs/veterinarian/veterinarian_bloc.dart';
import '../../../blocs/veterinarian/veterinarian_event.dart';
import '../../../blocs/veterinarian/veterinarian_state.dart';

class VeterinarianProfilePage extends StatefulWidget {
  const VeterinarianProfilePage({super.key});

  @override
  State<VeterinarianProfilePage> createState() =>
      _VeterinarianProfilePageState();
}

class _VeterinarianProfilePageState extends State<VeterinarianProfilePage> {
  String? vetId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    vetId = args?['vetId'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    if (vetId == null) {
      return const Scaffold(
        body: Center(child: Text('ID de veterinario no válido')),
      );
    }

    return BlocProvider<VeterinarianBloc>(
      create:
          (context) =>
              sl<VeterinarianBloc>()..add(GetVeterinarianProfileEvent(vetId!)),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: BlocBuilder<VeterinarianBloc, VeterinarianState>(
          builder: (context, state) {
            if (state is VeterinarianLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VeterinarianError) {
              return _buildErrorState(state.message);
            }

            if (state is VeterinarianProfileLoaded) {
              return _buildProfileContent(state.veterinarian);
            }

            return const Center(child: Text('Error inesperado'));
          },
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
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSizes.spaceL),
            Text(
              'Error al cargar perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.spaceL),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(Veterinarian veterinarian) {
    return Stack(
      children: [
        _buildDecorativeBackground(),
        CustomScrollView(
          slivers: [
            _buildSliverAppBar(veterinarian),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildVeterinarianInfo(veterinarian),
                  _buildContactInfo(veterinarian),
                  _buildScheduleInfo(veterinarian),
                  _buildServicesInfo(veterinarian),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: _buildFloatingActionButton(veterinarian),
        ),
      ],
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

  Widget _buildSliverAppBar(Veterinarian veterinarian) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Container(
        margin: const EdgeInsets.all(AppSizes.paddingS),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Hero(
                tag: 'vet-${veterinarian.id}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _buildProfileImage(veterinarian),
                ),
              ),
              const SizedBox(height: AppSizes.spaceL),
              Text(
                veterinarian.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSizes.spaceXS),
              Text(
                veterinarian.specialties.isNotEmpty
                    ? veterinarian.specialties
                        .map((specialtyCode) => VeterinaryConstants.getDisplayNameFromAICode(specialtyCode))
                        .join(', ')
                    : 'Especialidad no definida',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  fontStyle: veterinarian.specialties.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(Veterinarian veterinarian) {
    // Obtener la imagen prioritizando user.profilePhoto sobre profilePhoto del veterinario
    String? profileImage;
    if (veterinarian.user.profilePhoto != null && veterinarian.user.profilePhoto!.isNotEmpty) {
      profileImage = veterinarian.user.profilePhoto;
    } else if (veterinarian.profilePhoto != null && veterinarian.profilePhoto!.isNotEmpty) {
      profileImage = veterinarian.profilePhoto;
    }

    if (profileImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          profileImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.person_rounded,
            size: 50,
            color: AppColors.white,
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    } else {
      return const Icon(
        Icons.person_rounded,
        size: 50,
        color: AppColors.white,
      );
    }
  }

  String _getConsultationFeeText(dynamic consultationFee) {
    if (consultationFee == null) return 'No especificada';
    
    try {
      final fee = double.tryParse(consultationFee.toString());
      if (fee != null && fee > 0) {
        return '\$${fee.toInt()}';
      }
    } catch (e) {
      // Si hay error en la conversión, regresa el texto por defecto
    }
    
    return 'No especificada';
  }

  Widget _buildVeterinarianInfo(Veterinarian veterinarian) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem(
                'Experiencia',
                veterinarian.experienceText,
                Icons.timeline_outlined,
                AppColors.secondary,
              ),
              _buildStatItem(
                'Consulta',
                _getConsultationFeeText(veterinarian.consultationFee),
                Icons.attach_money_outlined,
                AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          if (veterinarian.bio != null && veterinarian.bio!.isNotEmpty)
            Text(
              veterinarian.bio!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
          else
            _buildEmptySection(
              'Sin descripción disponible',
              'El veterinario no ha agregado información adicional',
              Icons.info_outline,
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(Veterinarian veterinarian) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de Contacto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceL),
          if (veterinarian.license.isNotEmpty)
            _buildContactItem(
              Icons.badge_outlined,
              'Cédula',
              veterinarian.license,
            )
          else
            _buildContactItem(
              Icons.badge_outlined,
              'Cédula',
              'No especificada',
            ),

          if (veterinarian.location.isNotEmpty &&
              veterinarian.location != 'Ubicación no especificada')
            _buildContactItem(
              Icons.location_on_outlined,
              'Ubicación',
              veterinarian.location,
            )
          else
            _buildContactItem(
              Icons.location_on_outlined,
              'Ubicación',
              'No especificada',
            ),

          if (veterinarian.user.phone.isNotEmpty)
            _buildContactItem(
              Icons.phone_outlined,
              'Teléfono',
              veterinarian.user.phone,
            )
          else
            _buildContactItem(
              Icons.phone_outlined,
              'Teléfono',
              'No especificado',
            ),

          if (veterinarian.user.email.isNotEmpty)
            _buildContactItem(
              Icons.email_outlined,
              'Email',
              veterinarian.user.email,
            )
          else
            _buildContactItem(Icons.email_outlined, 'Email', 'No especificado'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    final isEmpty = value == 'No especificada' || value == 'No especificado';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isEmpty
                      ? AppColors.textSecondary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              icon,
              color: isEmpty ? AppColors.textSecondary : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isEmpty
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo(Veterinarian veterinarian) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingL,
        AppSizes.paddingL,
        0,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                color: AppColors.secondary,
                size: 24,
              ),
              const SizedBox(width: AppSizes.spaceS),
              const Text(
                'Disponibilidad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          if (veterinarian.availability.isNotEmpty)
            ...veterinarian.availability.map(
              (schedule) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
                child: Text(
                  schedule,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            _buildEmptySection(
              'Sin horarios disponibles',
              'El veterinario no ha configurado su disponibilidad',
              Icons.schedule_outlined,
            ),
        ],
      ),
    );
  }

  Widget _buildServicesInfo(Veterinarian veterinarian) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingL,
        AppSizes.paddingL,
        0,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: AppSizes.spaceS),
              const Text(
                'Servicios Disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceL),
          if (veterinarian.services.isNotEmpty)
            Wrap(
              spacing: AppSizes.spaceS,
              runSpacing: AppSizes.spaceS,
              children:
                  veterinarian.services
                      .map(
                        (service) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                            vertical: AppSizes.paddingS,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusL,
                            ),
                          ),
                          child: Text(
                            service,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            )
          else
            _buildEmptySection(
              'Sin servicios especificados',
              'El veterinario no ha agregado servicios específicos',
              Icons.medical_services_outlined,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String title, String subtitle, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppColors.textSecondary.withOpacity(0.5)),
        const SizedBox(height: AppSizes.spaceS),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXS),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(Veterinarian veterinarian) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _scheduleAppointment(veterinarian),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.calendar_today_rounded, color: AppColors.white),
        label: const Text(
          'Agendar Cita',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  void _scheduleAppointment(Veterinarian veterinarian) {
    Navigator.pushNamed(
      context,
      '/schedule-appointment',
      arguments: {'veterinarian': veterinarian},
    );
  }
}
