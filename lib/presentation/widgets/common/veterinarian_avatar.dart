import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/veterinarian.dart';

class VeterinarianAvatar extends StatelessWidget {
  final Veterinarian? veterinarian;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  const VeterinarianAvatar({
    super.key,
    this.veterinarian,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final String? profilePhoto = veterinarian?.user.profilePhoto ?? veterinarian?.profilePhoto;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.secondary.withOpacity(0.1);
    final effectiveIconColor = iconColor ?? AppColors.secondary;

    return CircleAvatar(
      backgroundColor: effectiveBackgroundColor,
      radius: radius,
      backgroundImage: profilePhoto != null && profilePhoto.isNotEmpty
          ? NetworkImage(profilePhoto)
          : null,
      child: profilePhoto == null || profilePhoto.isEmpty
          ? Icon(
              Icons.local_hospital,
              color: effectiveIconColor,
              size: radius * 0.8,
            )
          : null,
    );
  }
}

class VeterinarianInfo extends StatelessWidget {
  final Veterinarian? veterinarian;
  final String? fallbackName;
  final String? fallbackSpecialty;
  final TextStyle? nameStyle;
  final TextStyle? specialtyStyle;
  final bool showLocation;

  const VeterinarianInfo({
    super.key,
    this.veterinarian,
    this.fallbackName,
    this.fallbackSpecialty,
    this.nameStyle,
    this.specialtyStyle,
    this.showLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = veterinarian != null 
        ? 'Dr. ${veterinarian!.fullName}'
        : fallbackName ?? 'Dr. Veterinario';
    
    final specialty = veterinarian != null && veterinarian!.specialties.isNotEmpty
        ? veterinarian!.specialties.first
        : fallbackSpecialty ?? 'Medicina General';

    final location = veterinarian?.location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: nameStyle ?? const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          specialty,
          style: specialtyStyle ?? const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        if (showLocation && 
            location != null && 
            location.isNotEmpty && 
            location != 'Ubicación no especificada')
          Text(
            location,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
      ],
    );
  }
} 