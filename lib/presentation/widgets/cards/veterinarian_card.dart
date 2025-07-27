import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/image_utils.dart';

class VeterinarianCard extends StatelessWidget {
  final Map<String, dynamic> veterinarian;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const VeterinarianCard({
    super.key,
    required this.veterinarian,
    this.onTap,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _navigateToProfile(context),
      child: Container(
        width: isHorizontal ? 240 : null, // Reducido de 260 a 240
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  AppColors.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM), // Reducido de paddingL a paddingM
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Agregado para evitar overflow
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSizes.spaceS), // Reducido de spaceM a spaceS
                  _buildVetInfo(),
                  const SizedBox(height: AppSizes.spaceS), // Reducido de spaceM a spaceS
                  _buildExperience(), // Simplificado: solo experiencia
                  const SizedBox(height: AppSizes.spaceS), // Reducido de spaceM a spaceS
                  _buildActionButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50, // Reducido de 60 a 50
          height: 50, // Reducido de 60 a 50
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8, // Reducido de 10 a 8
                offset: const Offset(0, 3), // Reducido de 5 a 3
              ),
            ],
          ),
          child:
              veterinarian['profileImage'] != null && 
              veterinarian['profileImage'].toString().isNotEmpty &&
              ImageUtils.isValidImageUrl(veterinarian['profileImage'].toString())
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    child: Image.network(
                      veterinarian['profileImage'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading profile image: $error');
                        return const Icon(
                          Icons.person,
                          color: AppColors.white,
                          size: 25, // Reducido de 30 a 25
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 1.5, // Reducido de 2 a 1.5
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  )
                  : const Icon(Icons.person, color: AppColors.white, size: 25), // Reducido de 30 a 25
        ),

        const SizedBox(width: AppSizes.spaceS), // Reducido de spaceM a spaceS

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                veterinarian['name'] ?? 'Nombre no definido',
                style: TextStyle(
                  fontSize: 14, // Reducido de 16 a 14
                  fontWeight: FontWeight.bold,
                  color: veterinarian['name'] != null && veterinarian['name'] != 'Nombre no definido'
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontStyle: veterinarian['name'] != null && veterinarian['name'] != 'Nombre no definido'
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Reducido espacio
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXS, // Reducido de paddingS a paddingXS
                  vertical: 2, // Reducido padding vertical
                ),
                decoration: BoxDecoration(
                  gradient: veterinarian['specialty'] != null && 
                           veterinarian['specialty'] != 'Medicina General'
                      ? AppColors.purpleGradient
                      : LinearGradient(
                          colors: [
                            AppColors.textSecondary.withValues(alpha: 0.7),
                            AppColors.textSecondary.withValues(alpha: 0.5),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  veterinarian['specialty'] ?? 'Especialidad no definida',
                  style: const TextStyle(
                    fontSize: 10, // Reducido de 11 a 10
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVetInfo() {
    final clinic = veterinarian['clinic'] ?? 'Ubicación no definida';
    final isLocationDefined = clinic != 'Ubicación no definida';
    
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: isLocationDefined ? AppColors.secondary : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSizes.spaceXS),
        Expanded(
          child: Text(
            clinic,
            style: TextStyle(
              fontSize: 12,
              color: isLocationDefined ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              fontStyle: isLocationDefined ? FontStyle.normal : FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExperience() {
    final experience = veterinarian['experience'] ?? 'Sin experiencia';
    final isExperienceDefined = experience != 'Experiencia no definida' && experience != 'Sin experiencia';
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXS, // Reducido padding
        vertical: 3, // Reducido padding vertical
      ),
      decoration: BoxDecoration(
        color: isExperienceDefined 
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timeline_rounded,
            size: 12, // Reducido de 14 a 12
            color: isExperienceDefined ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 3), // Reducido de 4 a 3
          Expanded( // Agregado Expanded para evitar overflow
            child: Text(
              experience,
              style: TextStyle(
                fontSize: 10, // Reducido de 12 a 10
                fontWeight: FontWeight.w600,
                color: isExperienceDefined ? AppColors.primary : AppColors.textSecondary,
                fontStyle: isExperienceDefined ? FontStyle.normal : FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isAvailable = veterinarian['available'] ?? false;

    return SizedBox(
      width: double.infinity,
      height: 36, // Reducido de 44 a 36
      child: ElevatedButton.icon(
        onPressed: isAvailable ? () => _scheduleAppointment() : null,
        icon: const Icon(Icons.calendar_today_rounded, size: 14), // Reducido de 16 a 14
        label: Text(
          isAvailable ? 'Agendar' : 'No Disponible', // Texto más corto
          style: const TextStyle(fontSize: 12), // Tamaño de fuente reducido
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isAvailable
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.3),
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8), // Padding reducido
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/veterinarian-profile',
      arguments: veterinarian,
    );
  }

  void _scheduleAppointment() {
    print('Agendando cita con ${veterinarian['name']}');
  }
}
