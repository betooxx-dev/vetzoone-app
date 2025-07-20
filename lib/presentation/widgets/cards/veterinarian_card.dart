import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

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
        width: 260,
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
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSizes.spaceM),
                  _buildVetInfo(),
                  const SizedBox(height: AppSizes.spaceM),
                  _buildExperience(),
                  const SizedBox(height: AppSizes.spaceL),
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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child:
              veterinarian['profileImage'] != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    child: Image.network(
                      veterinarian['profileImage'],
                      fit: BoxFit.cover,
                    ),
                  )
                  : const Icon(Icons.person, color: AppColors.white, size: 30),
        ),

        const SizedBox(width: AppSizes.spaceM),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                veterinarian['name'] ?? 'Veterinario',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.spaceXS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: AppSizes.paddingXS,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  veterinarian['specialty'] ?? 'General',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVetInfo() {
    return Row(
      children: [
        Icon(
          Icons.local_hospital_rounded,
          size: 16,
          color: AppColors.secondary,
        ),
        const SizedBox(width: AppSizes.spaceXS),
        Expanded(
          child: Text(
            veterinarian['clinic'] ?? 'Clínica Veterinaria',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExperience() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timeline_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            veterinarian['experience'] ?? '0 años',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
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
      height: 44,
      child: ElevatedButton.icon(
        onPressed: isAvailable ? () => _scheduleAppointment() : null,
        icon: const Icon(Icons.calendar_today_rounded, size: 16),
        label: Text(isAvailable ? 'Agendar Cita' : 'No Disponible'),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isAvailable
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.3),
          foregroundColor: AppColors.white,
          elevation: 0,
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
